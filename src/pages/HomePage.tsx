import { Link } from 'react-router-dom';

export default function HomePage() {
  return (
    <div className="pt-8">
      <h1 className="text-3xl sm:text-4xl font-black text-center mb-8 bg-gradient-to-r from-emerald-500 to-teal-500 bg-clip-text text-transparent">Video Juegos y Más</h1>
      <div className="grid gap-4 sm:grid-cols-2 max-w-2xl mx-auto">
        <Link to="/tournaments" className="group relative overflow-hidden rounded-2xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-emerald-400 transition shadow-sm hover:shadow-lg p-6 text-center">
          <div className="w-28 h-28 mx-auto mb-3 flex items-center justify-center">
            <img src="/uasd-ring.jpg" alt="" className="max-w-full max-h-full object-contain drop-shadow-xl group-hover:scale-110 transition-transform duration-300" />
          </div>
          <div className="text-xl font-bold">Tournaments</div>
          <div className="text-xs text-slate-500 mt-2">Campeones, top scorers, standings</div>
        </Link>
        <Link to="/career" className="group relative overflow-hidden rounded-2xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-emerald-400 transition shadow-sm hover:shadow-lg p-6 text-center">
          <div className="w-28 h-28 mx-auto mb-3 flex items-center justify-center">
            <img src="/jabulani.jpg" alt="" className="max-w-full max-h-full object-contain drop-shadow-xl group-hover:rotate-12 transition-transform duration-500" />
          </div>
          <div className="text-xl font-bold">Career</div>
          <div className="text-xs text-slate-500 mt-2">Tus clubes, trofeos y temporadas</div>
        </Link>
      </div>
    </div>
  );
}
