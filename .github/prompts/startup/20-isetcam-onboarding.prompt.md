## Goal
- Learn the ISETCam codebase efficiently so future assistance can use the right functions and concepts without re-discovering basics.

## Assumptions
- MATLAB is already running and connected through the VS Code MATLAB extension.
- Repository root is at:
    - `~/Documents/MATLAB/idm/oraleye-lab-images`
- ISETCam root is at:
    - `~/Documents/MATLAB/isetcam`
- oe_tongue_lip root is at:
    - `~/Documents/MATLAB/isetprojects/oe_tongue_lip`

## Efficient learning plan
- Focus on these pipeline stages and functions:
    - Scene: `sceneCreate`, `sceneAdjustIlluminant`
    - Optical image: `oiCreate`, `oiCompute`
    - Sensor: `sensorCreate`, `sensorCompute`
    - Image processing: `ipCreate`, `ipCompute`
    - Display: `displayCreate`
- For each function, extract only:
    - Purpose (1 sentence)
    - Required inputs
    - Key optional parameters
    - Output structure

## Scope constraints
- Prioritize internal understanding over user-facing formatting.
- Do not spend effort on polished reports unless explicitly requested.
- Skip runnable examples unless explicitly requested.

## Reference
- Use this notes file as needed (do not rewrite it unless asked):
    - `.github/prompts/reference/isetcam-core-pipeline.notes.md`

