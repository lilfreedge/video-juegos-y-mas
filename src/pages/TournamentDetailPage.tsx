import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { supabase } from '../lib/supabase';

interface Tournament { id: string; name: string; country: string | null; logo_url: string | null; has_top_scorer: boolean; color: string | null; text_color: string | null; }
interface Champion { id: string; tournament_id: string; year: number; champion_team: string; champion_color: string | null; champion_text_color: string | null; runner_up_team: string | null; from_my_career: boolean; }
interface Scorer { id: string; tournament_id: string; year: number; player_name: string; nationality: string | null; team: string | null; goals: number; from_my_career: boolean; }

export default function TournamentDetailPage() {
  const { id } = useParams();
  const [t, setT] = useState<Tournament | null>(null);
  const [champs, setChamps] = useState<Champion[]>([]);
  const [scorers, setScorers] = useState<Scorer[]>([]);
  const [loading, setLoading] = useState(true);
  const [cForm, setCForm] = useState<Partial<Champion>>({ year: new Date().getFullYear() });
  const [sForm, setSForm] = useState<Partial<Scorer>>({ year: new Date().getFullYear(), goals: 0 });
  const [showC, setShowC] = useState(false);
  const [showS, setShowS] = useState(false);

  async function load() {
    if (!id) return;
    setLoading(true);
    const [{ data: td }, { data: cd }, { data: sd }] = await Promise.all([
      supabase.from('tournaments').select('*').eq('id', id).maybeSingle(),
      supabase.from('champions').select('*').eq('tournament_id', id).order('year', { ascending: false }),
      supabase.from('top_scorers').select('*').eq('tournament_id', id).order('year', { ascending: false }).order('goals', { ascending: false }),
    ]);
    setT(td as Tournament | null); setChamps((cd ?? []) as Champion[]); setScorers((sd ?? []) as Scorer[]); setLoading(false);
  }
  useEffect(() => { load(); }, [id]);

  async function saveChamp() {
    if (!id || !cForm.year || !cForm.champion_team) return;
    const { error } = await supabase.from('champions').insert({ tournament_id: id, year: Number(cForm.year), champion_team: cForm.champion_team, champion_color: cForm.champion_color || null, runner_up_team: cForm.runner_up_team || null, from_my_career: !!cForm.from_my_career });
    if (error) { alert(error.message); return; }
    setCForm({ year: new Date().getFullYear() }); setShowC(false); load();
  }
  async function saveScorer() {
    if (!id || !sForm.year || !sForm.player_name) return;
    const { error } = await supabase.from('top_scorers').insert({ tournament_id: id, year: Number(sForm.year), player_name: sForm.player_name, nationality: sForm.nationality || null, team: sForm.team || null, goals: Number(sForm.goals ?? 0), from_my_career: !!sForm.from_my_career });
    if (error) { alert(error.message); return; }
    setSForm({ year: new Date().getFullYear(), goals: 0 }); setShowS(false); load();
  }
  async function delChamp(cid: string) { if (!confirm('Delete?')) return; await supabase.from('champions').delete().eq('id', cid); load(); }
  async function delScorer(sid: string) { if (!confirm('Delete?')) return; await supabase.from('top_scorers').delete().eq('id', sid); load(); }

  if (loading) return <div className="text-slate-500 text-sm py-10 text-center">Loading…</div>;
  if (!t) return <div className="text-slate-500">Tournament not found.</div>;

  const season = (y: number) => `${y}-${String((y + 1) % 100).padStart(2, '0')}`;

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
          <button onClick={() => setShowC((v) => !v)} className="text-xs bg-emerald-600 text-white rounded px-3 py-1">+ Add year</button>
        </div>
        {showC && (
          <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded p-3 mb-3 grid gap-2 sm:grid-cols-3">
            <input type="number" value={cForm.year ?? ''} onChange={(e) => setCForm({ ...cForm, year: Number(e.target.value) })} placeholder="End year" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
            <input value={cForm.champion_team ?? ''} onChange={(e) => setCForm({ ...cForm, champion_team: e.target.value })} placeholder="Champion" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
            <input type="color" value={cForm.champion_color ?? '#1e3a8a'} onChange={(e) => setCForm({ ...cForm, champion_color: e.target.value })} className="h-9 rounded border border-slate-300 dark:border-slate-700" />
            <input value={cForm.runner_up_team ?? ''} onChange={(e) => setCForm({ ...cForm, runner_up_team: e.target.value })} placeholder="Runner-up" className="sm:col-span-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
            <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={!!cForm.from_my_career} onChange={(e) => setCForm({ ...cForm, from_my_career: e.target.checked })} /> ⭐ My career</label>
            <div className="sm:col-span-3 flex justify-end gap-2"><button onClick={() => setShowC(false)} className="text-sm text-slate-500 px-3">Cancel</button><button onClick={saveChamp} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">Save</button></div>
          </div>
        )}
        <div className="border border-slate-200 dark:border-slate-800 rounded overflow-hidden bg-white dark:bg-slate-900">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 dark:bg-slate-800 text-slate-500 text-xs uppercase"><tr><th className="text-left px-3 py-2">Year</th><th className="text-left px-3 py-2">Champion</th><th className="text-left px-3 py-2">Runner-up</th><th className="w-10"></th></tr></thead>
            <tbody>{champs.length === 0 ? <tr><td colSpan={4} className="text-center text-slate-400 py-6">No data yet.</td></tr> : champs.map((c) => (
              <tr key={c.id} className="group border-t border-slate-200 dark:border-slate-800">
                <td className="px-3 py-2 font-mono">{season(c.year)} {c.from_my_career && '⭐'}</td>
                <td className="px-3 py-2 font-bold uppercase" style={{ background: c.champion_color ?? undefined, color: c.champion_text_color ?? '#fff' }}>{c.champion_team}</td>
                <td className="px-3 py-2">{c.runner_up_team ?? '—'}</td>
                <td className="px-3 py-2 opacity-0 group-hover:opacity-100"><button onClick={() => delChamp(c.id)} className="text-slate-400 hover:text-red-500 text-sm">×</button></td>
              </tr>
            ))}</tbody>
          </table>
        </div>
      </section>

      {t.has_top_scorer && (
        <section>
          <div className="flex items-center justify-between mb-2">
            <div className="text-xs uppercase font-semibold text-slate-500">⚽ Top scorer in one season</div>
            <button onClick={() => setShowS((v) => !v)} className="text-xs bg-emerald-600 text-white rounded px-3 py-1">+ Add scorer</button>
          </div>
          {showS && (
            <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded p-3 mb-3 grid gap-2 sm:grid-cols-3">
              <input type="number" value={sForm.year ?? ''} onChange={(e) => setSForm({ ...sForm, year: Number(e.target.value) })} placeholder="End year" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
              <input value={sForm.player_name ?? ''} onChange={(e) => setSForm({ ...sForm, player_name: e.target.value })} placeholder="Player" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
              <input type="number" value={sForm.goals ?? ''} onChange={(e) => setSForm({ ...sForm, goals: Number(e.target.value) })} placeholder="Goals" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
              <input value={sForm.nationality ?? ''} onChange={(e) => setSForm({ ...sForm, nationality: e.target.value })} placeholder="Nationality" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
              <input value={sForm.team ?? ''} onChange={(e) => setSForm({ ...sForm, team: e.target.value })} placeholder="Team" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
              <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={!!sForm.from_my_career} onChange={(e) => setSForm({ ...sForm, from_my_career: e.target.checked })} /> ⭐ My career</label>
              <div className="sm:col-span-3 flex justify-end gap-2"><button onClick={() => setShowS(false)} className="text-sm text-slate-500 px-3">Cancel</button><button onClick={saveScorer} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">Save</button></div>
            </div>
          )}
          <div className="border border-slate-200 dark:border-slate-800 rounded overflow-hidden bg-white dark:bg-slate-900">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 dark:bg-slate-800 text-slate-500 text-xs uppercase"><tr><th className="w-10 px-3 py-2">#</th><th className="text-left px-3 py-2">Player</th><th className="text-right px-3 py-2">Goals</th><th className="text-left px-3 py-2">Nationality</th><th className="text-left px-3 py-2">Season</th><th className="text-left px-3 py-2">Team</th><th className="w-10"></th></tr></thead>
              <tbody>{scorers.length === 0 ? <tr><td colSpan={7} className="text-center text-slate-400 py-6">No data yet.</td></tr> : scorers.map((s, i) => (
                <tr key={s.id} className="group border-t border-slate-200 dark:border-slate-800">
                  <td className="px-3 py-2 text-slate-400 font-mono">{i + 1}</td>
                  <td className="px-3 py-2 font-medium">{s.player_name} {s.from_my_career && '⭐'}</td>
                  <td className="px-3 py-2 text-right font-semibold">{s.goals}</td>
                  <td className="px-3 py-2">{s.nationality ?? '—'}</td>
                  <td className="px-3 py-2 font-mono">{season(s.year)}</td>
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
