import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import Loading from '../components/Loading';

interface Tournament { id: string; name: string; country: string | null; logo_url: string | null; has_top_scorer: boolean; color: string | null; text_color: string | null; }
interface Champion { id: string; tournament_id: string; team_name: string; team_country: string | null; team_color: string | null; team_text_color: string | null; wins: number; runners_up: number; years_won: string | null; years_runner_up: string | null; from_my_career: boolean; }
interface Scorer { id: string; tournament_id: string; year: number; player_name: string; nationality: string | null; team: string | null; goals: number; from_my_career: boolean; }

export default function TournamentDetailPage() {
  const { id } = useParams();
  const [t, setT] = useState<Tournament | null>(null);
  const [champs, setChamps] = useState<Champion[]>([]);
  const [scorers, setScorers] = useState<Scorer[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingC, setEditingC] = useState<string | null>(null); // id or 'new'
  const [editingS, setEditingS] = useState<string | null>(null);
  const [cForm, setCForm] = useState<Partial<Champion>>({});
  const [sForm, setSForm] = useState<Partial<Scorer>>({ year: new Date().getFullYear(), goals: 0 });

  async function load() {
    if (!id) return;
    setLoading(true);
    const [{ data: td }, { data: cd }, { data: sd }] = await Promise.all([
      supabase.from('tournaments').select('*').eq('id', id).maybeSingle(),
      supabase.from('champions').select('*').eq('tournament_id', id).order('wins', { ascending: false }),
      supabase.from('top_scorers').select('*').eq('tournament_id', id).order('goals', { ascending: false }),
    ]);
    setT(td as Tournament | null); setChamps((cd ?? []) as Champion[]); setScorers((sd ?? []) as Scorer[]); setLoading(false);
  }
  useEffect(() => { load(); }, [id]);

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

      {t.has_top_scorer && (
        <section>
          <div className="flex items-center justify-between mb-2">
            <div className="text-xs uppercase font-semibold text-slate-500">⚽ Top scorer in one season</div>
            <button onClick={() => { setSForm({ year: new Date().getFullYear(), goals: 0 }); setEditingS('new'); }} className="text-xs bg-emerald-600 text-white rounded px-3 py-1">+ Add scorer</button>
          </div>
          {editingS === 'new' && (
            <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded p-3 mb-3 grid gap-2 sm:grid-cols-3">
              <input type="number" value={sForm.year ?? ''} onChange={(e) => setSForm({ ...sForm, year: Number(e.target.value) })} placeholder="End year" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-1 text-sm" />
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
                  <td className="px-3 py-2 font-medium">{s.player_name} {s.from_my_career && '⭐'}</td>
                  <td className="px-3 py-2 text-right font-semibold">{s.goals}</td>
                  <td className="px-3 py-2">{s.nationality ?? '—'}</td>
                  <td className="px-3 py-2 font-mono">{s.year}</td>
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
