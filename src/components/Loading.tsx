export default function Loading() {
  return (
    <div className="fixed inset-0 z-50 flex flex-col items-center justify-center bg-slate-50 dark:bg-slate-950">
      <div className="relative">
        {/* Pulsing ring */}
        <div className="absolute inset-0 rounded-full bg-emerald-500/40 animate-ping" />
        <div className="absolute inset-0 rounded-full bg-emerald-500/20 animate-pulse" style={{ animationDuration: '1.5s' }} />
        {/* Avatar */}
        <img src="/green-sandy.jpg" alt="" className="relative w-40 h-40 sm:w-48 sm:h-48 rounded-full object-cover ring-4 ring-emerald-500/60 shadow-2xl" />
        {/* Shimmer overlay */}
        <div className="absolute inset-0 rounded-full overflow-hidden">
          <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/30 to-transparent -translate-x-full animate-[shimmer_2s_ease-in-out_infinite]" style={{ animation: 'shimmer 2s linear infinite' }} />
        </div>
      </div>
      <div className="mt-6 text-sm font-bold tracking-wide text-slate-600 dark:text-slate-300 uppercase">Video Juegos y Más</div>
      <div className="mt-2 text-xs text-slate-400">Cargando…</div>
      <style>{`
        @keyframes shimmer {
          0% { transform: translateX(-100%); }
          100% { transform: translateX(200%); }
        }
      `}</style>
    </div>
  );
}
