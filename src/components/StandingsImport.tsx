import { useRef, useState } from 'react';
import { supabase } from '../lib/supabase';
import { ParsedRow, matchTeam, parseStandings, resizeImage, runOcr } from '../lib/standingsParser';

interface Props {
  tournamentId: string;
  yearEnd: number;
  catalog: string[]; // Known team names
  initialRows?: ParsedRow[]; // Pre-fill (edit mode); when provided, skips the upload stage
  onClose: () => void;
  onSaved: () => void;
}

type Stage = 'pick' | 'ocr' | 'review';

function emptyRows(count: number): ParsedRow[] {
  return Array.from({ length: count }, (_, i) => ({ position: i + 1, team: '', played: null, wins: null, draws: null, losses: null, gf: null, ga: null, points: null }));
}

export default function StandingsImport({ tournamentId, yearEnd, catalog, initialRows, onClose, onSaved }: Props) {
  const [stage, setStage] = useState<Stage>(initialRows ? 'review' : 'pick');
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [progress, setProgress] = useState(0);
  const [rows, setRows] = useState<ParsedRow[]>(initialRows && initialRows.length ? initialRows : (initialRows ? emptyRows(20) : []));
  const [rawText, setRawText] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const fileRef = useRef<HTMLInputElement>(null);

  async function handleFile(file: File) {
    setError(null); setStage('ocr'); setProgress(0);
    try {
      setImagePreview(URL.createObjectURL(file));
      const resized = await resizeImage(file);
      const text = await runOcr(resized, (p) => setProgress(p));
      setRawText(text);
      const parsed = parseStandings(text);
      // Try fuzzy matching each team against catalog
      const matched = parsed.map((r) => ({ ...r, team: matchTeam(r.team, catalog) ?? r.team }));
      setRows(matched);
      setStage('review');
    } catch (e: any) {
      setError(e.message || 'OCR failed');
      setStage('pick');
    }
  }

  // Append year to a champion's years_won / years_runner_up, or insert new row
  async function upsertChampion(teamName: string, kind: 'won' | 'runner_up') {
    const yearStr = String(yearEnd);
    const { data: existing } = await supabase.from('champions')
      .select('id, wins, runners_up, years_won, years_runner_up')
      .eq('tournament_id', tournamentId)
      .eq('team_name', teamName)
      .maybeSingle();
    if (existing) {
      const col = kind === 'won' ? 'years_won' : 'years_runner_up';
      const countCol = kind === 'won' ? 'wins' : 'runners_up';
      const current = (existing as any)[col] as string | null;
      if (!current || !new RegExp(`\\b${yearStr}\\b`).test(current)) {
        const next = current ? `${current}, ${yearStr}` : yearStr;
        await supabase.from('champions').update({
          [col]: next,
          [countCol]: ((existing as any)[countCol] ?? 0) + 1,
        }).eq('id', existing.id);
      }
    } else {
      await supabase.from('champions').insert({
        tournament_id: tournamentId,
        team_name: teamName,
        wins: kind === 'won' ? 1 : 0,
        runners_up: kind === 'won' ? 0 : 1,
        years_won: kind === 'won' ? yearStr : null,
        years_runner_up: kind === 'runner_up' ? yearStr : null,
      });
    }
  }

  async function save() {
    if (!rows.length) { setError('No rows to save'); return; }
    setSaving(true); setError(null);
    try {
      const payload = rows.filter((r) => r.team && r.position != null).map((r) => ({
        tournament_id: tournamentId, year_end: yearEnd, team_name: r.team,
        position: r.position, played: r.played, wins: r.wins, draws: r.draws, losses: r.losses,
        goals_for: r.gf, goals_against: r.ga, points: r.points,
      }));
      // Clear previous entries for this tournament+year first (so re-upload replaces)
      await supabase.from('standings').delete().eq('tournament_id', tournamentId).eq('year_end', yearEnd);
      const { error } = await supabase.from('standings').insert(payload);
      if (error) throw error;

      // Auto-mirror: position 1 → champion, position 2 → runner-up (in champions table)
      // Strict check: team must be non-empty trimmed string
      const winner = rows.find((r) => r.position === 1 && r.team && r.team.trim().length > 0);
      const runnerUp = rows.find((r) => r.position === 2 && r.team && r.team.trim().length > 0);
      if (winner) await upsertChampion(winner.team.trim(), 'won');
      if (runnerUp) await upsertChampion(runnerUp.team.trim(), 'runner_up');

      onSaved(); onClose();
    } catch (e: any) {
      setError(e.message || 'Save failed');
    } finally { setSaving(false); }
  }

  function updateRow(i: number, patch: Partial<ParsedRow>) {
    setRows((rs) => rs.map((r, idx) => idx === i ? { ...r, ...patch } : r));
  }
  function addRow() { setRows((rs) => [...rs, { position: rs.length + 1, team: '', played: null, wins: null, draws: null, losses: null, gf: null, ga: null, points: null }]); }
  function delRow(i: number) { setRows((rs) => rs.filter((_, idx) => idx !== i)); }

  return (
    <div className="fixed inset-0 z-50 bg-black/60 flex items-center justify-center p-4" onClick={onClose}>
      <div onClick={(e) => e.stopPropagation()} className="bg-white dark:bg-slate-900 rounded-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto p-5">
        <div className="flex items-center justify-between mb-4">
          <div><h2 className="text-lg font-bold">{initialRows ? 'Editar tabla' : 'Importar tabla desde foto'}</h2><div className="text-xs text-slate-500">Season {yearEnd - 1}-{String(yearEnd).slice(-2)}</div></div>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-700 text-2xl leading-none">×</button>
        </div>

        {error && <div className="mb-3 p-3 bg-red-50 border border-red-200 text-red-700 rounded text-sm">⚠️ {error}</div>}

        {stage === 'pick' && (
          <div className="space-y-3">
            <div className="p-5 border-2 border-dashed border-slate-300 dark:border-slate-700 rounded-lg text-center">
              <div className="text-4xl mb-2">📷</div>
              <div className="text-sm text-slate-600 dark:text-slate-300 mb-3">Sube una screenshot de la tabla de posiciones (FIFA, EA FC, cualquier liga)</div>
              <input ref={fileRef} type="file" accept="image/*" capture="environment" className="hidden" onChange={(e) => { const f = e.target.files?.[0]; if (f) handleFile(f); }} />
              <button onClick={() => fileRef.current?.click()} className="bg-emerald-600 hover:bg-emerald-500 text-white rounded px-5 py-2 text-sm font-semibold">Elegir imagen</button>
            </div>
            <div className="text-xs text-slate-500 text-center">
              Tip: entre más clara la foto, mejor. Zoom al zoom in antes de capturar es ideal. Vas a poder editar antes de guardar.
            </div>
          </div>
        )}

        {stage === 'ocr' && (
          <div className="text-center py-10">
            {imagePreview && <img src={imagePreview} alt="" className="max-h-40 mx-auto rounded mb-4 opacity-50" />}
            <div className="text-sm text-slate-600 mb-3">Analizando imagen con OCR local…</div>
            <div className="w-full bg-slate-200 rounded-full h-2 max-w-xs mx-auto"><div className="bg-emerald-500 h-2 rounded-full transition-all" style={{ width: `${Math.round(progress * 100)}%` }} /></div>
            <div className="text-xs text-slate-400 mt-2">{Math.round(progress * 100)}% · esto toma 10-30 segundos</div>
          </div>
        )}

        {stage === 'review' && (
          <div>
            {imagePreview && <details className="mb-3"><summary className="text-xs text-slate-500 cursor-pointer">Ver imagen original</summary><img src={imagePreview} alt="" className="mt-2 max-h-60 rounded" /></details>}
            <div className="flex items-center justify-between mb-2">
              <div className="text-sm font-semibold">{rows.length} filas detectadas · revisa y edita</div>
              <button onClick={addRow} className="text-xs bg-emerald-600 text-white rounded px-2 py-1">+ Fila</button>
            </div>
            <div className="border border-slate-200 dark:border-slate-700 rounded overflow-hidden bg-white dark:bg-slate-800 overflow-x-auto">
              <table className="w-full text-xs">
                <thead className="bg-slate-100 dark:bg-slate-900 text-slate-500 uppercase">
                  <tr>
                    <th className="p-1 w-10">#</th><th className="p-1 text-left">Equipo</th>
                    <th className="p-1 w-12">PJ</th><th className="p-1 w-12">G</th><th className="p-1 w-12">E</th><th className="p-1 w-12">P</th>
                    <th className="p-1 w-12">GF</th><th className="p-1 w-12">GC</th><th className="p-1 w-14">Pts</th><th></th>
                  </tr>
                </thead>
                <tbody>{rows.map((r, i) => (
                  <tr key={i} className="border-t border-slate-100 dark:border-slate-700">
                    <td><input type="number" value={r.position ?? ''} onChange={(e) => updateRow(i, { position: e.target.value ? Number(e.target.value) : null })} className="w-full bg-transparent border-0 p-1 text-center focus:bg-emerald-50 dark:focus:bg-slate-700" /></td>
                    <td><input value={r.team} onChange={(e) => updateRow(i, { team: e.target.value })} list="team-catalog" className="w-full bg-transparent border-0 p-1 focus:bg-emerald-50 dark:focus:bg-slate-700" /></td>
                    {(['played','wins','draws','losses','gf','ga','points'] as const).map((k) => (
                      <td key={k}><input type="number" value={(r[k] ?? '') as any} onChange={(e) => updateRow(i, { [k]: e.target.value ? Number(e.target.value) : null } as any)} className="w-full bg-transparent border-0 p-1 text-center focus:bg-emerald-50 dark:focus:bg-slate-700" /></td>
                    ))}
                    <td><button onClick={() => delRow(i)} className="text-slate-400 hover:text-red-500 px-1">×</button></td>
                  </tr>
                ))}</tbody>
              </table>
              <datalist id="team-catalog">{catalog.map((t) => <option key={t} value={t} />)}</datalist>
            </div>
            {rawText && <details className="mt-3"><summary className="text-xs text-slate-400 cursor-pointer">Ver texto OCR crudo</summary><pre className="mt-2 p-2 bg-slate-50 dark:bg-slate-800 text-xs overflow-auto max-h-40 rounded">{rawText}</pre></details>}
            <div className="flex justify-end gap-2 mt-4">
              {!initialRows && <button onClick={() => setStage('pick')} className="text-sm text-slate-500 px-3">← Otra imagen</button>}
              <button onClick={onClose} className="text-sm text-slate-500 px-3">Cancel</button>
              <button onClick={save} disabled={saving} className="bg-emerald-600 hover:bg-emerald-500 disabled:bg-emerald-300 text-white rounded px-5 py-2 text-sm font-semibold">{saving ? 'Guardando…' : `Guardar ${rows.filter(r => r.team).length} filas`}</button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
