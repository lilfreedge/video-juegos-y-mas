import { Link } from 'react-router-dom';

export default function CareerPage() {
  return (
    <div>
      <Link to="/" className="text-slate-500 hover:text-emerald-600 text-sm">← Home</Link>
      <h1 className="text-2xl font-bold mt-3 mb-4">⚽ Career</h1>
      <div className="text-slate-500 border border-dashed border-slate-300 rounded p-10 text-center">
        Próximamente: tus clubes, temporadas, squads, fichajes y trofeos.
      </div>
    </div>
  );
}
