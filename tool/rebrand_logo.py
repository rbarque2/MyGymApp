"""Recolorea los assets de marca de ZarpaFit del azul antiguo a la paleta naranja.

Extrae la mascara de la "Z" blanca (canal rojo: fondo azul R~1, trazo blanco R=255)
y la recompone sobre un degradado diagonal #F97316 -> #EA580C (orange-500 -> orange-600).

Uso: python3 tool/rebrand_logo.py
"""

from PIL import Image

SRC = "assets/zarpafit_logo.png"
OUTPUTS = ["assets/zarpafit_logo.png", "assets/zarpafit-icon.png"]
GRAD_START = (0xF9, 0x73, 0x16)  # #F97316 esquina superior izquierda
GRAD_END = (0xEA, 0x58, 0x0C)  # #EA580C esquina inferior derecha


def diagonal_gradient(size: int) -> Image.Image:
    ramp = Image.new("L", (size, size))
    ramp.putdata(
        [round((x + y) * 255 / (2 * (size - 1))) for y in range(size) for x in range(size)]
    )
    start = Image.new("RGB", (size, size), GRAD_START)
    end = Image.new("RGB", (size, size), GRAD_END)
    return Image.composite(end, start, ramp)


def main() -> None:
    src = Image.open(SRC).convert("RGB")
    mask = src.getchannel("R")
    white = Image.new("RGB", src.size, (255, 255, 255))
    out = Image.composite(white, diagonal_gradient(src.size[0]), mask).convert("RGBA")
    for path in OUTPUTS:
        out.save(path, optimize=True)
        print(f"escrito {path} {out.size}")


if __name__ == "__main__":
    main()
