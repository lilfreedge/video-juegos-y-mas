import { useEffect, useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft, BarChart3, Plus, Star, Trophy as TrophyIcon, X } from 'lucide-react';
import { supabase } from '../lib/supabase';
import Loading from '../components/Loading';

interface Season { id: string; contract_id: string; label: string; start_year: number; end_year: number; }
interface Contract { id: string; club_name: string; club_country: string | null; club_color: string | null; club_text_color: string | null; club_logo_url: string | null; is_national: boolean; }
interface Player { id: string; season_id: string; jersey: number | null; position: string | null; name: string; age: number | null; overall: number | null; nationality: string | null; status: 'squad' | 'new_signing' | 'loan_in' | 'loan_out' | 'sold'; }
interface Transfer { id: string; season_id: string; type: 'in' | 'out' | 'loan_in' | 'loan_out'; player_name: string; from_club: string | null; to_club: string | null; amount: string | null; month: number | null; squad_player_id: string | null; }
interface Tournament { id: string; name: string; country: string | null; division: number | null; }
interface Trophy { id: string; season_id: string; tournament_id: string | null; tournament_name_snapshot: string; result: string; }
interface Standing { id: string; tournament_id: string; year_end: number; team_name: string; position: number | null; played: number | null; wins: number | null; draws: number | null; losses: number | null; goals_for: number | null; goals_against: number | null; points: number | null; is_my_team: boolean; }

const STATUS_BADGE: Record<Player['status'], { label: string; className: string }> = {
  squad: { label: '', className: '' },
  new_signing: { label: 'NEW', className: 'bg-emerald-500 text-white' },
  loan_in: { label: 'LOAN IN', className: 'bg-blue-500 text-white' },
  loan_out: { label: 'LOAN OUT', className: 'bg-orange-500 text-white' },
  sold: { label: 'SOLD', className: 'bg-slate-400 text-white' },
};

const RESULTS = [
  ['winner', 'Winner'],
  ['runner_up', 'Runner-up'],
  ['semifinal', 'Semifinal'],
  ['quarterfinal', 'Quarterfinal'],
  ['r16', 'R16'],
  ['group', 'Group stage'],
  ['other', 'Other'],
] as const;

export default function SeasonDetailPage() {
  const { id } = useParams();
  const [tab, setTab] = useState<'squad' | 'transfers' | 'resumen'>('resumen');
  const [season, setSeason] = useState<Season | null>(null);
  const [contract, setContract] = useState<Contract | null>(null);
  const [players, setPlayers] = useState<Player[]>([]);
  const [transfers, setTransfers] = useState<Transfer[]>([]);
  const [trophies, setTrophies] = useState<Trophy[]>([]);
  const [tournaments, setTournaments] = useState<Tournament[]>([]);
  const [standings, setStandings] = useState<Standing[]>([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    if (!id) return;
    setLoading(true);
    const { data: s } = await supabase.from('seasons').select('*').eq('id', id).maybeSingle();
    const se = s as Season | null; setSeason(se);
    const [{ data: c }, { data: pl }, { data: tr }, { data: tw }, { data: ts }] = await Promise.all([
      se ? supabase.from('contracts').select('*').eq('id', se.contract_id).maybeSingle() : Promise.resolve({ data: null } as any),
      supabase.from('squad_players').select('*').eq('season_id', id).order('jersey', { ascending: true, nullsFirst: false }),
      supabase.from('transfers').select('*').eq('season_id', id).order('month', { ascending: true, nullsFirst: true }),
      supabase.from('trophies_won').select('*').eq('season_id', id),
      supabase.from('tournaments').select('id,name,country,division'),
    ]);
    setContract(c as Contract | null);
    setPlayers((pl ?? []) as Player[]);
    setTransfers((tr ?? []) as Transfer[]);
    setTrophies((tw ?? []) as Trophy[]);
    setTournaments((ts ?? []) as Tournament[]);

    // Load standings for the D1 of the contract's country for the season's end year
    if (se && c) {
      const contractData = c as Contract;
      const d1 = ((ts ?? []) as Tournament[]).find((t) => t.country === contractData.club_country && t.division === 1);
      if (d1) {
        const { data: std } = await supabase.from('standings').select('*').eq('tournament_id', d1.id).eq('year_end', se.end_year).order('position', { ascending: true });
        setStandings((std ?? []) as Standing[]);
      } else {
        setStandings([]);
      }
    }
    setLoading(false);
  }
  useEffect(() => { load(); }, [id]);

  if (loading) return <Loading />;
  if (!season) return <div className="text-slate-500">Season not found.</div>;

  // Find primary league tournament (D1 of contract's country)
  const primaryLeague = tournaments.find((t) => t.country === contract?.club_country && t.division === 1);

  return (
    <div>
      <Link to={`/career/contract/${season.contract_id}`} className="text-slate-500 hover:text-emerald-600 text-sm inline-flex items-center gap-1"><ArrowLeft className="w-3.5 h-3.5" /> {contract?.club_name ?? 'Contract'}</Link>
      <div className="mt-3 mb-4">
        <h1 className="text-2xl font-bold">{season.label}</h1>
      </div>

      <div className="flex gap-1 border-b border-slate-200 dark:border-slate-800 mb-4">
        {(['resumen', 'squad', 'transfers'] as const).map((t) => (
          <button key={t} onClick={() => setTab(t)} className={`px-4 py-2 text-sm font-semibold capitalize border-b-2 transition ${tab === t ? 'border-emerald-500 text-emerald-600' : 'border-transparent text-slate-500 hover:text-slate-700'}`}>
            {t === 'resumen' ? `Resumen (${trophies.length})` : t === 'squad' ? `Squad (${players.length})` : `Transfers (${transfers.length})`}
          </button>
        ))}
      </div>

      {tab === 'squad' && <SquadTab seasonId={season.id} players={players} onChange={load} />}
      {tab === 'transfers' && <TransfersTab seasonId={season.id} transfers={transfers} players={players} onChange={load} />}
      {tab === 'resumen' && <ResumenTab seasonId={season.id} trophies={trophies} tournaments={tournaments} standings={standings} primaryLeague={primaryLeague ?? null} contract={contract} onChange={load} />}
    </div>
  );
}

function SquadTab({ seasonId, players, onChange }: { seasonId: string; players: Player[]; onChange: () => void }) {
  const [showAdd, setShowAdd] = useState(false);
  const [showBulk, setShowBulk] = useState(false);
  const [bulk, setBulk] = useState('');
  const [p, setP] = useState<Partial<Player>>({ status: 'squad' });

  async function save() {
    if (!p.name?.trim()) return;
    const payload: any = { season_id: seasonId, name: p.name.trim(), jersey: p.jersey ?? null, position: p.position || null, age: p.age ?? null, overall: p.overall ?? null, nationality: p.nationality || null, status: p.status || 'squad' };
    const { error } = await supabase.from('squad_players').insert(payload);
    if (error) { alert(error.message); return; }
    setP({ status: 'squad' }); setShowAdd(false); onChange();
  }
  async function del(id: string) { if (!confirm('Remove player?')) return; await supabase.from('squad_players').delete().eq('id', id); onChange(); }
  async function parseBulk() {
    const lines = bulk.split('\n').map((l) => l.trim()).filter(Boolean);
    const rows = lines.map((line) => {
      const parts = line.split(/[\t,|]/).map((s) => s.trim());
      const [jersey, position, name, age, overall, nationality] = parts;
      return { season_id: seasonId, jersey: jersey ? Number(jersey) : null, position: position || null, name: name || parts[0] || '', age: age ? Number(age) : null, overall: overall ? Number(overall) : null, nationality: nationality || null, status: 'squad' as const };
    }).filter((r) => r.name);
    if (!rows.length) return;
    const { error } = await supabase.from('squad_players').insert(rows);
    if (error) { alert(error.message); return; }
    setBulk(''); setShowBulk(false); onChange();
  }

  const sorted = useMemo(() => [...players].sort((a, b) => (a.jersey ?? 999) - (b.jersey ?? 999)), [players]);

  return (
    <div>
      <div className="flex items-center justify-between mb-3 gap-2 flex-wrap">
        <div className="text-xs uppercase text-slate-500 font-semibold">Squad</div>
        <div className="flex gap-2">
          <button onClick={() => setShowBulk((v) => !v)} className="text-xs border border-slate-300 dark:border-slate-700 hover:border-emerald-400 rounded px-2 py-1">Bulk import</button>
          <button onClick={() => setShowAdd((v) => !v)} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">+ Player</button>
        </div>
      </div>

      {showBulk && (
        <div className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded p-3 mb-3">
          <div className="text-xs text-slate-500 mb-2">Paste rows: <code>jersey, pos, name, age, overall, nationality</code> (tab/comma/pipe)</div>
          <textarea rows={6} value={bulk} onChange={(e) => setBulk(e.target.value)} className="w-full bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm font-mono" placeholder="1, GK, M. Neuer, 38, 88, GER&#10;2, RB, Pavard, 28, 83, FRA" />
          <div className="flex justify-end gap-2 mt-2"><button onClick={() => setShowBulk(false)} className="text-sm text-slate-500 px-3">Cancel</button><button onClick={parseBulk} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">Import</button></div>
        </div>
      )}
      {showAdd && (
        <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded p-3 mb-3 grid gap-2 sm:grid-cols-6">
          <input type="number" value={p.jersey ?? ''} onChange={(e) => setP({ ...p, jersey: e.target.value ? Number(e.target.value) : null })} placeholder="#" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm" />
          <input value={p.position ?? ''} onChange={(e) => setP({ ...p, position: e.target.value })} placeholder="Pos" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm" />
          <input value={p.name ?? ''} onChange={(e) => setP({ ...p, name: e.target.value })} placeholder="Name" className="sm:col-span-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm" />
          <input type="number" value={p.age ?? ''} onChange={(e) => setP({ ...p, age: e.target.value ? Number(e.target.value) : null })} placeholder="Age" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm" />
          <input type="number" value={p.overall ?? ''} onChange={(e) => setP({ ...p, overall: e.target.value ? Number(e.target.value) : null })} placeholder="OVR" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm" />
          <input value={p.nationality ?? ''} onChange={(e) => setP({ ...p, nationality: e.target.value })} placeholder="Nat" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm" />
          <select value={p.status ?? 'squad'} onChange={(e) => setP({ ...p, status: e.target.value as Player['status'] })} className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm">
            <option value="squad">Squad</option><option value="new_signing">New signing</option><option value="loan_in">Loan in</option><option value="loan_out">Loan out</option>
          </select>
          <div className="sm:col-span-6 flex justify-end gap-2"><button onClick={() => setShowAdd(false)} className="text-sm text-slate-500 px-3">Cancel</button><button onClick={save} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">Save</button></div>
        </div>
      )}

      {sorted.length === 0 ? (
        <div className="text-slate-500 border border-dashed border-slate-300 rounded p-8 text-center text-sm">No players yet.</div>
      ) : (
        <div className="overflow-x-auto bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded">
          <table className="w-full text-sm">
            <thead className="bg-slate-100 dark:bg-slate-800 text-xs uppercase text-slate-500"><tr><th className="p-2 text-left">#</th><th className="p-2 text-left">Pos</th><th className="p-2 text-left">Name</th><th className="p-2">Age</th><th className="p-2">OVR</th><th className="p-2 text-left">Nat</th><th></th></tr></thead>
            <tbody>{sorted.map((pl) => {
              const b = STATUS_BADGE[pl.status];
              return (
                <tr key={pl.id} className="border-t border-slate-100 dark:border-slate-800">
                  <td className="p-2 font-bold w-10">{pl.jersey ?? '—'}</td>
                  <td className="p-2 w-14">{pl.position ?? ''}</td>
                  <td className="p-2 font-medium">
                    <span className="inline-flex items-center gap-2">{pl.name}{b.label && <span className={`text-[9px] font-bold px-1.5 py-0.5 rounded ${b.className}`}>{b.label}</span>}</span>
                  </td>
                  <td className="p-2 text-center w-14">{pl.age ?? ''}</td>
                  <td className="p-2 text-center w-14 font-bold text-emerald-600">{pl.overall ?? ''}</td>
                  <td className="p-2 w-14">{pl.nationality ?? ''}</td>
                  <td className="p-2 w-10 text-right"><button onClick={() => del(pl.id)} className="text-slate-400 hover:text-red-500">×</button></td>
                </tr>
              );
            })}</tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function TransfersTab({ seasonId, transfers, players, onChange }: { seasonId: string; transfers: Transfer[]; players: Player[]; onChange: () => void }) {
  const [type, setType] = useState<Transfer['type']>('in');
  const [showAdd, setShowAdd] = useState(false);
  const [t, setT] = useState<Partial<Transfer>>({});

  async function save() {
    if (!t.player_name?.trim()) return;
    const payload: any = { season_id: seasonId, type, player_name: t.player_name.trim(), from_club: t.from_club || null, to_club: t.to_club || null, amount: t.amount || null, month: t.month ?? null };
    const { data: inserted, error } = await supabase.from('transfers').insert(payload).select().maybeSingle();
    if (error) { alert(error.message); return; }
    // Side-effects on squad
    if (type === 'in' || type === 'loan_in') {
      const status = type === 'in' ? 'new_signing' : 'loan_in';
      const { data: sp } = await supabase.from('squad_players').insert({ season_id: seasonId, name: t.player_name!.trim(), status, nationality: null }).select().maybeSingle();
      if (sp && inserted) await supabase.from('transfers').update({ squad_player_id: (sp as any).id }).eq('id', (inserted as any).id);
    } else if (type === 'loan_out') {
      const match = players.find((p) => p.name.toLowerCase() === t.player_name!.trim().toLowerCase());
      if (match) await supabase.from('squad_players').update({ status: 'loan_out' }).eq('id', match.id);
    } else if (type === 'out') {
      const match = players.find((p) => p.name.toLowerCase() === t.player_name!.trim().toLowerCase());
      if (match) await supabase.from('squad_players').update({ status: 'sold' }).eq('id', match.id);
    }
    setT({}); setShowAdd(false); onChange();
  }
  async function del(id: string) { if (!confirm('Remove transfer?')) return; await supabase.from('transfers').delete().eq('id', id); onChange(); }

  const groups: Record<Transfer['type'], Transfer[]> = { in: [], out: [], loan_in: [], loan_out: [] };
  for (const tr of transfers) groups[tr.type].push(tr);
  const titles: Record<Transfer['type'], string> = { in: '↙ IN', out: '↗ OUT', loan_in: '← LOAN IN', loan_out: '→ LOAN OUT' };

  return (
    <div>
      <div className="flex items-center justify-between mb-3 gap-2 flex-wrap">
        <div className="text-xs uppercase text-slate-500 font-semibold">Transfers</div>
        <button onClick={() => setShowAdd((v) => !v)} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">+ Transfer</button>
      </div>
      {showAdd && (
        <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded p-3 mb-3 grid gap-2 sm:grid-cols-5">
          <select value={type} onChange={(e) => setType(e.target.value as Transfer['type'])} className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm">
            <option value="in">IN</option><option value="out">OUT</option><option value="loan_in">LOAN IN</option><option value="loan_out">LOAN OUT</option>
          </select>
          <input value={t.player_name ?? ''} onChange={(e) => setT({ ...t, player_name: e.target.value })} placeholder="Player" className="sm:col-span-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm" />
          <input value={t.from_club ?? ''} onChange={(e) => setT({ ...t, from_club: e.target.value })} placeholder="From club" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm" />
          <input value={t.to_club ?? ''} onChange={(e) => setT({ ...t, to_club: e.target.value })} placeholder="To club" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm" />
          <input value={t.amount ?? ''} onChange={(e) => setT({ ...t, amount: e.target.value })} placeholder="Amount (e.g. €50M)" className="sm:col-span-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm" />
          <input type="number" value={t.month ?? ''} onChange={(e) => setT({ ...t, month: e.target.value ? Number(e.target.value) : null })} placeholder="Month (1-12)" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm" />
          <div className="sm:col-span-5 flex justify-end gap-2"><button onClick={() => setShowAdd(false)} className="text-sm text-slate-500 px-3">Cancel</button><button onClick={save} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">Save</button></div>
        </div>
      )}
      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
        {(['in', 'out', 'loan_in', 'loan_out'] as const).map((k) => (
          <div key={k} className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded p-3">
            <div className="text-xs font-bold mb-2">{titles[k]} <span className="text-slate-400">({groups[k].length})</span></div>
            {groups[k].length === 0 ? <div className="text-xs text-slate-400 italic">—</div> : groups[k].map((tr) => (
              <div key={tr.id} className="text-sm border-t border-slate-100 dark:border-slate-800 py-2 first:border-t-0 first:pt-0">
                <div className="flex items-center justify-between gap-2"><div className="font-medium truncate">{tr.player_name}</div><button onClick={() => del(tr.id)} className="text-slate-400 hover:text-red-500 shrink-0">×</button></div>
                <div className="text-xs text-slate-500">{tr.from_club && `← ${tr.from_club}`} {tr.to_club && `→ ${tr.to_club}`}</div>
                {tr.amount && <div className="text-xs text-emerald-600 font-semibold">{tr.amount}</div>}
              </div>
            ))}
          </div>
        ))}
      </div>
    </div>
  );
}

function TrophiesTab({ seasonId, trophies, tournaments, onChange }: { seasonId: string; trophies: Trophy[]; tournaments: Tournament[]; onChange: () => void }) {
  const [showAdd, setShowAdd] = useState(false);
  const [tournamentId, setTournamentId] = useState('');
  const [result, setResult] = useState<string>('winner');

  async function save() {
    if (!tournamentId) return;
    const tourn = tournaments.find((x) => x.id === tournamentId);
    if (!tourn) return;
    const { error } = await supabase.from('trophies_won').insert({ season_id: seasonId, tournament_id: tournamentId, tournament_name_snapshot: tourn.name, result });
    if (error) { alert(error.message); return; }
    setTournamentId(''); setResult('winner'); setShowAdd(false); onChange();
  }
  async function del(id: string) { if (!confirm('Remove?')) return; await supabase.from('trophies_won').delete().eq('id', id); onChange(); }

  const grouped: Record<string, Tournament[]> = {};
  for (const t of tournaments) { const k = t.country ?? 'Other'; (grouped[k] = grouped[k] || []).push(t); }

  return (
    <div>
      <div className="flex items-center justify-between mb-3 gap-2 flex-wrap">
        <div className="text-xs uppercase text-slate-500 font-semibold">Trophies</div>
        <button onClick={() => setShowAdd((v) => !v)} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">+ Add</button>
      </div>
      {showAdd && (
        <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded p-3 mb-3 grid gap-2 sm:grid-cols-3">
          <select value={tournamentId} onChange={(e) => setTournamentId(e.target.value)} className="sm:col-span-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm">
            <option value="">Pick tournament…</option>
            {Object.entries(grouped).map(([country, list]) => (
              <optgroup key={country} label={country}>
                {list.map((t) => <option key={t.id} value={t.id}>{t.name}{t.division ? ` (D${t.division})` : ''}</option>)}
              </optgroup>
            ))}
          </select>
          <select value={result} onChange={(e) => setResult(e.target.value)} className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-2 py-2 text-sm">
            {RESULTS.map(([k, l]) => <option key={k} value={k}>{l}</option>)}
          </select>
          <div className="sm:col-span-3 flex justify-end gap-2"><button onClick={() => setShowAdd(false)} className="text-sm text-slate-500 px-3">Cancel</button><button onClick={save} className="bg-emerald-600 text-white rounded px-3 py-1 text-sm">Save</button></div>
        </div>
      )}
      {trophies.length === 0 ? (
        <div className="text-slate-500 border border-dashed border-slate-300 rounded p-8 text-center text-sm">No trophies logged.</div>
      ) : (
        <div className="grid gap-2">{trophies.map((t) => {
          const label = RESULTS.find(([k]) => k === t.result)?.[1] ?? t.result;
          return (
            <div key={t.id} className="flex items-center gap-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded p-3">
              <span className="text-2xl">{t.result === 'winner' ? '🏆' : t.result === 'runner_up' ? '🥈' : '🎯'}</span>
              <div className="flex-1 min-w-0"><div className="font-medium truncate">{t.tournament_name_snapshot}</div><div className="text-xs text-slate-500">{label}</div></div>
              <button onClick={() => del(t.id)} className="text-slate-400 hover:text-red-500">×</button>
            </div>
          );
        })}</div>
      )}
    </div>
  );
}
