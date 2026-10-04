import { Routes, Route, Link } from 'react-router-dom';
import TournamentsPage from './pages/TournamentsPage';
import TournamentDetailPage from './pages/TournamentDetailPage';

export default function App() {
  return (
    <div className="min-h-full bg-slate-50 dark:bg-slate-950 text-slate-900 dark:text-slate-100">
      <header className="border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 px-4 py-3 sticky top-0 z-10">
        <div className="max-w-5xl mx-auto flex items-center gap-3">
          <Link to="/" className="font-bold text-lg">🏆 Video Juegos y Más</Link>
        </div>
      </header>
      <main className="p-4 max-w-5xl mx-auto">
        <Routes>
          <Route path="/" element={<TournamentsPage />} />
          <Route path="/tournament/:id" element={<TournamentDetailPage />} />
        </Routes>
      </main>
    </div>
  );
}
