# Munsell renotation data

CIE chromaticity (x, y) and luminance factor (Y) of Munsell hue/value/chroma
samples, for CIE Illuminant C and the CIE 1931 2-degree observer.

| File       | Samples | Contents |
|------------|--------:|----------|
| `real.dat` | 2,734 | Samples tabulated in the 1943 renotation paper. All lie within the MacAdam limits. |
| `all.dat`  | 4,995 | `real.dat` plus extrapolated samples (including Values 0.2–0.8 and 10). Some are outside the MacAdam limits. |
| `1929.dat` |   956 | The 1929 Munsell Book of Color samples, transcribed from Munsell's notes. |

Each file has a one-line header followed by six columns: hue (e.g. `2.5R`),
value, chroma, x, y, Y.

**Y scale.** Y is relative to magnesium oxide (MgO), not to a perfect
reflecting diffuser. Multiply Y by 0.975 to convert it to the
perfect-diffuser scale used by ASTM D1535 and by `ieMunsell2XYZ`.

**Not chip measurements.** The renotation specifies the aim colors of the
Munsell system. It is not a set of measurements of a particular Munsell
Book of Color.

**Known discrepancies between the files.** The files are kept exactly as
downloaded.

- `2.5R 9/2`: `real.dat` lists x = 0.3210 and `all.dat` lists x = 0.3220.
  The `all.dat` value is consistent with the neighboring hues and Values;
  the `real.dat` value is probably a transcription error.
- Values 3 and 6: `all.dat` lists Y = 6.55 and 30.03. `real.dat`,
  `1929.dat`, and the 1943 Value formula give 6.555 and 30.05.

`ieMunsell2XYZ` uses the x, y of `all.dat` and computes Y from the Value
with the ASTM D1535 formula, so the Y discrepancies do not affect it.

## Source

S. M. Newhall, D. Nickerson, and D. B. Judd, "Final report of the O.S.A.
Subcommittee on the Spacing of the Munsell Colors," *J. Opt. Soc. Am.* 33,
385–418 (1943).

The files were downloaded unchanged in November 2026 from the Munsell Color
Science Laboratory (MCSL) at RIT:
<https://www.rit.edu/science/munsell-color-science-lab-educational-resources>.
According to that page, the tables were taken from Wyszecki and Stiles,
*Color Science*, 2nd ed. (1982).

## Terms of use

**For research use only.** The renotation section of the RIT page states no
terms of use for these files. The same page restricts its spectral-image
downloads: "THESE IMAGES ARE MADE AVAILABLE FOR RESEARCH PURPOSES ONLY. All
other uses are prohibited. Copyright remains with PoCS / MCSL." ISETCam
treats the renotation files the same way and includes them for research
use. When you use them, cite Newhall, Nickerson and Judd (1943) and credit
the Munsell Color Science Laboratory at RIT as the source of the files.

## ISETCam functions

- `ieMunsellRenotation` – read these files
- `ieMunsell2XYZ` – Munsell notation to XYZ
- `ieXYZ2Munsell` – XYZ to Munsell notation
- `ieMunsellNotation` – convert between notation text and numeric [H V C]
