## Goal
- Provide one reliable startup prompt for this workspace.

## Startup sequence
1. Confirm MATLAB is running and connected in VS Code.
2. If MATLAB paths are not initialized for this workspace, run:
   - `.github/prompts/startup/10-matlab-paths.prompt.md`
3. Ask what the user wants next:
   - ISETCam onboarding/context refresh: run `.github/prompts/startup/20-isetcam-onboarding.prompt.md`
   - Direct coding/debug task: proceed immediately with code-focused help.

## Default behavior
- If the user does not specify, do path setup check first, then proceed with direct coding/debug help.
