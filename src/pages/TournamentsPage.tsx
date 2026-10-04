import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';

interface Tournament {
  id: string;
  name: string;
  country: string | null;
  logo_url: string | null;
  has_top_scorer: boolean;
  color: string | null;
  text_color: string | null;
  sort_order: number | null;
}

export default function TournamentsPage() {
  const [rows, setRows] = useState<Tournament[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);
  const [showAdd, setShowAdd] = useState(false);
  const [name, setName] = useState('');
  const [country, setCountry] = useState('');
  const [logoUrl, setLogoUrl] = useState('');
  const [hasScorer, setHasScorer] = useState(false);

  async function load() {
    setLoading(true);
    try {
      const { data, error } = await supabase.from('tournaments').select('*').order('sort_order', { ascending: true });
      if (error) throw error;
      setRows((data ?? []) as Tournament[]);
    } catch (e: any) {
      setErr(e.message ?? String(e));
    }
    setLoading(false);
  }
  useEffect(() => { load(); }, []);

  async function add() {
    if (!name.trim()) return;
    const maxOrder = rows.reduce((m, r) => Math.max(m, r.sort_order ?? 0), 0);
    const { error } = await supabase.from('tournaments').insert({ name: name.trim(), country: country || null, logo_url: logoUrl || null, has_top_scorer: hasScorer, sort_order: maxOrder + 1 });
    if (error) { alert(error.message); return; }
    setName(''); setCountry(''); setLogoUrl(''); setHasScorer(false); setShowAdd(false); load();
  }
  async function del(t: Tournament) {
    if (!confirm(`Delete ${t.name}?`)) return;
    await supabase.from('tournaments').delete().eq('id', t.id); load();
  }

  if (loading) return <div className="text-slate-500 text-sm py-10 text-center">Loading…</div>;

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-2xl font-bold">Tournaments</h1>
        <button onClick={() => setShowAdd((v) => !v)} className="bg-emerald-600 hover:bg-emerald-500 text-white rounded px-4 py-2 text-sm">+ Add</button>
      </div>
      {err && <div className="mb-3 p-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded">{err}</div>}
      {showAdd && (
        <div className="bg-white dark:bg-slate-900 border border-emerald-300 rounded-lg p-4 mb-4 grid gap-2 sm:grid-cols-2">
          <input autoFocus value={name} onChange={(e) => setName(e.target.value)} placeholder="Tournament name" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
          <input value={country} onChange={(e) => setCountry(e.target.value)} placeholder="Country" className="bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
          <input value={logoUrl} onChange={(e) => setLogoUrl(e.target.value)} placeholder="Logo URL" className="sm:col-span-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded px-3 py-2 text-sm" />
          <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={hasScorer} onChange={(e) => setHasScorer(e.target.checked)} /> Has top scorer table</label>
          <div className="sm:col-span-2 flex justify-end gap-2"><button onClick={() => setShowAdd(false)} className="text-sm text-slate-500 px-3">Cancel</button><button onClick={add} className="bg-emerald-600 text-white rounded px-4 py-2 text-sm">Save</button></div>
        </div>
      )}
      {rows.length === 0 ? (
        <div className="text-slate-500 border border-dashed border-slate-300 rounded p-10 text-center">No tournaments yet.</div>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {rows.map((t) => (
            <div key={t.id} className="group relative bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-emerald-400 rounded-lg overflow-hidden transition">
              <Link to={`/tournament/${t.id}`} className="block p-4 flex items-center gap-3">
                <div className="w-12 h-12 rounded flex items-center justify-center overflow-hidden shrink-0" style={{ background: t.color ?? '#1e3a8a' }}>
                  {t.logo_url ? <img src={t.logo_url} alt="" className="w-full h-full object-contain p-1" onError={(e) => (e.currentTarget as HTMLImageElement).style.display = 'none'} /> : <span className="font-bold text-white text-xs">{t.name.slice(0, 3).toUpperCase()}</span>}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="font-bold truncate">{t.name}</div>
                  <div className="text-xs text-slate-500 mt-0.5">{t.country ?? '—'}{t.has_top_scorer && <span className="ml-2 text-emerald-700">⚽ scorers</span>}</div>
                </div>
              </Link>
              <button onClick={() => del(t)} className="absolute top-2 right-2 w-6 h-6 rounded-full bg-black/60 text-white opacity-0 group-hover:opacity-100 transition flex items-center justify-center text-sm">×</button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
