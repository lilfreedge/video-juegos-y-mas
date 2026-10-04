import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import Loading from '../components/Loading';

interface Contract { id: string; club_name: string; club_country: string | null; club_color: string | null; club_text_color: string | null; club_logo_url: string | null; start_year: number; start_month: number | null; end_year: number | null; end_month: number | null; }
interface Season { id: string; contract_id: string; label: string; start_year: number; end_year: number; }
interface Trophy { id: string; season_id: string; tournament_name_snapshot: string; result: string; }

const MONTHS = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

function duration(c: Contract): string {
  const now = new Date();
  const startY = c.start_year, startM = c.start_month ?? 1;
  const endY = c.end_year ?? now.getFullYear();
  const endM = c.end_month ?? (now.getMonth() + 1);
  const months = Math.max(0, (endY * 12 + endM) - (startY * 12 + startM));
  const y = Math.floor(months / 12);
  const m = months % 12;
  if (y === 0) return `${m} mo`;
  if (m === 0) return `${y}y`;
  return `${y}y ${m}m`;
}

export default function CareerPage() {
  const [contracts, setContracts] = useState<Contract[]>([]);
  const [seasons, setSeasons] = useState<Season[]>([]);
  const [trophies, setTrophies] = useState<Trophy[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [f, setF] = useState<Partial<Contract>>({ start_year: new Date().getFullYear(), start_month: new Date().getMonth() + 1, club_color: '#1e3a8a', club_text_color: '#ffffff' });

  async function load() {
    setLoading(true);
    const [{ data: cs }, { data: ss }, { data: ts }] = await Promise.all([
      supabase.from('contracts').select('*').order('start_year', { ascending: false }).order('start_month', { ascending: false }),
      supabase.from('seasons').select('*'),
      supabase.from('trophies_won').select('*'),
    ]);
    setContracts((cs ?? []) as Contract[]);
    setSeasons((ss ?? []) as Season[]);
    setTrophies((ts ?? []) as Trophy[]);
    setLoading(false);
  }
  useEffect(() => { load(); }, []);

  async function saveContract() {
    if (!f.club_name?.trim() || !f.start_year) return;
    const payload: any = {
      club_name: f.club_name.trim(), club_country: f.club_country || null,
      club_color: f.club_color || null, club_text_color: f.club_text_color || null,
      club_logo_url: f.club_logo_url || null,
      start_year: Number(f.start_year), start_month: f.start_month ? Number(f.start_month) : null,
      end_year: f.end_year ? Number(f.end_year) : null, end_month: f.end_month ? Number(f.end_month) : null,
    };
    const { error } = await supabase.from('contracts').insert(payload);
    if (error) { alert(error.message); return; }
    setF({ start_year: new Date().getFullYear(), start_month: new Date().getMonth() + 1, club_color: '#1e3a8a', club_text_color: '#ffffff' });
    setShowAdd(false); load();
  }
  async function delContract(id: string) { if (!confirm('Delete contract + all seasons?')) return; await supabase.from('contracts').delete().eq('id', id); load(); }

  if (loading) return <Loading />;

  const active = contracts.filter((c) => !c.end_year);
  const previous = contracts.filter((c) => c.end_year);
  const totalWinners = trophies.filter((t) => t.result === 'winner').length;
  const trophyCounts: Record<string, { count: number; years: Set<number> }> = {};
  for (const t of trophies) {
    if (t.result !== 'winner') continue;
    const s = seasons.find((x) => x.id === t.season_id);
    const yr = s?.end_year ?? 0;
    const key = t.tournament_name_snapshot;
    if (!trophyCounts[key]) trophyCounts[key] = { count: 0, years: new Set() };
    trophyCounts[key].count += 1;
    if (yr) trophyCounts[key].years.add(yr);
  }
  const trophyList = Object.entries(trophyCounts).sort((a, b) => b[1].count - a[1].count);

  const activeContract = active[0];

  function ContractCard({ c }: { c: Contract }) {
    const cs = seasons.filter((s) => s.contract_id === c.id);
    const ct = trophies.filter((t) => cs.some((s) => s.id === t.season_id));
    return (
      <Link to={`/career/contract/${c.id}`} className="block bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-emerald-400 rounded-lg overflow-hidden">
        <div className="flex items-stretch">
          <div className="w-1.5" style={{ background: c.club_color ?? '#64748b' }} />
          <div className="flex-1 p-3 flex items-center gap-3">
            <div className="w-10 h-10 rounded-lg flex items-center justify-center overflow-hidden shrink-0" style={{ background: c.club_color ?? '#0f172a' }}>
              {c.club_logo_url ? <img src={c.club_logo_url} alt="" className="w-full h-full object-contain p-1" /> : <span className="text-white text-xs font-bold">{c.club_name.slice(0, 2).toUpperCase()}</span>}
            </div>
            <div className="flex-1 min-w-0">
              <div className="font-bold truncate">{c.club_name}</div>
              <div className="text-xs text-slate-500">
                {c.start_month ? MONTHS[c.start_month - 1] + ' ' : ''}{c.start_year} → {c.end_year ? `${c.end_month ? MONTHS[c.end_month - 1] + ' ' : ''}${c.end_year}` : 'present'}
                <span className="text-slate-400"> · {duration(c)}</span>
              </div>
            </div>
            {ct.filter((t) => t.result === 'winner').length > 0 && (
              <span className="text-xs bg-amber-100 text-amber-800 rounded px-2 py-0.5 font-semibold">🏆 {ct.filter((t) => t.result === 'winner').length}</span>
            )}
            <button onClick={(e) => { e.preventDefault(); delContract(c.id); }} className="text-slate-400 hover:text-red-500 text-sm">×</button>
          </div>
        </div>
      </Link>
    );
  }

  return (
    <div>
      <Link to="/" className="text-slate-500 hover:text-emerald-600 text-sm">← Home</Link>
      <div className="mt-3 mb-5 flex items-center justify-between gap-3 flex-wrap">
        <h1 className="text-2xl font-bold">⚽ Career</h1>
        <button onClick={() => setShowAdd((v) => !v)} className="bg-emerald-600 hover:bg-emerald-500 text-white rounded px-4 py-2 text-sm">+ Nuevo contract</button>
      </div>

      {showAdd && (
        <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded-lg p-4 mb-5 grid gap-2 sm:grid-cols-3">
          <input autoFocus value={f.club_name ?? ''} onChange={(e) => setF({ ...f, club_name: e.target.value })} placeholder="Club" className="sm:col-span-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
          <input value={f.club_country ?? ''} onChange={(e) => setF({ ...f, club_country: e.target.value })} placeholder="Country" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
          <input value={f.club_logo_url ?? ''} onChange={(e) => setF({ ...f, club_logo_url: e.target.value })} placeholder="Logo URL" className="sm:col-span-3 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
          <div className="flex gap-1 items-center"><input type="color" value={f.club_color ?? '#1e3a8a'} onChange={(e) => setF({ ...f, club_color: e.target.value })} className="w-10 h-9 rounded border border-slate-300 dark:border-slate-700" /><input type="color" value={f.club_text_color ?? '#ffffff'} onChange={(e) => setF({ ...f, club_text_color: e.target.value })} className="w-10 h-9 rounded border border-slate-300 dark:border-slate-700" /><span className="text-xs text-slate-500">colors</span></div>
          <select value={f.start_month ?? ''} onChange={(e) => setF({ ...f, start_month: e.target.value ? Number(e.target.value) : null })} className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm">
            <option value="">Start month…</option>{MONTHS.map((m, i) => <option key={m} value={i + 1}>{m}</option>)}
          </select>
          <input type="number" value={f.start_year ?? ''} onChange={(e) => setF({ ...f, start_year: Number(e.target.value) })} placeholder="Start year" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
          <select value={f.end_month ?? ''} onChange={(e) => setF({ ...f, end_month: e.target.value ? Number(e.target.value) : null })} className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm">
            <option value="">End month (opt)…</option>{MONTHS.map((m, i) => <option key={m} value={i + 1}>{m}</option>)}
          </select>
          <input type="number" value={f.end_year ?? ''} onChange={(e) => setF({ ...f, end_year: e.target.value ? Number(e.target.value) : null })} placeholder="End year (opt)" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
          <div className="sm:col-span-3 flex justify-end gap-2"><button onClick={() => setShowAdd(false)} className="text-sm text-slate-500 px-3">Cancel</button><button onClick={saveContract} className="bg-emerald-600 text-white rounded px-4 py-2 text-sm">Save</button></div>
        </div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-6">
        {[['Clubs', contracts.length], ['Seasons', seasons.length], ['Trophies', totalWinners], ['Active Contract', activeContract?.club_name ?? '—']].map(([l, v]) => (
          <div key={l as string} className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded p-3">
            <div className="text-[10px] uppercase text-slate-500 tracking-wide">{l}</div>
            <div className="text-xl font-bold mt-0.5 truncate">{v as any}</div>
          </div>
        ))}
      </div>

      {/* Trophy showcase */}
      {trophyList.length > 0 && (
        <section className="mb-6">
          <div className="text-xs uppercase font-semibold text-slate-500 mb-2">🏆 Trophy showcase</div>
          <div className="grid gap-2">{trophyList.map(([name, { count, years }]) => (
            <div key={name} className="flex items-center gap-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded p-3">
              <span className="text-2xl">🏆</span>
              <div className="flex-1 min-w-0"><div className="font-medium">{name}</div><div className="text-xs text-slate-500">{[...years].sort().join(' · ')}</div></div>
              <span className="text-xl font-bold text-amber-700">×{count}</span>
            </div>
          ))}</div>
        </section>
      )}

      {/* Timeline */}
      {active.length > 0 && (
        <section className="mb-6">
          <div className="text-xs uppercase font-semibold text-emerald-700 mb-2">🟢 Active</div>
          <div className="grid gap-2">{active.map((c) => <ContractCard key={c.id} c={c} />)}</div>
        </section>
      )}
      {previous.length > 0 && (
        <section>
          <div className="text-xs uppercase font-semibold text-slate-500 mb-2">📁 Previous</div>
          <div className="grid gap-2">{previous.map((c) => <ContractCard key={c.id} c={c} />)}</div>
        </section>
      )}
      {contracts.length === 0 && (
        <div className="text-slate-500 border border-dashed border-slate-300 rounded p-10 text-center">No tienes contracts aún. Click + Nuevo contract para empezar.</div>
      )}
    </div>
  );
}
