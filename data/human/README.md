# Human vision data

Spectral functions and measurements for human vision, organized by kind.

| Folder | Contents |
| --- | --- |
| `cmf/` | Color matching functions (CMFs) |
| `cones/` | Cone fundamentals, photopigment absorbance, cone density |
| `conemosaic/` | Cone mosaic measurements |
| `rods/` | Rod spectral sensitivity |
| `luminosity/` | Photopic and scotopic luminosity functions |
| `lens/` | Lens optical density |
| `macular/` | Macular pigment optical density and transmittance |
| `melanopsin/` | Melanopsin spectral sensitivity |
| `spectrum/` | Lookup table for plotting spectra in color |
| `cvrl/` | Tables from CVRL, stored exactly as downloaded |

MATLAB finds these files by name, so code should use the name alone, as in
`ieReadSpectra('XYZ',wave)`, and not spell out a folder. Only scripts that write a
data file need the folder. Because lookup is by name, file names must be unique
across the folders; `test_humanStandards` checks this.

The color standards are built from tables published by the Color & Vision Research
Laboratory (CVRL, <http://www.cvrl.org>), maintained by Andrew Stockman.

New work should use the CIE 2006 cone fundamentals. Most ISETCam code still reads
the files with older names, which are described at the end of this page.

## Which file to use

| To compute | Use |
| --- | --- |
| Cone responses | `cones_CIE2006_2deg_*` or `cones_CIE2006_10deg_*` |
| Standard XYZ, 2° | `XYZ` (energy) or `xyzQuanta` (quanta): the CIE 1931 observer |
| Standard XYZ, 10° | `cmf_CIE1964_10deg_*` |
| XYZ consistent with the CIE 2006 cones | `cmf_CIE2012_2deg_*` or `cmf_CIE2012_10deg_*` |
| Luminosity consistent with the CIE 2006 cones | `luminosity_CIE2008_2deg_*` or `luminosity_CIE2008_10deg_*` |
| The original Stiles & Burch color matches | `cmf_SB1955_2deg_*` or `cmf_SB1959_10deg_*` |

The field size is the stimulus diameter the function applies to. Use 2° for small
central fields and 10° for large fields, which have less macular pigment influence.

Read a file by name, for example:

```matlab
xyz10 = ieReadSpectra('cmf_CIE1964_10deg_quanta',wave);
[cones,names] = ieReadColorFilter(wave,'cones_CIE2006_2deg_quanta');
```

`ieReadSpectra` returns 0 outside the wavelength range of a file. The CIE 2006
functions start at 390 nm, for example, so they read as 0 below that.

## File names

```text
<kind>_<source><year>_<field>deg_<basis>.mat
```

| Part | Values |
| --- | --- |
| `kind` | `cmf`, `cones`, `luminosity` |
| `source` and `year` | `CIE1964`, `SB1955`, `SB1959`, `CIE2012`, `CIE2006`, `CIE2008` |
| `field` | `2` or `10` degrees |
| `basis` | `energy` or `quanta` |

## Energy and quanta

The standards are defined for light measured in energy. ISETCam mainly computes
with photons, so each standard has two files.

- A `_energy` file is the CVRL table, to be applied to light in energy units.
- A `_quanta` file is to be applied to light in photons. It is the energy data
  multiplied at each wavelength by hc/λ, the energy of one photon.

`data_humanStandards` always computes the `_quanta` file from the `_energy` file.

The two kinds of function use different scales in their `_quanta` files:

| Kind | Scale of the `_quanta` file | Consequence |
| --- | --- | --- |
| `cmf`, `luminosity` | Absolute, in joules per photon | Photon and energy input give the same result: `cmfQuanta'*photons` equals `cmfEnergy'*energy` |
| `cones` | Peak of 1 for each cone class | Only the shape is meaningful; values are about 1, not about 1e-19 |

The `normalization` field of each file records its scale.

## Contents of each file

| Field | Meaning |
| --- | --- |
| `wavelength` | Samples in nm, N x 1 |
| `data` | N x K matrix, one function per column |
| `filterNames` | One name per column; the first letter is the ISETCam color hint |
| `comment` | Description and source table |
| `units` | `'energy'` or `'quanta'` |
| `normalization` | How the values are scaled |
| `fieldSizeDeg` | 2 or 10 |
| `source` | CVRL site, table name, URL, SHA-256 and retrieval date |

## The standards

Each stem below has an `_energy` and a `_quanta` file.

| File stem | Function | Field | Samples (nm) | CVRL table |
| --- | --- | --- | --- | --- |
| `cmf/cmf_CIE1964_10deg` | CIE 1964 XYZ | 10° | 360–830, 1 nm | `ciexyz64_1.csv` |
| `cmf/cmf_SB1955_2deg` | Stiles & Burch RGB | 2° | 390–730, 5 nm | `sbrgb2.csv` |
| `cmf/cmf_SB1959_10deg` | Stiles & Burch RGB | 10° | 390–830, 5 nm | `sbrgb10w.csv` |
| `cmf/cmf_CIE2012_2deg` | CIE 2012 XYZ | 2° | 390–830, 1 nm | `lin2012xyz2e_1_7sf.csv` |
| `cmf/cmf_CIE2012_10deg` | CIE 2012 XYZ | 10° | 390–830, 1 nm | `lin2012xyz10e_1_7sf.csv` |
| `cones/cones_CIE2006_2deg` | CIE 2006 LMS | 2° | 390–830, 1 nm | `linss2_10e_1_8dp.csv` |
| `cones/cones_CIE2006_10deg` | CIE 2006 LMS | 10° | 390–830, 1 nm | `linss10e_1_8dp.csv` |
| `luminosity/luminosity_CIE2008_2deg` | CIE 2008 V(λ) | 2° | 390–830, 1 nm | `linCIE2008v2e_1_8dp.csv` |
| `luminosity/luminosity_CIE2008_10deg` | CIE 2008 V(λ) | 10° | 390–830, 1 nm | `linCIE2008v10e_1_8dp.csv` |

Notes on these standards:

- **CIE 2006 cones** are the Stockman & Sharpe (2000) fundamentals, adopted by the
  CIE in TR 170-1. CVRL serves one table for both.
- CVRL does not tabulate the **S-cone** function above 615 nm. Those values are
  stored as 0.
- CVRL sets each **cone peak** to 1 on its 0.1 nm table. The peak usually falls
  between the 1 nm samples, so the largest stored value can be as low as 0.99994.
- **CIE 2012 XYZ** are a linear transform of the CIE 2006 cones. CVRL labels them
  CIE (2012); the CIE published them in TR 170-2:2015. The 2° XYZ are linear in the
  2° cones only, and the 10° XYZ in the 10° cones only.

### CIE 1931, CIE 1964 and Stiles & Burch

These names are easy to mix up:

- **CIE 1931** is the 2° observer, reconstructed from the chromaticity
  measurements of Wright and Guild using V(λ).
- **Stiles & Burch (1955)** are directly measured 2° CMFs from 10 observers,
  in RGB primaries.
- **Stiles & Burch (1959)** are directly measured 10° CMFs, in RGB primaries.
  The table here uses the wavelength version, in which Stockman & Sharpe (2000)
  corrected the long wavelengths for rod intrusion.
- **CIE 1964** is the 10° observer in XYZ. It is based on the mean 10° CMFs of
  Stiles & Burch (1959) and of Speranskaya (1959), with the Speranskaya data given
  low weight.

## Older file names

These files keep their original names, which most ISETCam code and other
repositories still use. The table says what each file actually is, as verified
numerically against CVRL (`test_humanStandards`).

| File(s) | What it is | Basis | Agreement with CVRL |
| --- | --- | --- | --- |
| `XYZ`, `XYZEnergy` (same data) | CIE 1931 2° XYZ | energy | Matches `ciexyz31_1.csv`, except Y at 547 nm is 0.9874812 and should be 0.9874182 |
| `xyzQuanta` | `XYZ` times hc/λ, absolute scale | quanta | Same 547 nm error; all zeros above 730 nm |
| `vlambda`, `luminosity` (same data) | CIE 1924 V(λ), the Y of `XYZ` | energy | Matches `vl1924e_1.csv`, with the same 547 nm error |
| `vlambdaQuanta`, `photopicLuminosityQuanta`, `photopicLuminosity`, `luminosityQuanta` | V(λ) times hc/λ, absolute scale | quanta | `photopicLuminosity` holds quanta despite its name |
| `luminosityJudd` | Judd (1951) luminosity | energy | Matches `vlje.csv`, 10 nm samples |
| `luminosityJuddQuanta` | `luminosityJudd` times hc/λ, absolute scale | quanta | Derived |
| `scotopicLuminosity` | CIE 1951 V′(λ) | energy | Matches `scvle.csv`, 5 nm samples |
| `stockman`, `stockmanEnergy` (same data) | Stockman, MacLeod & Johnson (1993), 2° derived from 10° CMFs | energy | Matches `smj2_10.csv` at 390–730 nm; the 1 nm values are linear interpolations. Values at 370–385 nm are placeholders: exactly 0.1 times the 390–405 nm values |
| `stockman-StilesBurch` | Stockman, MacLeod & Johnson (1993), 2° from the Stiles & Burch 2° CMFs | energy | Matches `smj2.csv`; same placeholders. These are cone fundamentals, not CMFs |
| `stockmanQuanta` | `stockman` times hc/λ, peak of 1 | quanta | Within 1.1e-4 of `smj2_10q.csv` |
| `stockmanAbs` | `stockman` times [0.27 0.26 0.07] | energy | Derived; same placeholders |
| `SmithPokornyCones`, `ncones` (same data) | Smith-Pokorny equations applied to the Judd (1951) CMFs | energy | Matches `ciexyzj.csv` through those equations. CVRL's own `sp` table uses Judd-Vos and differs by up to 0.078 in S near 410 nm |
| `macularPigment` | Macular pigment optical density | density | Matches `macss_1.csv` |
| `lensDensity` | Lens optical density | density | Matches `lensss_1.csv` |
| `coneAbsorbance` | Stockman-Sharpe photopigment absorbance | log10 | Matches `ssabance_1.csv` |

`melanopsin*` come from a CIE spreadsheet and `rods` is derived, so CVRL has no
table to compare them with.

## Updating a table

CVRL serves plain HTTP only, so `cvrl/MANIFEST.tsv` records a SHA-256 for each
table. The tables in `cvrl/` are stored exactly as downloaded.

1. Download the table with the URL in `cvrl/MANIFEST.tsv` and replace the file in
   `cvrl/`.
2. Update its row in the manifest.
3. To add a standard, add a row to the list in `data_humanStandards.m`.
4. Run `data_humanStandards`, then `runtests('test_humanStandards')`.

MATLAB only sees new folders after the path is set again, for example with
`addpath(genpath(isetRootPath))`.

## References

- CIE (1926). *Commission Internationale de l'Éclairage Proceedings, 1924*. Cambridge University Press.
- CIE (1932). *Commission Internationale de l'Éclairage Proceedings, 1931*. Cambridge University Press.
- CIE Proceedings (1951). Vol. 1, Sec. 4; Vol. 3, p. 37. Bureau Central de la CIE, Paris.
- CIE Proceedings (1964). Vienna Session, 1963, Vol. B, pp. 209–220 (Committee Report E-1.4.1). Bureau Central de la CIE, Paris.
- CIE (2006). *Fundamental chromaticity diagram with physiological axes – Part 1*. Technical Report 170-1. Vienna: Central Bureau of the CIE.
- CIE (2015). *Fundamental chromaticity diagram with physiological axes – Part 2*. Technical Report 170-2. Vienna: Central Bureau of the CIE.
- Judd, D. B. (1951). Report of U.S. Secretariat Committee on Colorimetry and Artificial Daylight. *Proceedings of the Twelfth Session of the CIE, Stockholm*.
- Sharpe, L. T., Stockman, A., Jagla, W., & Jägle, H. (2005). A luminous efficiency function, V\*(λ), for daylight adaptation. *Journal of Vision, 5*, 948–968.
- Sharpe, L. T., Stockman, A., Jagla, W., & Jägle, H. (2011). A luminous efficiency function, V\*(λ), for daylight adaptation: a correction. *Color Research & Application, 36*, 42–46.
- Speranskaya, N. I. (1959). Determination of spectrum color co-ordinates for twenty-seven normal observers. *Optics and Spectroscopy, 7*, 424–428.
- Stiles, W. S., & Burch, J. M. (1955). Interim report to the Commission Internationale de l'Éclairage, Zurich, 1955, on the National Physical Laboratory's investigation of colour-matching. *Optica Acta, 2*, 168–181.
- Stiles, W. S., & Burch, J. M. (1959). NPL colour-matching investigation: Final report. *Optica Acta, 6*, 1–26.
- Stockman, A., Jägle, H., Pirzer, M., & Sharpe, L. T. (2008). The dependence of luminous efficiency on chromatic adaptation. *Journal of Vision, 8*(16):1, 1–26.
- Stockman, A., MacLeod, D. I. A., & Johnson, N. E. (1993). Spectral sensitivities of the human cones. *Journal of the Optical Society of America A, 10*, 2491–2521.
- Stockman, A., Sharpe, L. T., & Fach, C. C. (1999). The spectral sensitivity of the human short-wavelength cones. *Vision Research, 39*, 2901–2927.
- Stockman, A., & Sharpe, L. T. (2000). Spectral sensitivities of the middle- and long-wavelength sensitive cones derived from measurements in observers of known genotype. *Vision Research, 40*, 1711–1737.
- Wyszecki, G., & Stiles, W. S. (1982). *Color Science: concepts and methods, quantitative data and formulae* (2nd ed.). New York: Wiley.
