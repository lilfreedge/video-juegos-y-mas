import { useEffect, useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import Loading from '../components/Loading';
import StandingsImport from '../components/StandingsImport';

interface Tournament { id: string; name: string; country: string | null; logo_url: string | null; has_top_scorer: boolean; color: string | null; text_color: string | null; }
interface Champion { id: string; tournament_id: string; team_name: string; team_country: string | null; team_color: string | null; team_text_color: string | null; wins: number; runners_up: number; years_won: string | null; years_runner_up: string | null; from_my_career: boolean; }
interface Scorer { id: string; tournament_id: string; year: number; player_name: string; nationality: string | null; team: string | null; goals: number; from_my_career: boolean; }
interface Standing { id: string; tournament_id: string; year_end: number; team_name: string; position: number | null; played: number | null; wins: number | null; draws: number | null; losses: number | null; goals_for: number | null; goals_against: number | null; points: number | null; }

export default function TournamentDetailPage() {
  const { id } = useParams();
  const [t, setT] = useState<Tournament | null>(null);
  const [champs, setChamps] = useState<Champion[]>([]);
  const [scorers, setScorers] = useState<Scorer[]>([]);
  const [standings, setStandings] = useState<Standing[]>([]);
  const [catalog, setCatalog] = useState<string[]>([]);
  const [standingsYear, setStandingsYear] = useState<number>(new Date().getFullYear() + 1);
  const [showImport, setShowImport] = useState(false);
  const [showEdit, setShowEdit] = useState(false);
  const [loading, setLoading] = useState(true);
  const [editingC, setEditingC] = useState<string | null>(null); // id or 'new'
  const [editingS, setEditingS] = useState<string | null>(null);
  const [cForm, setCForm] = useState<Partial<Champion>>({});
  const [sForm, setSForm] = useState<Partial<Scorer>>({ year: new Date().getFullYear(), goals: 0 });

  async function load() {
    if (!id) return;
    setLoading(true);
    const [{ data: td }, { data: cd }, { data: sd }, { data: std }, { data: cat }] = await Promise.all([
      supabase.from('tournaments').select('*').eq('id', id).maybeSingle(),
      supabase.from('champions').select('*').eq('tournament_id', id).order('wins', { ascending: false }),
      supabase.from('top_scorers').select('*').eq('tournament_id', id).order('goals', { ascending: false }),
      supabase.from('standings').select('*').eq('tournament_id', id).order('year_end', { ascending: false }).order('position', { ascending: true }),
      supabase.from('clubs_catalog').select('name').order('name'),
    ]);
    setT(td as Tournament | null);
    setChamps((cd ?? []) as Champion[]);
    setScorers((sd ?? []) as Scorer[]);
    setStandings((std ?? []) as Standing[]);
    setCatalog(((cat ?? []) as { name: string }[]).map((c) => c.name));
    setLoading(false);
  }
  useEffect(() => { load(); }, [id]);

  // Count chronological appearances per player (within this tournament's scorers)
  // appearance[id] = 1 means first time, 2 = second, etc.
  const scorerAppearance = useMemo(() => {
    const sorted = [...scorers].sort((a, b) => a.year - b.year);
    const seen: Record<string, number> = {};
    const result: Record<string, number> = {};
    for (const s of sorted) {
      const key = s.player_name.toLowerCase().trim();
      seen[key] = (seen[key] ?? 0) + 1;
      result[s.id] = seen[key];
    }
    return result;
  }, [scorers]);

  const availableYears = useMemo(() => Array.from(new Set(standings.map((s) => s.year_end))).sort((a, b) => b - a), [standings]);
  useEffect(() => { if (availableYears.length && !availableYears.includes(standingsYear)) setStandingsYear(availableYears[0]); }, [availableYears]);
  const standingsForYear = useMemo(() => standings.filter((s) => s.year_end === standingsYear).sort((a, b) => (a.position ?? 999) - (b.position ?? 999)), [standings, standingsYear]);

  async function delStandings() {
    if (!id || !confirm(`Borrar standings de ${standingsYear - 1}-${String(standingsYear).slice(-2)}?`)) return;
    await supabase.from('standings').delete().eq('tournament_id', id).eq('year_end', standingsYear);
    load();
  }

  function openNewChamp() { setCForm({ team_color: '#1e3a8a', team_text_color: '#ffffff', wins: 0, runners_up: 0 }); setEditingC('new'); }
  function openEditChamp(c: Champion) { setCForm({ ...c }); setEditingC(c.id); }
  function cancelC() { setEditingC(null); setCForm({}); }

  async function saveChamp() {
    if (!id || !cForm.team_name) return;
    const payload: any = {
      tournament_id: id,
      team_name: cForm.team_name.trim(),
      team_country: cForm.team_country || null,
      team_color: cForm.team_color || null,
      team_text_color: cForm.team_text_color || null,
      wins: Number(cForm.wins ?? 0),
      runners_up: Number(cForm.runners_up ?? 0),
      years_won: cForm.years_won || null,
      years_runner_up: cForm.years_runner_up || null,
      from_my_career: !!cForm.from_my_career,
    };
    const r = editingC === 'new' ? await supabase.from('champions').insert(payload) : await supabase.from('champions').update(payload).eq('id', editingC!);
    if (r.error) { alert(r.error.message); return; }
    cancelC(); load();
  }
  async function delChamp(cid: string) { if (!confirm('Delete?')) return; await supabase.from('champions').delete().eq('id', cid); load(); }

  async function saveScorer() {
    if (!id || !sForm.year || !sForm.player_name) return;
    const payload: any = { tournament_id: id, year: Number(sForm.year), player_name: sForm.player_name, nationality: sForm.nationality || null, team: sForm.team || null, goals: Number(sForm.goals ?? 0), from_my_career: !!sForm.from_my_career };
    const r = editingS === 'new' ? await supabase.from('top_scorers').insert(payload) : await supabase.from('top_scorers').update(payload).eq('id', editingS!);
    if (r.error) { alert(r.error.message); return; }
    setSForm({ year: new Date().getFullYear(), goals: 0 }); setEditingS(null); load();
  }
  async function delScorer(sid: string) { if (!confirm('Delete?')) return; await supabase.from('top_scorers').delete().eq('id', sid); load(); }

  if (loading) return <Loading />;
  if (!t) return <div className="text-slate-500">Tournament not found.</div>;

  const ChampForm = (
    <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded p-3 mb-3 grid gap-2 sm:grid-cols-3">
      <input value={cForm.team_name ?? ''} onChange={(e) => setCForm({ ...cForm, team_name: e.target.value })} placeholder="Team" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1.5 text-sm" />
      <input value={cForm.team_country ?? ''} onChange={(e) => setCForm({ ...cForm, team_country: e.target.value })} placeholder="Country" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1.5 text-sm" />
      <div className="flex gap-1"><input type="color" value={cForm.team_color ?? '#1e3a8a'} onChange={(e) => setCForm({ ...cForm, team_color: e.target.value })} className="w-10 h-9 rounded border border-slate-300 dark:border-slate-700" title="BG" /><input type="color" value={cForm.team_text_color ?? '#ffffff'} onChange={(e) => setCForm({ ...cForm, team_text_color: e.target.value })} className="w-10 h-9 rounded border border-slate-300 dark:border-slate-700" title="Text" /></div>
      <input type="number" value={cForm.wins ?? 0} onChange={(e) => setCForm({ ...cForm, wins: Number(e.target.value) })} placeholder="Wins" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1.5 text-sm" />
      <input type="number" value={cForm.runners_up ?? 0} onChange={(e) => setCForm({ ...cForm, runners_up: Number(e.target.value) })} placeholder="Runners-up" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1.5 text-sm" />
      <div></div>
      <textarea rows={2} value={cForm.years_won ?? ''} onChange={(e) => setCForm({ ...cForm, years_won: e.target.value })} placeholder="Winning seasons (e.g. 1930-31, 1931-32, …)" className="sm:col-span-3 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1.5 text-sm" />
      <textarea rows={2} value={cForm.years_runner_up ?? ''} onChange={(e) => setCForm({ ...cForm, years_runner_up: e.target.value })} placeholder="Runner-up seasons" className="sm:col-span-3 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1.5 text-sm" />
      <label className="sm:col-span-3 flex items-center gap-2 text-sm"><input type="checkbox" checked={!!cForm.from_my_career} onChange={(e) => setCForm({ ...cForm, from_my_career: e.target.checked })} /> ⭐ Has entries from my career</label>
      <div className="sm:col-span-3 flex justify-end gap-2"><button onClick={cancelC} className="text-sm text-slate-500 px-3">Cancel</button><button onClick={saveChamp} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">{editingC === 'new' ? 'Save' : 'Update'}</button></div>
    </div>
  );

  return (
    <div>
      <Link to="/" className="text-slate-500 hover:text-emerald-600 text-sm">← Tournaments</Link>
      <div className="mt-3 mb-6 rounded-xl p-5 flex items-center gap-4" style={{ background: t.color ?? '#1e3a8a', color: t.text_color ?? '#ffffff' }}>
        <div className="w-14 h-14 rounded-lg bg-white/10 flex items-center justify-center overflow-hidden shrink-0">
          {t.logo_url ? <img src={t.logo_url} alt="" className="w-full h-full object-contain p-1" onError={(e) => (e.currentTarget as HTMLImageElement).style.display = 'none'} /> : <span className="font-bold">{t.name.slice(0, 3).toUpperCase()}</span>}
        </div>
        <div><div className="text-2xl font-black uppercase tracking-tight">{t.name}</div>{t.country && <div className="text-sm opacity-80">{t.country}</div>}</div>
      </div>

      <section className="mb-8">
        <div className="flex items-center justify-between mb-2">
          <div className="text-xs uppercase font-semibold text-slate-500">🏆 Champions</div>
          <button onClick={openNewChamp} className="text-xs bg-emerald-600 text-white rounded px-3 py-1">+ Add team</button>
        </div>
        {editingC === 'new' && ChampForm}
        <div className="border border-slate-200 dark:border-slate-800 rounded overflow-hidden bg-white dark:bg-slate-900">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 dark:bg-slate-800 text-slate-500 text-xs uppercase"><tr><th className="text-left px-3 py-2">Team</th><th className="text-right px-3 py-2 w-14">W</th><th className="text-right px-3 py-2 w-14">2nd</th><th className="text-left px-3 py-2">Winning seasons</th><th className="text-left px-3 py-2">Runner-up seasons</th><th className="w-16"></th></tr></thead>
            <tbody>{champs.length === 0 ? <tr><td colSpan={6} className="text-center text-slate-400 py-6">No data yet.</td></tr> : champs.map((c) => editingC === c.id ? (
              <tr key={c.id}><td colSpan={6} className="p-0">{ChampForm}</td></tr>
            ) : (
              <tr key={c.id} className="group border-t border-slate-200 dark:border-slate-800">
                <td className="px-3 py-2 font-bold uppercase" style={{ background: c.team_color ?? undefined, color: c.team_text_color ?? '#fff' }}>{c.team_name} {c.from_my_career && '⭐'}</td>
                <td className="px-3 py-2 text-right font-semibold">{c.wins}</td>
                <td className="px-3 py-2 text-right">{c.runners_up}</td>
                <td className="px-3 py-2 text-xs text-slate-600 dark:text-slate-300 max-w-xs">{c.years_won || '—'}</td>
                <td className="px-3 py-2 text-xs text-slate-600 dark:text-slate-300 max-w-xs">{c.years_runner_up || '—'}</td>
                <td className="px-3 py-2 opacity-0 group-hover:opacity-100 whitespace-nowrap text-right">
                  <button onClick={() => openEditChamp(c)} className="text-slate-400 hover:text-emerald-500 text-sm mr-2">✎</button>
                  <button onClick={() => delChamp(c.id)} className="text-slate-400 hover:text-red-500 text-sm">×</button>
                </td>
              </tr>
            ))}</tbody>
          </table>
        </div>
      </section>

      {/* Standings */}
      <section className="mb-8">
        <div className="flex items-center justify-between mb-2 flex-wrap gap-2">
          <div className="text-xs uppercase font-semibold text-slate-500">📊 Standings por temporada</div>
          <div className="flex items-center gap-2">
            {availableYears.length > 0 && (
              <select value={standingsYear} onChange={(e) => setStandingsYear(Number(e.target.value))} className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-xs">
                {availableYears.map((y) => <option key={y} value={y}>{y - 1}-{String(y).slice(-2)}</option>)}
              </select>
            )}
            <input type="number" value={standingsYear} onChange={(e) => setStandingsYear(Number(e.target.value))} placeholder="Año fin" className="w-24 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-xs" title="Año fin de temporada (ej: 2027 para 2026-27)" />
            <button onClick={() => setShowEdit(true)} className="text-xs bg-emerald-600 text-white rounded px-3 py-1">✎ Editar manual</button>
            <button onClick={() => setShowImport(true)} className="text-xs border border-slate-300 dark:border-slate-700 hover:border-emerald-400 rounded px-3 py-1" title="OCR aún no muy preciso para FIFA">📷 Foto</button>
            {standingsForYear.length > 0 && <button onClick={delStandings} className="text-xs text-slate-400 hover:text-red-500 px-2">🗑</button>}
          </div>
        </div>
        {standingsForYear.length === 0 ? (
          <div className="border border-dashed border-slate-300 dark:border-slate-700 rounded p-6 text-center text-sm text-slate-500">
            No hay tabla para {standingsYear - 1}-{String(standingsYear).slice(-2)}. Sube una foto o captura la de tu juego.
          </div>
        ) : (
          <div className="border border-slate-200 dark:border-slate-800 rounded overflow-hidden bg-white dark:bg-slate-900 overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 dark:bg-slate-800 text-slate-500 text-xs uppercase">
                <tr>
                  <th className="w-10 px-3 py-2">#</th>
                  <th className="text-left px-3 py-2">Equipo</th>
                  <th className="text-center px-2 w-10">PJ</th>
                  <th className="text-center px-2 w-10">G</th>
                  <th className="text-center px-2 w-10">E</th>
                  <th className="text-center px-2 w-10">P</th>
                  <th className="text-center px-2 w-10">GF</th>
                  <th className="text-center px-2 w-10">GC</th>
                  <th className="text-right px-3 py-2 w-14">Pts</th>
                </tr>
              </thead>
              <tbody>{standingsForYear.map((r) => (
                <tr key={r.id} className={`border-t border-slate-100 dark:border-slate-800 ${r.position === 1 ? 'bg-amber-50 dark:bg-amber-900/20' : ''}`}>
                  <td className="px-3 py-1.5 font-mono text-slate-500">{r.position ?? ''}</td>
                  <td className="px-3 py-1.5 font-medium">{r.team_name}{r.position === 1 && <span className="ml-2 text-amber-600 text-xs font-bold">🏆</span>}</td>
                  <td className="px-2 text-center">{r.played ?? '—'}</td>
                  <td className="px-2 text-center">{r.wins ?? '—'}</td>
                  <td className="px-2 text-center">{r.draws ?? '—'}</td>
                  <td className="px-2 text-center">{r.losses ?? '—'}</td>
                  <td className="px-2 text-center">{r.goals_for ?? '—'}</td>
                  <td className="px-2 text-center">{r.goals_against ?? '—'}</td>
                  <td className="px-3 py-1.5 text-right font-bold">{r.points ?? '—'}</td>
                </tr>
              ))}</tbody>
            </table>
          </div>
        )}
      </section>

      {showImport && id && <StandingsImport tournamentId={id} yearEnd={standingsYear} catalog={catalog} onClose={() => setShowImport(false)} onSaved={load} />}
      {showEdit && id && (
        <StandingsImport
          tournamentId={id}
          yearEnd={standingsYear}
          catalog={catalog}
          initialRows={standingsForYear.length > 0
            ? standingsForYear.map((s) => ({ position: s.position, team: s.team_name, played: s.played, wins: s.wins, draws: s.draws, losses: s.losses, gf: s.goals_for, ga: s.goals_against, points: s.points }))
            : []}
          onClose={() => setShowEdit(false)}
          onSaved={load}
        />
      )}

      {t.has_top_scorer && (
        <section>
          <div className="flex items-center justify-between mb-2">
            <div className="text-xs uppercase font-semibold text-slate-500">⚽ Top scorer in one season</div>
            <button onClick={() => { setSForm({ year: new Date().getFullYear(), goals: 0 }); setEditingS('new'); }} className="text-xs bg-emerald-600 text-white rounded px-3 py-1">+ Add scorer</button>
          </div>
          {editingS === 'new' && (
            <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded p-3 mb-3 grid gap-2 sm:grid-cols-3">
              <input type="number" value={sForm.year ?? ''} onChange={(e) => setSForm({ ...sForm, year: Number(e.target.value) })} placeholder="Season end year (e.g. 2015 for 2014-15)" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
              <input value={sForm.player_name ?? ''} onChange={(e) => setSForm({ ...sForm, player_name: e.target.value })} placeholder="Player" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
              <input type="number" value={sForm.goals ?? ''} onChange={(e) => setSForm({ ...sForm, goals: Number(e.target.value) })} placeholder="Goals" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
              <input value={sForm.nationality ?? ''} onChange={(e) => setSForm({ ...sForm, nationality: e.target.value })} placeholder="Nationality" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
              <input value={sForm.team ?? ''} onChange={(e) => setSForm({ ...sForm, team: e.target.value })} placeholder="Team" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
              <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={!!sForm.from_my_career} onChange={(e) => setSForm({ ...sForm, from_my_career: e.target.checked })} /> ⭐ My career</label>
              <div className="sm:col-span-3 flex justify-end gap-2"><button onClick={() => setEditingS(null)} className="text-sm text-slate-500 px-3">Cancel</button><button onClick={saveScorer} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">Save</button></div>
            </div>
          )}
          <div className="border border-slate-200 dark:border-slate-800 rounded overflow-hidden bg-white dark:bg-slate-900">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 dark:bg-slate-800 text-slate-500 text-xs uppercase"><tr><th className="w-10 px-3 py-2">#</th><th className="text-left px-3 py-2">Player</th><th className="text-right px-3 py-2">Goals</th><th className="text-left px-3 py-2">Nat</th><th className="text-left px-3 py-2">Season</th><th className="text-left px-3 py-2">Team</th><th className="w-10"></th></tr></thead>
              <tbody>{scorers.length === 0 ? <tr><td colSpan={7} className="text-center text-slate-400 py-6">No data yet.</td></tr> : scorers.map((s, i) => (
                <tr key={s.id} className="group border-t border-slate-200 dark:border-slate-800">
                  <td className="px-3 py-2 text-slate-400 font-mono">{i + 1}</td>
                  <td className="px-3 py-2 font-medium">
                    {s.player_name}
                    {scorerAppearance[s.id] > 1 && (
                      <span className="ml-1 text-amber-600 font-bold" title={`${scorerAppearance[s.id]}a vez goleador`}>{'*'.repeat(scorerAppearance[s.id] - 1)}</span>
                    )}
                    {s.from_my_career && ' ⭐'}
                  </td>
                  <td className="px-3 py-2 text-right font-semibold">{s.goals}</td>
                  <td className="px-3 py-2">{s.nationality ?? '—'}</td>
                  <td className="px-3 py-2 font-mono">{s.year - 1}-{String(s.year).slice(-2)}</td>
                  <td className="px-3 py-2">{s.team ?? '—'}</td>
                  <td className="px-3 py-2 opacity-0 group-hover:opacity-100"><button onClick={() => delScorer(s.id)} className="text-slate-400 hover:text-red-500 text-sm">×</button></td>
                </tr>
              ))}</tbody>
            </table>
          </div>
        </section>
      )}
    </div>
  );
}
