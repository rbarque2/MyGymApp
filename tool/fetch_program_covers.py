#!/usr/bin/env python3
"""Fetch Unsplash cover photos for ZarpaFit programs.

Reads UNSPLASH_ACCESS_KEY from .env, queries one photo per program id, and
prints a JSON map { program_id: photo_url } to stdout. Run once; results get
baked into lib/models/program_model.dart as static imageUrl values.

Usage:
    python3 tool/fetch_program_covers.py > /tmp/covers.json
"""

import json
import os
import pathlib
import sys
import time
import urllib.parse
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]

# Load .env
env = {}
for line in (ROOT / ".env").read_text().splitlines():
    line = line.strip()
    if not line or line.startswith("#") or "=" not in line:
        continue
    k, v = line.split("=", 1)
    env[k.strip()] = v.strip()

ACCESS_KEY = env.get("UNSPLASH_ACCESS_KEY")
if not ACCESS_KEY:
    sys.exit("Missing UNSPLASH_ACCESS_KEY in .env")

# Per-program search queries. Keep them concrete so Unsplash returns a photo
# that matches the vibe (not a random stock photo).
QUERIES = {
    # Rápidos (one body part)
    "rapido_pierna": "barbell squat gym",
    "rapido_espalda": "pull up bar back workout",
    "rapido_core": "plank abs workout",
    "rapido_biceps": "biceps curl dumbbell",
    "rapido_triceps": "triceps pushdown gym",
    "rapido_hombro": "shoulder press gym",
    "rapido_gluteos": "hip thrust barbell",
    "rapido_abs": "abs crunch gym",
    "rapido_brazos": "arm workout dumbbell",
    "rapido_pantorrillas": "calf raise gym",
    "rapido_antebrazos": "forearm grip training",
    "rapido_lumbar": "back extension gym",
    "rapido_fullbody_casa": "home workout body weight",
    "rapido_hiit": "hiit workout",

    # Programas (multi-week)
    "rino_pierna_hombro": "barbell squat overhead press",
    "gorila_tiron": "deadlift barbell",
    "prog_running_inicio": "beginner running",
    "prog_running_avanzado": "trail running athlete",
    "prog_calistenia_inicio": "calisthenics park",
    "prog_ppl": "push pull legs gym",
    "prog_upper_lower": "barbell bench press gym",
    "prog_full_body_inicio": "full body workout gym",
    "prog_volumen_pecho": "chest bench press gym",
    "prog_volumen_espalda": "back row barbell",
    "prog_brazos_21": "biceps triceps gym arms",
    "prog_gluteos_30dias": "glute workout woman gym",
    "prog_core_6sem": "core training plank",
    "prog_531": "powerlifting squat barbell",
    "prog_movilidad_diaria": "mobility stretching mat",
    "prog_hiit_4semanas": "hiit training kettlebell",

    # Calentamientos
    "calent_superior": "upper body warm up",
    "calent_inferior": "leg warm up stretching",
    "calent_prerunning": "runner stretching warmup",
    "calent_fullbody": "dynamic warm up",
    "calent_brazos": "arm warm up gym",
    "calent_push": "shoulder mobility warm up",
    "calent_pull": "back mobility warm up",
    "calent_cuello": "neck stretch mobility",

    # Estiramientos
    "mov_hombro": "shoulder mobility stretch",
    "mov_cadera": "hip mobility stretch",
    "est_post_pierna": "leg stretch cool down",
    "est_post_torso": "back stretch yoga",
    "est_post_brazos": "arm stretch yoga",
    "est_full_body": "full body stretch yoga",
    "est_movilidad_tobillo": "ankle mobility stretch",
    "est_yoga_recuperacion": "yoga recovery mat",
    "est_espalda_cadera": "back hip stretch yoga",
}


def fetch_photo(query: str) -> str | None:
    """Hit Unsplash /search/photos, return urls.regular of the top hit."""
    url = (
        "https://api.unsplash.com/search/photos?"
        + urllib.parse.urlencode(
            {"query": query, "per_page": 1, "orientation": "landscape"}
        )
    )
    req = urllib.request.Request(
        url,
        headers={
            "Authorization": f"Client-ID {ACCESS_KEY}",
            "Accept-Version": "v1",
        },
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        data = json.loads(resp.read().decode())
    results = data.get("results") or []
    if not results:
        return None
    # Prefer urls.regular (~1080w). Fall back to small or raw.
    urls = results[0].get("urls") or {}
    return urls.get("regular") or urls.get("small") or urls.get("raw")


def main() -> None:
    out: dict[str, str] = {}
    errors: list[str] = []
    for i, (pid, q) in enumerate(QUERIES.items(), 1):
        try:
            url = fetch_photo(q)
        except Exception as e:
            errors.append(f"{pid}: {e}")
            url = None
        if url:
            out[pid] = url
            print(f"[{i:02d}/{len(QUERIES)}] {pid:30s} → ok", file=sys.stderr)
        else:
            print(f"[{i:02d}/{len(QUERIES)}] {pid:30s} → NO RESULT", file=sys.stderr)
        # Be polite with the rate limit (50/hr on demo).
        time.sleep(0.6)

    json.dump(out, sys.stdout, indent=2, ensure_ascii=False)
    sys.stdout.write("\n")
    if errors:
        print("\nErrors:", file=sys.stderr)
        for e in errors:
            print(f"  {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
