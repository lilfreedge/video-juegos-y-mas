import { useEffect, useMemo, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowLeft, Archive, BarChart3, CheckCircle2, ChevronDown, ChevronUp, Flag, Plus, Trophy, X } from 'lucide-react';
import { supabase } from '../lib/supabase';
import Loading from '../components/Loading';

interface Contract { id: string; club_name: string; club_country: string | null; club_color: string | null; club_text_color: string | null; club_logo_url: string | null; start_year: number; start_month: number | null; end_year: number | null; end_month: number | null; is_national: boolean; }
interface Season { id: string; contract_id: string; label: string; start_year: number; end_year: number; }
interface Trophy { id: string; season_id: string; tournament_name_snapshot: string; result: string; }
interface Club { id: string; name: string; country: string; primary_color: string; text_color: string; is_national: boolean; }

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
  const [clubs, setClubs] = useState<Club[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [showStats, setShowStats] = useState(false);
  const [addMode, setAddMode] = useState<'club' | 'national'>('club');
  const [selectedClub, setSelectedClub] = useState<Club | null>(null);
  const [startMonth, setStartMonth] = useState<number | ''>(new Date().getMonth() + 1);
  const [startYear, setStartYear] = useState<number>(new Date().getFullYear());
  const [endMonth, setEndMonth] = useState<number | ''>('');
  const [endYear, setEndYear] = useState<number | ''>('');

  async function load() {
    setLoading(true);
    const [{ data: cs }, { data: ss }, { data: ts }, { data: cat }] = await Promise.all([
      supabase.from('contracts').select('*').order('start_year', { ascending: false }).order('start_month', { ascending: false }),
      supabase.from('seasons').select('*'),
      supabase.from('trophies_won').select('*'),
      supabase.from('clubs_catalog').select('*').order('name'),
    ]);
    setContracts((cs ?? []) as Contract[]);
    setSeasons((ss ?? []) as Season[]);
    setTrophies((ts ?? []) as Trophy[]);
    setClubs((cat ?? []) as Club[]);
    setLoading(false);
  }
  useEffect(() => { load(); }, []);

  function resetForm() {
    setSelectedClub(null);
    setStartMonth(new Date().getMonth() + 1);
    setStartYear(new Date().getFullYear());
    setEndMonth('');
    setEndYear('');
  }

  async function saveContract() {
    if (!selectedClub) { alert('Pick a club first'); return; }
    const payload: any = {
      club_name: selectedClub.name,
      club_country: selectedClub.country,
      club_color: selectedClub.primary_color,
      club_text_color: selectedClub.text_color,
      club_logo_url: null,
      start_year: Number(startYear),
      start_month: startMonth ? Number(startMonth) : null,
      end_year: endYear ? Number(endYear) : null,
      end_month: endMonth ? Number(endMonth) : null,
      is_national: addMode === 'national',
    };
    const { error } = await supabase.from('contracts').insert(payload);
    if (error) { alert(error.message); return; }
    resetForm(); setShowAdd(false); load();
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

  // Split active + previous by club vs national
  const activeClub = active.find((c) => !c.is_national);
  const activeClubs = active.filter((c) => !c.is_national);
  const activeNationals = active.filter((c) => c.is_national);
  const previousClubs = previous.filter((c) => !c.is_national);
  const previousNationals = previous.filter((c) => c.is_national);

  function ContractCard({ c }: { c: Contract }) {
    const cs = seasons.filter((s) => s.contract_id === c.id);
    const ct = trophies.filter((t) => cs.some((s) => s.id === t.season_id));
    return (
      <Link to={`/career/contract/${c.id}`} className="block bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-emerald-400 rounded-lg overflow-hidden">
        <div className="flex items-stretch">
          <div className="w-1.5" style={{ background: c.club_color ?? '#64748b' }} />
          <div className="flex-1 p-3 flex items-center gap-3">
            <div className="w-10 h-10 rounded-lg flex items-center justify-center overflow-hidden shrink-0" style={{ background: c.club_color ?? '#0f172a', color: c.club_text_color ?? '#ffffff' }}>
              {c.is_national ? <Flag className="w-5 h-5" /> : <span className="text-xs font-bold">{c.club_name.slice(0, 2).toUpperCase()}</span>}
            </div>
            <div className="flex-1 min-w-0">
              <div className="font-bold truncate">{c.club_name}</div>
              <div className="text-xs text-slate-500">
                {c.club_country && <span className="mr-1">{c.club_country}</span>}·{' '}
                {c.start_month ? MONTHS[c.start_month - 1] + ' ' : ''}{c.start_year} → {c.end_year ? `${c.end_month ? MONTHS[c.end_month - 1] + ' ' : ''}${c.end_year}` : 'present'}
                <span className="text-slate-400"> · {duration(c)}</span>
              </div>
            </div>
            {ct.filter((t) => t.result === 'winner').length > 0 && (
              <span className="text-xs bg-amber-100 text-amber-800 rounded px-2 py-0.5 font-semibold inline-flex items-center gap-1"><Trophy className="w-3 h-3" /> {ct.filter((t) => t.result === 'winner').length}</span>
            )}
            <button onClick={(e) => { e.preventDefault(); delContract(c.id); }} className="text-slate-400 hover:text-red-500"><X className="w-4 h-4" /></button>
          </div>
        </div>
      </Link>
    );
  }

  return (
    <div>
      <Link to="/" className="text-slate-500 hover:text-emerald-600 text-sm inline-flex items-center gap-1"><ArrowLeft className="w-3.5 h-3.5" /> Home</Link>
      <div className="mt-3 mb-5 flex items-center justify-between gap-3 flex-wrap">
        <h1 className="text-2xl font-bold flex items-center gap-2"><Trophy className="w-6 h-6 text-emerald-600" /> Career</h1>
        <button onClick={() => setShowAdd((v) => !v)} className="bg-emerald-600 hover:bg-emerald-500 text-white rounded px-4 py-2 text-sm inline-flex items-center gap-1"><Plus className="w-4 h-4" /> Nuevo contract</button>
      </div>

      {showAdd && (
        <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded-lg p-4 mb-5">
          {clubs.length === 0 && (
            <div className="mb-3 p-3 bg-amber-50 border border-amber-300 rounded text-sm text-amber-900">
              ⚠️ <strong>Catálogo vacío.</strong> Corre la migración <code className="bg-amber-200 px-1 rounded">005_clubs_catalog.sql</code> en Supabase para cargar los ~400 clubes.
            </div>
          )}
          <div className="inline-flex rounded-lg border border-slate-200 dark:border-slate-700 overflow-hidden mb-3 text-sm">
            <button onClick={() => { setAddMode('club'); setSelectedClub(null); }} className={`px-4 py-1.5 inline-flex items-center gap-1.5 ${addMode === 'club' ? 'bg-emerald-600 text-white' : 'bg-transparent text-slate-500 hover:text-slate-800'}`}><Trophy className="w-4 h-4" /> Club</button>
            <button onClick={() => { setAddMode('national'); setSelectedClub(null); }} className={`px-4 py-1.5 inline-flex items-center gap-1.5 ${addMode === 'national' ? 'bg-emerald-600 text-white' : 'bg-transparent text-slate-500 hover:text-slate-800'}`}><Flag className="w-4 h-4" /> Selección</button>
          </div>
          <ClubPicker clubs={clubs.filter((c) => !!c.is_national === (addMode === 'national'))} value={selectedClub} onChange={setSelectedClub} isNational={addMode === 'national'} />
          <div className="grid gap-2 sm:grid-cols-4 mt-3">
            <select value={startMonth} onChange={(e) => setStartMonth(e.target.value ? Number(e.target.value) : '')} className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm">
              <option value="">Start month…</option>{MONTHS.map((m, i) => <option key={m} value={i + 1}>{m}</option>)}
            </select>
            <input type="number" value={startYear} onChange={(e) => setStartYear(Number(e.target.value))} placeholder="Start year" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
            <select value={endMonth} onChange={(e) => setEndMonth(e.target.value ? Number(e.target.value) : '')} className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm">
              <option value="">End month (opt)…</option>{MONTHS.map((m, i) => <option key={m} value={i + 1}>{m}</option>)}
            </select>
            <input type="number" value={endYear} onChange={(e) => setEndYear(e.target.value ? Number(e.target.value) : '')} placeholder="End year (opt)" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
          </div>
          <div className="flex justify-end gap-2 mt-3">
            <button onClick={() => { setShowAdd(false); resetForm(); }} className="text-sm text-slate-500 px-3">Cancel</button>
            <button onClick={saveContract} className="bg-emerald-600 text-white rounded px-4 py-2 text-sm">Save</button>
          </div>
        </div>
      )}

      {/* Stats toggle */}
      <button onClick={() => setShowStats((v) => !v)} className="w-full mb-3 flex items-center justify-between gap-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-emerald-400 rounded-lg px-4 py-3 text-sm">
        <span className="flex items-center gap-3 text-slate-600 dark:text-slate-300">
          <BarChart3 className="w-4 h-4" />
          <span className="font-semibold">Stats</span>
          <span className="text-slate-400 text-xs inline-flex items-center gap-1">· {contracts.filter((c) => !c.is_national).length} clubes · {seasons.length} seasons · {totalWinners} <Trophy className="w-3 h-3 inline" /> · {activeClub?.club_name ?? '—'}</span>
        </span>
        {showStats ? <ChevronUp className="w-4 h-4 text-slate-400" /> : <ChevronDown className="w-4 h-4 text-slate-400" />}
      </button>
      {showStats && (
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-6">
          {[
            ['Clubes', contracts.filter((c) => !c.is_national).length],
            ['Seasons', seasons.length],
            ['Trophies', totalWinners],
            ['Active Club', activeClub?.club_name ?? '—'],
          ].map(([l, v]) => (
            <div key={l as string} className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded p-3">
              <div className="text-[10px] uppercase text-slate-500 tracking-wide">{l}</div>
              <div className="text-xl font-bold mt-0.5 truncate">{v as any}</div>
            </div>
          ))}
        </div>
      )}


      {/* Trophy showcase */}
      {trophyList.length > 0 && (
        <section className="mb-6">
          <div className="text-xs uppercase font-semibold text-slate-500 mb-2 inline-flex items-center gap-1.5"><Trophy className="w-3.5 h-3.5" /> Trophy showcase</div>
          <div className="grid gap-2">{trophyList.map(([name, { count, years }]) => (
            <div key={name} className="flex items-center gap-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded p-3">
              <Trophy className="w-6 h-6 text-amber-500" />
              <div className="flex-1 min-w-0"><div className="font-medium">{name}</div><div className="text-xs text-slate-500">{[...years].sort().join(' · ')}</div></div>
              <span className="text-xl font-bold text-amber-700">×{count}</span>
            </div>
          ))}</div>
        </section>
      )}

      {/* Two-column layout: Clubs | Selecciones */}
      <div className="grid gap-6 md:grid-cols-2">
        {/* CLUBES column */}
        <div>
          <div className="text-sm font-bold text-slate-800 dark:text-slate-100 border-b border-slate-200 dark:border-slate-700 pb-2 mb-3 flex items-center gap-2">
            <Trophy className="w-4 h-4" />
            <span>Clubes</span>
            <span className="text-xs text-slate-400 font-normal ml-auto">{contracts.filter((c) => !c.is_national).length}</span>
          </div>
          {activeClubs.length > 0 && (
            <div className="mb-5">
              <div className="text-[10px] uppercase font-semibold text-emerald-700 mb-2 flex items-center gap-1"><CheckCircle2 className="w-3 h-3" /> Activos</div>
              <div className="grid gap-2">{activeClubs.map((c) => <ContractCard key={c.id} c={c} />)}</div>
            </div>
          )}
          {previousClubs.length > 0 && (
            <div>
              <div className="text-[10px] uppercase font-semibold text-slate-500 mb-2 flex items-center gap-1"><Archive className="w-3 h-3" /> Anteriores</div>
              <div className="grid gap-2">{previousClubs.map((c) => <ContractCard key={c.id} c={c} />)}</div>
            </div>
          )}
          {activeClubs.length === 0 && previousClubs.length === 0 && (
            <div className="text-slate-400 text-sm border border-dashed border-slate-300 dark:border-slate-700 rounded p-6 text-center">Sin clubes aún</div>
          )}
        </div>

        {/* SELECCIONES column */}
        <div>
          <div className="text-sm font-bold text-slate-800 dark:text-slate-100 border-b border-slate-200 dark:border-slate-700 pb-2 mb-3 flex items-center gap-2">
            <Flag className="w-4 h-4" />
            <span>Selecciones</span>
            <span className="text-xs text-slate-400 font-normal ml-auto">{contracts.filter((c) => c.is_national).length}</span>
          </div>
          {activeNationals.length > 0 && (
            <div className="mb-5">
              <div className="text-[10px] uppercase font-semibold text-emerald-700 mb-2 flex items-center gap-1"><CheckCircle2 className="w-3 h-3" /> Activas</div>
              <div className="grid gap-2">{activeNationals.map((c) => <ContractCard key={c.id} c={c} />)}</div>
            </div>
          )}
          {previousNationals.length > 0 && (
            <div>
              <div className="text-[10px] uppercase font-semibold text-slate-500 mb-2 flex items-center gap-1"><Archive className="w-3 h-3" /> Anteriores</div>
              <div className="grid gap-2">{previousNationals.map((c) => <ContractCard key={c.id} c={c} />)}</div>
            </div>
          )}
          {activeNationals.length === 0 && previousNationals.length === 0 && (
            <div className="text-slate-400 text-sm border border-dashed border-slate-300 dark:border-slate-700 rounded p-6 text-center">Sin selecciones aún</div>
          )}
        </div>
      </div>

      {contracts.length === 0 && (
        <div className="mt-6 text-slate-500 border border-dashed border-slate-300 rounded p-10 text-center">No tienes contracts aún. Click + Nuevo contract para empezar.</div>
      )}
    </div>
  );
}

function ClubPicker({ clubs, value, onChange, isNational = false }: { clubs: Club[]; value: Club | null; onChange: (c: Club | null) => void; isNational?: boolean }) {
  const [query, setQuery] = useState('');
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function onDoc(e: MouseEvent) { if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false); }
    document.addEventListener('mousedown', onDoc);
    return () => document.removeEventListener('mousedown', onDoc);
  }, []);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return clubs.slice(0, 50);
    return clubs.filter((c) => c.name.toLowerCase().includes(q) || c.country.toLowerCase().includes(q)).slice(0, 50);
  }, [clubs, query]);

  // Group filtered by country
  const grouped = useMemo(() => {
    const m: Record<string, Club[]> = {};
    for (const c of filtered) (m[c.country] = m[c.country] || []).push(c);
    return Object.entries(m).sort((a, b) => a[0].localeCompare(b[0]));
  }, [filtered]);

  if (value) {
    return (
      <div className="rounded-lg p-3 flex items-center gap-3 border-2" style={{ background: value.primary_color, color: value.text_color, borderColor: value.primary_color }}>
        <div className="w-12 h-12 rounded-lg bg-black/20 flex items-center justify-center font-bold text-lg shrink-0">{value.name.slice(0, 2).toUpperCase()}</div>
        <div className="flex-1 min-w-0">
          <div className="text-xs opacity-80 uppercase">{value.country}</div>
          <div className="font-black text-lg truncate">{value.name}</div>
        </div>
        <button onClick={() => { onChange(null); setQuery(''); }} className="bg-black/20 hover:bg-black/40 rounded px-3 py-1 text-xs font-semibold">Change</button>
      </div>
    );
  }

  return (
    <div ref={ref} className="relative">
      <input
        autoFocus
        value={query}
        onChange={(e) => { setQuery(e.target.value); setOpen(true); }}
        onFocus={() => setOpen(true)}
        placeholder={isNational ? 'Buscar selección… (ej: Portugal, Brazil…)' : 'Buscar club… (ej: Real Madrid, Udinese…)'}
        className="w-full bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2.5 text-sm"
      />
      {open && (
        <div className="absolute z-20 top-full left-0 right-0 mt-1 max-h-80 overflow-auto bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg shadow-xl">
          {filtered.length === 0 ? (
            <div className="p-4 text-sm text-slate-500 text-center">Ningún {isNational ? 'país' : 'club'} coincide. Solo entradas del catálogo son permitidas.</div>
          ) : grouped.map(([country, list]) => (
            <div key={country}>
              <div className="px-3 py-1 text-[10px] uppercase font-semibold text-slate-500 bg-slate-100 dark:bg-slate-900 sticky top-0">{country}</div>
              {list.map((c) => (
                <button key={c.id} onClick={() => { onChange(c); setQuery(''); setOpen(false); }} className="w-full flex items-center gap-2 px-3 py-2 text-sm hover:bg-emerald-50 dark:hover:bg-slate-700 text-left">
                  <span className="w-6 h-6 rounded shrink-0" style={{ background: c.primary_color, borderLeft: `3px solid ${c.text_color}` }} />
                  <span className="flex-1 truncate">{c.name}</span>
                </button>
              ))}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
