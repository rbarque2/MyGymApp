#!/usr/bin/env python3
"""Elimina el `const` que envuelve expresiones que dejaron de ser constantes.

Uso: ejecutar tras convertir ZarpaColors a getters dinámicos. Parsea la salida
de `flutter analyze`, y para cada error invalid_constant /
non_constant_list_element busca hacia atrás el token `const` que abre la
expresión envolvente y lo borra. Itera hasta converger.
"""
import re
import subprocess
import sys
from collections import defaultdict

ROOT = "/Users/rafaelbarqueromurillo/Documents/GitHub/my_gym_app"
CODES = ("invalid_constant", "non_constant_list_element",
         "const_with_non_const", "non_constant_default_value")

OPEN, CLOSE = "([{", ")]}"
SKIP = set("_.<>, \n\r\t")


def offset_of(src, line, col):
    lines = src.split("\n")
    return sum(len(l) + 1 for l in lines[: line - 1]) + col - 1


def find_const(src, pos):
    """Busca hacia atrás el `const` que hace const la expresión en pos."""
    depth = 0
    i = pos - 1
    while i >= 0:
        c = src[i]
        if c in CLOSE:
            depth += 1
        elif c in OPEN:
            if depth == 0:
                j = i - 1
                while j >= 0 and (src[j].isalnum() or src[j] in SKIP):
                    j -= 1
                segment = src[j + 1: i]
                tokens = segment.split()
                if "const" in tokens:
                    k = src.rfind("const", j + 1, i)
                    return k
                i = j
                depth = 0
                continue
            depth -= 1
        i -= 1
    return None


def analyze():
    out = subprocess.run(
        ["flutter", "analyze", "--no-pub"],
        capture_output=True, text=True, cwd=ROOT,
    )
    errors = []
    for line in (out.stdout + out.stderr).splitlines():
        m = re.match(
            r"\s*error • .* • (lib/[^ ]+):(\d+):(\d+) • ([a-z_]+)", line)
        if m and m.group(4) in CODES:
            errors.append((m.group(1), int(m.group(2)), int(m.group(3))))
    return errors


def main():
    for iteration in range(12):
        errors = analyze()
        if not errors:
            print(f"OK: sin errores const tras {iteration} iteraciones")
            return 0
        print(f"Iteración {iteration + 1}: {len(errors)} errores")
        by_file = defaultdict(list)
        for f, line, col in errors:
            by_file[f].append((line, col))
        changed = False
        for f, positions in by_file.items():
            path = f"{ROOT}/{f}"
            with open(path) as fh:
                src = fh.read()
            # De atrás hacia delante para no desplazar offsets pendientes
            removals = set()
            for line, col in sorted(positions, reverse=True):
                pos = offset_of(src, line, col)
                k = find_const(src, pos)
                if k is not None:
                    removals.add(k)
            for k in sorted(removals, reverse=True):
                end = k + len("const")
                if end < len(src) and src[end] == " ":
                    end += 1
                src = src[:k] + src[end:]
                changed = True
            with open(path, "w") as fh:
                fh.write(src)
        if not changed:
            print("Sin progreso; quedan errores para arreglo manual:")
            for e in errors:
                print(" ", e)
            return 1
    return 1


if __name__ == "__main__":
    sys.exit(main())
