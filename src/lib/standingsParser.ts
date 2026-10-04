import Tesseract from 'tesseract.js';

export interface ParsedRow {
  position: number | null;
  team: string;
  played: number | null;
  wins: number | null;
  draws: number | null;
  losses: number | null;
  gf: number | null;
  ga: number | null;
  points: number | null;
}

// Resize image to max 1600px wide for faster OCR
export async function resizeImage(file: File, maxDim = 1600): Promise<Blob> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => {
      const scale = Math.min(1, maxDim / Math.max(img.width, img.height));
      const w = Math.round(img.width * scale);
      const h = Math.round(img.height * scale);
      const canvas = document.createElement('canvas');
      canvas.width = w; canvas.height = h;
      const ctx = canvas.getContext('2d')!;
      ctx.drawImage(img, 0, 0, w, h);
      canvas.toBlob((b) => b ? resolve(b) : reject(new Error('resize failed')), 'image/jpeg', 0.9);
    };
    img.onerror = () => reject(new Error('image load failed'));
    img.src = URL.createObjectURL(file);
  });
}

export async function runOcr(image: Blob | File, onProgress?: (p: number) => void): Promise<string> {
  const result = await Tesseract.recognize(image, 'eng', {
    logger: (m) => { if (m.status === 'recognizing text' && onProgress) onProgress(m.progress); },
  });
  return result.data.text;
}

// Parse OCR text into standing rows.
// Expected row format: "1 Real Madrid 38 28 6 4 82 28 90" (various separators OK).
export function parseStandings(text: string): ParsedRow[] {
  const lines = text.split('\n').map((l) => l.trim()).filter(Boolean);
  const rows: ParsedRow[] = [];

  for (const line of lines) {
    // Match: optional leading noise, position (1-30), then rest
    const m = line.match(/^[^\d]*(\d{1,2})[\s.)]+(.+)$/);
    if (!m) continue;
    const position = parseInt(m[1], 10);
    if (position < 1 || position > 30) continue;

    const rest = m[2];
    // Extract trailing numbers (team name + stats)
    // Split on whitespace, walk from the right collecting numeric tokens
    const tokens = rest.split(/\s+/);
    const stats: number[] = [];
    let teamEnd = tokens.length;
    for (let i = tokens.length - 1; i >= 0; i--) {
      const cleaned = tokens[i].replace(/[^-\d:]/g, '');
      if (/^-?\d+$/.test(cleaned)) {
        stats.unshift(parseInt(cleaned, 10));
        teamEnd = i;
      } else if (/^(-?\d+):(-?\d+)$/.test(cleaned)) {
        // Score like 82:28 — split into two
        const [a, b] = cleaned.split(':').map((n) => parseInt(n, 10));
        stats.unshift(a, b);
        teamEnd = i;
      } else {
        break;
      }
    }

    // Need at least 2 stat numbers to be a valid row
    if (stats.length < 2) continue;

    const team = tokens.slice(0, teamEnd).join(' ').trim();
    if (!team) continue;

    // Map stats by common formats:
    // 8 stats: PJ W D L GF GC GD Pts
    // 7 stats: PJ W D L GF GC Pts
    // 6 stats: PJ W D L GD Pts  OR  PJ GF GC Pts (unlikely)
    // 2 stats: PJ Pts (minimal)
    const n = stats.length;
    let played = null, wins = null, draws = null, losses = null, gf = null, ga = null, points = null;
    if (n >= 7) { played = stats[0]; wins = stats[1]; draws = stats[2]; losses = stats[3]; gf = stats[4]; ga = stats[5]; points = stats[n - 1]; }
    else if (n === 6) { played = stats[0]; wins = stats[1]; draws = stats[2]; losses = stats[3]; points = stats[5]; }
    else if (n >= 2) { played = stats[0]; points = stats[n - 1]; }

    rows.push({ position, team, played, wins, draws, losses, gf, ga, points });
  }

  // Dedupe by position (keep first)
  const seen = new Set<number>();
  return rows.filter((r) => {
    if (r.position == null || seen.has(r.position)) return false;
    seen.add(r.position); return true;
  }).sort((a, b) => (a.position ?? 0) - (b.position ?? 0));
}

// Fuzzy match a parsed team name to a catalog of real names
export function matchTeam(name: string, catalog: string[]): string | null {
  const n = name.toLowerCase().replace(/[^a-z0-9]/g, '');
  if (!n) return null;
  // Exact (normalized) first
  for (const c of catalog) {
    if (c.toLowerCase().replace(/[^a-z0-9]/g, '') === n) return c;
  }
  // Prefix match
  for (const c of catalog) {
    const cn = c.toLowerCase().replace(/[^a-z0-9]/g, '');
    if (cn.startsWith(n) || n.startsWith(cn)) return c;
  }
  // Substring
  for (const c of catalog) {
    const cn = c.toLowerCase().replace(/[^a-z0-9]/g, '');
    if (cn.includes(n) || n.includes(cn)) return c;
  }
  return null;
}
