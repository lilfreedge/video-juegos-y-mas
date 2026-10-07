import { useEffect, useMemo, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { AlertCircle } from 'lucide-react';
import { supabase } from '../lib/supabase';
import Loading from '../components/Loading';

interface Tournament {
  id: string;
  name: string;
  country: string | null;
  logo_url: string | null;
  has_top_scorer: boolean;
  color: string | null;
  text_color: string | null;
  sort_order: number | null;
  division: number | null;
}

// Extract latest END year from a years_won / years_runner_up string
// Handles "2024-25" (→ 2025), "2024" (→ 2024), comma-separated lists
function latestYear(yearsText: string | null): number | null {
  if (!yearsText) return null;
  let max = 0;
  const re = /(\d{4})(?:-(\d{2,4}))?/g;
  let m: RegExpExecArray | null;
  while ((m = re.exec(yearsText)) !== null) {
    const start = Number(m[1]);
    let end = start;
    if (m[2]) {
      if (m[2].length === 2) {
        const twoDigit = Number(m[2]);
        end = Math.floor(start / 100) * 100 + twoDigit;
        if (end < start) end += 100;
      } else {
        end = Number(m[2]);
      }
    }
    if (end > max) max = end;
  }
  return max > 0 ? max : null;
}

const COUNTRY_FLAG: Record<string, string> = {
  France: '🇫🇷', Spain: '🇪🇸', England: '🏴󠁧󠁢󠁥󠁮󠁧󠁿', Italy: '🇮🇹', Germany: '🇩🇪',
  Netherlands: '🇳🇱', Portugal: '🇵🇹', Belgium: '🇧🇪', Scotland: '🏴󠁧󠁢󠁳󠁣󠁴󠁿',
};
const INTL_LABEL = '🌍 International';

export default function TournamentsPage() {
  const [rows, setRows] = useState<Tournament[]>([]);
  const [latestByTournament, setLatestByTournament] = useState<Record<string, number>>({});
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [showAdd, setShowAdd] = useState(false);
  const [f, setF] = useState<Partial<Tournament>>({ has_top_scorer: false });
  const dragId = useRef<string | null>(null);

  async function load() {
    setLoading(true);
    try {
      const [{ data: toursRows, error: toursErr }, { data: champs }] = await Promise.all([
        supabase.from('tournaments').select('*').order('sort_order', { ascending: true }).order('division', { ascending: true }),
        supabase.from('champions').select('tournament_id, years_won'),
      ]);
      if (toursErr) throw toursErr;
      setRows((toursRows ?? []) as Tournament[]);
      // For each tournament, compute the latest year any team has won (end year)
      const latest: Record<string, number> = {};
      for (const c of ((champs ?? []) as { tournament_id: string; years_won: string | null }[])) {
        const y = latestYear(c.years_won);
        if (y !== null && (latest[c.tournament_id] ?? 0) < y) latest[c.tournament_id] = y;
      }
      setLatestByTournament(latest);
    } catch (e: any) { setErr(e.message ?? String(e)); }
    setLoading(false);
  }
  useEffect(() => { load(); }, []);

  // Global max year across ALL tournaments — the "current era" the user is tracking
  const globalMaxYear = useMemo(() => {
    const vals = Object.values(latestByTournament);
    return vals.length > 0 ? Math.max(...vals) : 0;
  }, [latestByTournament]);

  const grouped = useMemo(() => {
    const map = new Map<string, Tournament[]>();
    for (const r of rows) {
      const key = r.country ?? INTL_LABEL;
      if (!map.has(key)) map.set(key, []);
      map.get(key)!.push(r);
    }
    // Sort each group by division then sort_order
    for (const list of map.values()) {
      list.sort((a, b) => (a.division ?? 99) - (b.division ?? 99) || (a.sort_order ?? 999) - (b.sort_order ?? 999));
    }
    // Order: International last
    const entries = Array.from(map.entries());
    entries.sort((a, b) => {
      if (a[0] === INTL_LABEL) return 1;
      if (b[0] === INTL_LABEL) return -1;
      return a[0].localeCompare(b[0]);
    });
    return entries;
  }, [rows]);

  function openEdit(t: Tournament) { setF({ ...t }); setEditingId(t.id); }
  function openNew() { setF({ has_top_scorer: false, color: '#1e3a8a', text_color: '#ffffff', division: 1 }); setShowAdd(true); setEditingId(null); }
  function cancel() { setShowAdd(false); setEditingId(null); setF({}); }

  async function save() {
    if (!f.name?.trim()) return;
    const payload: any = {
      name: f.name.trim(),
      country: f.country || null,
      logo_url: f.logo_url || null,
      has_top_scorer: !!f.has_top_scorer,
      color: f.color || null,
      text_color: f.text_color || null,
      division: f.division ?? null,
    };
    if (editingId) {
      const { error } = await supabase.from('tournaments').update(payload).eq('id', editingId);
      if (error) { alert(error.message); return; }
    } else {
      const maxOrder = rows.reduce((m, r) => Math.max(m, r.sort_order ?? 0), 0);
      const { error } = await supabase.from('tournaments').insert({ ...payload, sort_order: maxOrder + 1 });
      if (error) { alert(error.message); return; }
    }
    cancel(); load();
  }
  async function del(t: Tournament) {
    if (!confirm(`Delete ${t.name}?`)) return;
    await supabase.from('tournaments').delete().eq('id', t.id); load();
  }
  async function onDrop(targetId: string) {
    const sourceId = dragId.current; dragId.current = null;
    if (!sourceId || sourceId === targetId) return;
    const src = rows.findIndex((r) => r.id === sourceId);
    const tgt = rows.findIndex((r) => r.id === targetId);
    if (src < 0 || tgt < 0) return;
    const next = [...rows];
    const [moved] = next.splice(src, 1);
    next.splice(tgt, 0, moved);
    setRows(next);
    await Promise.all(next.map((r, i) => supabase.from('tournaments').update({ sort_order: i + 1 }).eq('id', r.id)));
  }

  if (loading) return <Loading />;

  const Form = (
    <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded-lg p-4 mb-4 grid gap-2 sm:grid-cols-2">
      <input autoFocus value={f.name ?? ''} onChange={(e) => setF({ ...f, name: e.target.value })} placeholder="Tournament name" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
      <input value={f.country ?? ''} onChange={(e) => setF({ ...f, country: e.target.value })} placeholder="Country (empty = International)" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
      <input value={f.logo_url ?? ''} onChange={(e) => setF({ ...f, logo_url: e.target.value })} placeholder="Logo URL" className="sm:col-span-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
      <div className="flex gap-2 items-center"><input type="number" value={f.division ?? ''} onChange={(e) => setF({ ...f, division: e.target.value ? Number(e.target.value) : null })} placeholder="Division (1,2,3…)" className="flex-1 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" /></div>
      <div className="flex gap-1"><input type="color" value={f.color ?? '#1e3a8a'} onChange={(e) => setF({ ...f, color: e.target.value })} className="w-10 h-9 rounded border border-slate-300 dark:border-slate-700" title="BG" /><input type="color" value={f.text_color ?? '#ffffff'} onChange={(e) => setF({ ...f, text_color: e.target.value })} className="w-10 h-9 rounded border border-slate-300 dark:border-slate-700" title="Text" /></div>
      <label className="sm:col-span-2 flex items-center gap-2 text-sm"><input type="checkbox" checked={!!f.has_top_scorer} onChange={(e) => setF({ ...f, has_top_scorer: e.target.checked })} /> Has top scorer table</label>
      <div className="sm:col-span-2 flex justify-end gap-2"><button onClick={cancel} className="text-sm text-slate-500 px-3">Cancel</button><button onClick={save} className="bg-emerald-600 text-white rounded px-4 py-2 text-sm">{editingId ? 'Update' : 'Save'}</button></div>
    </div>
  );

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-2xl font-bold">Tournaments</h1>
        <button onClick={openNew} className="bg-emerald-600 hover:bg-emerald-500 text-white rounded px-4 py-2 text-sm">+ Add</button>
      </div>
      {err && <div className="mb-3 p-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded">{err}</div>}
      {showAdd && Form}

      {grouped.length === 0 ? (
        <div className="text-slate-500 border border-dashed border-slate-300 rounded p-10 text-center">No tournaments yet.</div>
      ) : (
        <div className="space-y-6">
          {grouped.map(([country, list]) => (
            <div key={country}>
              <div className="text-sm font-bold text-slate-600 dark:text-slate-300 mb-2 uppercase tracking-wide">
                {country === INTL_LABEL ? INTL_LABEL : `${COUNTRY_FLAG[country] ?? ''} ${country}`}
              </div>
              <div className="grid gap-2 sm:grid-cols-2">
                {list.map((t) => editingId === t.id ? (
                  <div key={t.id} className="sm:col-span-2">{Form}</div>
                ) : (
                  <div key={t.id}
                    draggable
                    onDragStart={() => { dragId.current = t.id; }}
                    onDragOver={(e) => e.preventDefault()}
                    onDrop={() => onDrop(t.id)}
                    className="group relative bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-emerald-400 rounded-lg overflow-hidden cursor-move">
                    <Link to={`/tournament/${t.id}`} className="block p-3 flex items-center gap-3">
                      <div className="w-10 h-10 rounded flex items-center justify-center overflow-hidden shrink-0" style={{ background: t.color ?? '#1e3a8a' }}>
                        {t.logo_url ? <img src={t.logo_url} alt="" className="w-full h-full object-contain p-1" onError={(e) => (e.currentTarget as HTMLImageElement).style.display = 'none'} /> : <span className="font-bold text-white text-xs">{t.name.slice(0, 3).toUpperCase()}</span>}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="font-medium truncate flex items-center gap-2">
                          {t.name}
                          {t.division && <span className="text-[10px] font-bold text-slate-500 bg-slate-100 dark:bg-slate-800 rounded px-1.5 py-0.5">D{t.division}</span>}
                          {globalMaxYear > 0 && (latestByTournament[t.id] ?? 0) < globalMaxYear && (
                            <span title={`Falta campeón ${globalMaxYear - 1}-${String(globalMaxYear).slice(-2)}`} className="inline-flex items-center gap-1 text-[10px] font-semibold text-amber-700 bg-amber-100 dark:bg-amber-900/40 dark:text-amber-300 rounded px-1.5 py-0.5">
                              <AlertCircle className="w-3 h-3" /> {globalMaxYear - 1}-{String(globalMaxYear).slice(-2)}
                            </span>
                          )}
                        </div>
                        {t.has_top_scorer && <div className="text-[10px] text-emerald-700">⚽ scorers</div>}
                      </div>
                    </Link>
                    <div className="absolute top-2 right-2 flex gap-1 opacity-0 group-hover:opacity-100 transition">
                      <button onClick={(e) => { e.preventDefault(); openEdit(t); }} className="w-6 h-6 rounded-full bg-black/60 text-white flex items-center justify-center text-xs">✎</button>
                      <button onClick={(e) => { e.preventDefault(); del(t); }} className="w-6 h-6 rounded-full bg-black/60 text-white flex items-center justify-center text-sm">×</button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
