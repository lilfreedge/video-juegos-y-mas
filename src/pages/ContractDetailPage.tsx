import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import Loading from '../components/Loading';

interface Contract { id: string; club_name: string; club_color: string | null; club_text_color: string | null; club_logo_url: string | null; start_year: number; start_month: number | null; end_year: number | null; end_month: number | null; }
interface Season { id: string; contract_id: string; label: string; start_year: number; end_year: number; }

export default function ContractDetailPage() {
  const { id } = useParams();
  const [c, setC] = useState<Contract | null>(null);
  const [seasons, setSeasons] = useState<Season[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [label, setLabel] = useState('');

  async function load() {
    if (!id) return;
    setLoading(true);
    const [{ data: cd }, { data: sd }] = await Promise.all([
      supabase.from('contracts').select('*').eq('id', id).maybeSingle(),
      supabase.from('seasons').select('*').eq('contract_id', id).order('start_year', { ascending: true }),
    ]);
    setC(cd as Contract | null); setSeasons((sd ?? []) as Season[]);
    // Auto-suggest next season label from last season or contract start.
    // Falls back to parsing the label if end_year is corrupt (< 1900).
    const yearFromSeason = (s: Season): number => {
      if (s.end_year >= 1900) return s.end_year;
      const m = s.label.match(/(\d{4})/);
      return m ? Number(m[1]) + 1 : new Date().getFullYear();
    };
    if (sd && sd.length) {
      const y = yearFromSeason(sd[sd.length - 1] as Season);
      setLabel(`Season ${y}-${String((y + 1) % 100).padStart(2, '0')}`);
    } else if (cd) {
      const y = (cd as Contract).start_year;
      setLabel(`Season ${y}-${String((y + 1) % 100).padStart(2, '0')}`);
    }
    setLoading(false);
  }
  useEffect(() => { load(); }, [id]);

  // Parse "Season YYYY-YY" or "YYYY-YY" or "YYYY-YYYY" → start year
  function parseStartYear(lbl: string): number | null {
    const m = lbl.match(/(\d{4})\s*-\s*(\d{2,4})/);
    if (!m) return null;
    return Number(m[1]);
  }

  async function addSeason() {
    if (!id || !label.trim()) return;
    const startYear = parseStartYear(label);
    if (!startYear) { alert('Label must include a year like "2026-27" or "Season 2026-27"'); return; }
    const { error } = await supabase.from('seasons').insert({ contract_id: id, label: label.trim(), start_year: startYear, end_year: startYear + 1 });
    if (error) { alert(error.message); return; }
    setShowAdd(false); load();
  }
  async function delSeason(sid: string) { if (!confirm('Delete season + all data?')) return; await supabase.from('seasons').delete().eq('id', sid); load(); }
  async function cloneToNext(prev: Season) {
    // Use end_year if valid; otherwise parse the label
    const nextStart = prev.end_year >= 1900
      ? prev.end_year
      : (() => { const m = prev.label.match(/(\d{4})/); return m ? Number(m[1]) + 1 : new Date().getFullYear(); })();
    const newLabel = `Season ${nextStart}-${String((nextStart + 1) % 100).padStart(2, '0')}`;
    const { data: created, error } = await supabase.from('seasons').insert({ contract_id: id, label: newLabel, start_year: nextStart, end_year: nextStart + 1 }).select().maybeSingle();
    if (error || !created) { alert(error?.message ?? 'error'); return; }
    const { data: prevSquad } = await supabase.from('squad_players').select('*').eq('season_id', prev.id);
    if (prevSquad?.length) {
      const rows = prevSquad.filter((p: any) => p.status !== 'sold').map((p: any) => ({ season_id: created.id, jersey: p.jersey, position: p.position, name: p.name, age: p.age != null ? p.age + 1 : null, overall: p.overall, nationality: p.nationality, status: 'squad' }));
      await supabase.from('squad_players').insert(rows);
    }
    load();
  }

  if (loading) return <Loading />;
  if (!c) return <div className="text-slate-500">Contract not found.</div>;

  return (
    <div>
      <Link to="/career" className="text-slate-500 hover:text-emerald-600 text-sm">← Career</Link>
      <div className="mt-3 mb-5 rounded-xl p-5 flex items-center gap-4" style={{ background: c.club_color ?? '#1e3a8a', color: c.club_text_color ?? '#ffffff' }}>
        <div className="w-14 h-14 rounded-lg bg-white/10 flex items-center justify-center overflow-hidden shrink-0">
          {c.club_logo_url ? <img src={c.club_logo_url} alt="" className="w-full h-full object-contain p-1" /> : <span className="font-bold">{c.club_name.slice(0, 3).toUpperCase()}</span>}
        </div>
        <div className="flex-1"><div className="text-2xl font-black uppercase">{c.club_name}</div></div>
      </div>

      <div className="flex items-center justify-between mb-3">
        <div className="text-xs uppercase font-semibold text-slate-500">Seasons</div>
        <button onClick={() => setShowAdd((v) => !v)} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">+ New season</button>
      </div>
      {showAdd && (
        <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded p-3 mb-3">
          <input autoFocus value={label} onChange={(e) => setLabel(e.target.value)} placeholder="Season 2026-27" className="w-full bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
          <div className="flex justify-end gap-2 mt-2"><button onClick={() => setShowAdd(false)} className="text-sm text-slate-500 px-3">Cancel</button><button onClick={addSeason} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">Save</button></div>
        </div>
      )}
      {seasons.length === 0 ? (
        <div className="text-slate-500 border border-dashed border-slate-300 rounded p-8 text-center">No seasons yet.</div>
      ) : (
        <div className="grid gap-2">{seasons.map((s, i) => (
          <div key={s.id} className="flex items-center gap-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded p-3 hover:border-emerald-400 transition">
            <Link to={`/career/season/${s.id}`} className="flex-1 min-w-0">
              <div className="font-bold">{s.label}</div>
            </Link>
            {i === seasons.length - 1 && <button onClick={() => cloneToNext(s)} className="text-xs border border-slate-300 dark:border-slate-700 hover:border-emerald-400 rounded px-2 py-1" title="Clone to next season">↻ Clone next</button>}
            <button onClick={() => delSeason(s.id)} className="text-slate-400 hover:text-red-500 text-sm">×</button>
          </div>
        ))}</div>
      )}
    </div>
  );
}
