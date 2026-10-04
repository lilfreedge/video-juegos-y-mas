import { Routes, Route, Link } from 'react-router-dom';
import HomePage from './pages/HomePage';
import TournamentsPage from './pages/TournamentsPage';
import TournamentDetailPage from './pages/TournamentDetailPage';
import CareerPage from './pages/CareerPage';

export default function App() {
  return (
    <div className="min-h-full bg-slate-50 dark:bg-slate-950 text-slate-900 dark:text-slate-100 relative">
      <div aria-hidden className="pointer-events-none fixed inset-0 z-0 overflow-hidden flex items-center justify-between opacity-[0.06] dark:opacity-[0.08]">
        <img src="/padre-patria.webp" alt="" className="h-[80vh] max-w-[45vw] object-contain blur-[1px]" />
        <img src="/el-lider.jpg" alt="" className="h-[70vh] max-w-[45vw] object-contain blur-[1px]" />
      </div>
      <div className="relative z-10">
        <header className="border-b border-slate-200 dark:border-slate-800 bg-white/95 dark:bg-slate-900/95 backdrop-blur px-4 py-3 sticky top-0 z-20">
          <div className="max-w-5xl mx-auto flex items-center gap-3">
            <Link to="/" className="flex items-center gap-2 font-bold text-lg">
              <img src="/green-sandy.jpg" alt="" className="w-10 h-10 rounded-xl object-cover" />
              <span>Video Juegos y Más</span>
            </Link>
          </div>
        </header>
        <main className="p-4 max-w-5xl mx-auto">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/tournaments" element={<TournamentsPage />} />
            <Route path="/tournament/:id" element={<TournamentDetailPage />} />
            <Route path="/career" element={<CareerPage />} />
          </Routes>
        </main>
      </div>
    </div>
  );
}
