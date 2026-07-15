# Optics Examples Overview

This directory contains optics-focused examples for ISETCam.

## Layout

- Root scripts (`examples/optics`): core diffraction, shift-invariant, PSF/OTF, and microlens examples.
- `flare/`: flare and aperture-structure experiments.
- `focus_dof/`: depth-of-field and defocus analyses.
- `raytrace/`: synthetic and ray-trace PSF workflows.
- `wavefront/`: wavefront modeling, plotting, and Zernike workflows.
- `chromAb/`: legacy chromatic-aberration material (archival/external-tool dependent).

## How To Run

Run one example:

```matlab
ieExampleTest('selection','s_opticsFlare')
```

Run from a starting point:

```matlab
ieExampleTest('start','s_opticsFlare')
```

Run all examples:

```matlab
ieExampleTest
```

## Notes

- Prefer scripts in the active subdirectories listed above.
- Treat `chromAb` as archival unless you specifically need those historical/external-tool workflows.
