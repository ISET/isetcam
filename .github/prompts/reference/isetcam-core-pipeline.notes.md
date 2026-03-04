# ISETCam core pipeline notes (internal)

Scope: quick reminders for the main stage constructors/computes so future assistance can use the right functions/fields without re-reading source.

## Mental model: pipeline objects (all are MATLAB `struct`s)

- **Scene** (`scene.type == 'scene'`): spectral *radiance* at each spatial sample. Access via `sceneGet/sceneSet`.
- **Optical image** (`oi.type == 'opticalimage'`): spectral *irradiance* at the sensor plane + optics model. Access via `oiGet/oiSet`.
- **Sensor** (`sensor.type == 'sensor'`): pixel array model + measured signal (volts / digital values) in `sensor.data.*`. Access via `sensorGet/sensorSet`.
- **Image processor** (`ip.type == 'vcimage'`): pipeline output in sensor space + rendered RGB (`ip.data.*`). Access via `ipGet/ipSet`.
- **Display** (`d.type == 'display'`): calibration (SPD primaries + gamma) used for rendering. Access via `displayGet/displaySet`.

---

## Scene

### `sceneCreate(sceneName, varargin)`
- **Purpose**: Create a `scene` struct (spectral radiance) for a named synthetic scene (default is Macbeth under D65).
- **Required inputs**:
  - `sceneName` (string) optional; default `'default'`.
- **Key optional parameters** (depend on `sceneName`):
  - For Macbeth/default/empty: `patchSize` (pixels/patch, default `16`), `wave` (default `400:10:700`), `surfaceFile` (reflectances, default `'macbethChart.mat'`), `blackBorder` (logical).
  - Many other scene families accept size, frequency, dynamic range, etc. (see header examples).
- **Outputs**:
  - `scene` (struct)
    - Always has `scene.type = 'scene'` and `scene.metadata = []` initially.
    - Typical content is set through `sceneSet(...)`, notably: `'wave'`, `'photons'` (radiance photons), `'illuminant'` (illuminant struct), `'fov'`, `'distance'`, `'magnification'`, `'luminance'`.
  - `parms` (struct/[]) returned for some special pattern scenes.

### `sceneAdjustIlluminant(scene, illEnergy, preserveMean)`
- **Purpose**: Replace a scene’s illuminant SPD while preserving surface reflectance (divide out current illuminant, multiply by new).
- **Required inputs**:
  - `scene` (scene struct). If omitted/empty: uses `ieGetObject('scene')`.
  - `illEnergy` one of:
    - filename to spectra (read via `ieReadSpectra(fullName, wave)`)
    - energy vector (same length as scene wave)
    - illuminant struct (`illEnergy.type == 'illuminant'`)
- **Key optional parameters**:
  - `preserveMean` (logical, default `true`): after changing illuminant, rescale to preserve the original mean luminance.
- **Output structure**:
  - Returns updated `scene` with:
    - radiance photons updated (via `sceneSPDScale` for spectral illuminants, or explicit per-pixel math for spatial-spectral)
    - illuminant updated in the scene
    - mean luminance optionally restored (`sceneAdjustLuminance(scene, mLum)`)
    - comment set: `sceneSet(scene,'illuminant comment', fullName)`

---

## Optical image

### `oiCreate(oiType, varargin)`
- **Purpose**: Create an `oi` struct (optics + storage for sensor-plane irradiance).
- **Required inputs**:
  - `oiType` optional; default `'diffraction limited'`.
- **Key optional parameters** (depend on `oiType`):
  - `'wvf'`: may pass an existing wavefront struct as first arg.
  - `'ray trace'`: typically first arg is a ray-trace optics file.
  - `'uniform d65'`, `'uniform ee'`, `'black'`: optional `sz`, `wave`.
  - `'human wvf'` / `'human mw'`: pass-through args for `opticsCreate(...)`.
- **Outputs**:
  - `oi` (struct)
    - `oi.type = 'opticalimage'`, `oi.name = vcNewObjectName('opticalimage')`, `oi.metadata = []`.
    - `oi.optics` set for most cases (via `opticsCreate(...)` or `wvf2oi(...)`).
    - compute method commonly set to `'opticsotf'` (DL) or `'opticspsf'` (SI); uniform/black cases may clear it.
  - `wvf` (struct/[]) wavefront struct when relevant.
  - `scene` (struct/[]) returned for uniform cases (`uniform ee` returns both).

### `oiCompute(oi, scene, varargin)`
- **Purpose**: Convert scene spectral radiance into sensor-plane spectral irradiance using the optics model.
- **Required inputs**:
  - `oi` (opticalimage struct). Also supports `oi.type == 'wvf'` as a special case.
  - `scene` (scene struct)
- **Key optional parameters**:
  - `'pad value'` (default `'zero'`): padding mode passed into OTF/PSF compute path.
  - `'crop'` (logical, default `false`): crop padded border after compute.
  - `'pixel size'` (meters): adjust angular width to match a desired sampling; later forces resample via `oiSpatialResample`.
  - `'aperture'` (matrix): forwarded to shift-invariant compute.
- **Output structure**:
  - Returns updated `oi` with computed irradiance photons stored via the underlying compute (`opticsDLCompute`, `opticsSICompute`, `opticsRayTrace`).
  - Also sets:
    - `oi.name` to `scene` name (`oiSet(oi,'name',sceneGet(scene,'name'))`)
    - padded depth map attached (`oiSet(oi,'depth map', ...)`)
    - optional crop (`oiCrop(oi,'border')`)
    - `oi.metadata` appended with scene metadata (`appendStruct(oi.metadata, scene.metadata)`)

---

## Sensor

### `sensorCreate(sensorType, pixel, varargin)`
- **Purpose**: Create a `sensor` struct describing pixel array geometry + CFA/filter spectra + noise/quantization settings.
- **Required inputs**:
  - `sensorType` optional; default `'default'` (Bayer GRBG).
  - `pixel` optional; default `pixelCreate('default')`.
- **Key optional parameters**:
  - Depends strongly on `sensorType` (Bayer variants, vendor parts, multispectral, human cone mosaic, light field, dual pixel, custom filter arrays).
  - Special overloads:
    - `'lightfield'` / `'dualpixel'` allow passing an `oi` in place of `pixel`.
  - Many parameters are set after creation via `sensorSet` (e.g., `'size'`, `'pattern'`, `'noise flag'`, `'integrationTime'`, `'autoexposure'`, etc.).
- **Output structure**:
  - Returns `sensor` with at least:
    - `sensor.type = 'sensor'`, `sensor.name`
    - `sensor.pixel` (pixel struct) and inherited `sensor.spectrum`
    - `sensor.data` initialized empty; key later fields typically live in `sensor.data.volts` and `sensor.data.dv`
    - default noise/quantization-related fields initialized (analog gain/offset, FPN images, `quantization` default `'analog'`, `noise flag` default `2`)

### `sensorCompute(sensor, oi, showBar)`
- **Purpose**: Compute sensor response (volts and/or digital values) from an optical image.
- **Required inputs**:
  - `sensor` (sensor struct, or cell array). If omitted/empty: uses `vcGetSelectedObject('sensor')`.
  - `oi` (opticalimage struct). If omitted/empty: uses `vcGetSelectedObject('oi')`.
- **Key optional parameters**:
  - `showBar` (logical): waitbar control; default `ieSessionGet('waitbar')`.
  - Most behavior is controlled via **sensor parameters** (not function varargin), notably:
    - exposure (`integrationTime`, `auto exposure`, bracketing/burst)
    - `noise flag`
    - `quantization method` (`analog`, `linear`, `sqrt`, ...)
- **Output structure**:
  - Returns `outSensor` (same shape as input sensor array) with:
    - `sensor.data.volts` set (and clipped to voltage swing)
    - optionally `sensor.data.dv` set when quantization is not `'analog'`
    - exposure may be updated by `autoExposure(...)`
    - metadata copied/augmented (stores sensor/scenename/opticsname; appends `oi.metadata` into sensor metadata)

---

## Image processing

### `ipCreate(ipName, sensor, display, L3)`
- **Purpose**: Create an image processing struct (`vcimage`) and initialize default processing settings.
- **Required inputs**:
  - `ipName` optional; default `'default'`.
  - `sensor` optional; if provided, `ip.data.input` and `datamax` are initialized from `sensorGet(sensor,'dv or volts')`.
  - `display` optional; string or struct. If omitted, uses `displayCreate('lcdExample.mat','wave', ipGet(ip,'wave'))`.
  - `L3` optional; attached only when `ipName` starts with `'L3'`.
- **Key optional parameters**:
  - The main “knobs” are set after creation via `ipSet` (transform, demosaic, illuminant correction, internal CS, conversion method).
- **Output structure**:
  - Returns `ip` with:
    - `ip.type = 'vcimage'`, default spectrum set (`initDefaultSpectrum(...,'hyperspectral')`)
    - `ip.data.input` possibly initialized
    - `ip.display` set
    - `ip.render.renderflag = 'rgb'`, `ip.render.scale = true`

### `ipCompute(ip, sensor, varargin)`
- **Purpose**: Run the image processing pipeline from sensor mosaic values to rendered image.
- **Required inputs**:
  - `ip` (struct, `ip.type == 'vcimage'`)
  - `sensor` (struct, `sensor.type == 'sensor'`)
- **Key optional parameters**:
  - HDR whitening controls: `'hdr white'` (logical), `'hdr level'` (fraction), `'wgt blur'`.
  - `'saturation'` override.
  - `'network demosaic'` (string) uses a special ONNX/Python path if configured.
- **Output structure**:
  - Updates `ip.data` slots:
    - `ip.data.input` (double sensor values)
    - `ip.data.sensorspace` (demosaicked / sensor-space representation)
    - `ip.data.result` (processed image in lrgb, typically in [0,1])
  - Also updates `ip.datamax` based on whether input is volts vs digital values.

---

## Display

### `displayCreate(displayName, varargin)`
- **Purpose**: Create/load a calibrated display struct (SPD primaries + gamma) used by rendering.
- **Required inputs**:
  - `displayName` optional; default `'LCD-Apple'`.
- **Key optional parameters**:
  - Any key/value supported by `displaySet`; commonly `'wave'` to resample.
  - Special names: `'default'`, `'equal energy'`.
  - Otherwise expects a `.mat` file containing variable `d`.
- **Output structure**:
  - Returns `d` with:
    - `d.type = 'display'`, name set
    - `d.wave`, `d.spd` (primary spectra), `d.gamma`
    - viewing parameters `d.dpi`, `d.dist`
    - `d.image` initialized to `[]`
