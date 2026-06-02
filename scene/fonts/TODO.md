# Font Rendering TODO

## Current State

`fontCreate` builds a font struct and obtains its bitmap through `fontBitmapGet`.
For cached fonts, bitmap data are loaded from `data/fonts/*.mat`. For missing
fonts, the fallback renders text into a hidden MATLAB figure, captures pixels,
crops whitespace, thresholds the image, and closes the figure.

There is currently a small local cache:

- `g-georgia-14-96.mat`
- `g-georgia-14-300.mat`
- `l-georgia-14-72.mat`

## Recommendation

Use cached bitmap files as the reproducible path for tests and generated scenes.
The cache should live in ISETCam under `data/fonts`. If we rebuild a larger font
set, a good long-term home would be the Stanford Digital Repository, retrievable
with `ieWebGet`, matching the pattern used for other data assets.

Keep system-font rendering only as a fallback for missing cache entries. Treat
that path as platform dependent and unsuitable for numerical goldens.

## Notes On Direct Font Reading

Most system font files are TrueType/OpenType vector outlines, not stored bitmap
glyphs. To get a bitmap at a particular size and DPI, some rasterizer still has
to render the glyph.

Options:

- Keep the current hidden-figure rasterization fallback.
- Replace it with an offscreen Java AWT rasterizer for better control and fewer
  MATLAB graphics side effects.
- Use a true TTF/OTF parser/rasterizer such as FreeType, but that would add a
  dependency and cross-platform maintenance burden.

## Cleanup

There should be only one implementation of `fontBitmapGet`. At the moment,
`fontCreate.m` contains a nested copy while `scene/fonts/fontBitmapGet.m` is a
standalone function. Consolidate these so the cache lookup and fallback behavior
cannot drift.
