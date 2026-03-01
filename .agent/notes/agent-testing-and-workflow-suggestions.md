# Agent-Based Coding Suggestions for ISETCam

Date: 2026-02-28

## Context
You have a mature, script-based validation framework in `isetvalidate` (for example `v_icam_*` tests), and you are beginning to add agent workflows directly in the `isetcam` repository.

This note recommends a practical path that preserves current validation value while enabling incremental modernization.

## Recommended Testing Strategy (Hybrid)

### 1) Keep `isetvalidate` as the system/regression backbone
- Continue using existing `v_icam_*` validations for broad behavioral coverage.
- Keep existing numeric-baseline checks with explicit tolerances.
- Treat this suite as the long-horizon compatibility signal.

### 2) Add function-local tests in `isetcam`
- For each source folder, colocate tests in a sibling folder named `_tests_`.
- Suggested naming convention: `ieTest_<functionname>.m`.
- Example for scene pattern code:
  - Source: `isetcam/scene/pattern/sceneFluorescenceChart.m`
  - Test: `isetcam/scene/pattern/_tests_/ieTest_sceneFluorescenceChart.m`

### 3) Test structure per function
Each `ieTest_<functionname>.m` should include:
1. API/shape checks (sizes, metadata fields, expected dimensions)
2. Mapping checks (index-to-parameter mapping)
3. Golden-value checks (fixed numeric fingerprint + tolerance)
4. Input-validation checks (expected errors for invalid args)

## Naming and Tolerance Conventions
- Use named tolerance variables (for example `goldenTol = 1e-9`) rather than hard-coded literals repeated in assertions.
- Keep tolerances near their check block and document why the value is chosen.
- Prefer a small set of stable fingerprint metrics for golden tests (for example sum, norm, selected indices), not every element unless needed.

## Migration Guidance for `runtests` / `matlab.unittest`
- No immediate migration is required.
- If desired later, migrate incrementally by wrapping new local tests first.
- A practical order:
  1. New work uses `ieTest_*` colocated files.
  2. Add lightweight runners to execute grouped `ieTest_*` folders.
  3. Convert selected high-value `v_icam_*` scripts when there is clear benefit.

## Agent Workflow Suggestions for `isetcam/.agent`

Suggested starter layout:

- `.agent/notes/` — design decisions, test policy, migration notes
- `.agent/workflows/` — reusable workflow prompts/checklists (bugfix, feature, refactor, release)
- `.agent/templates/` — templates for test files, change summaries, and migration PR notes
- `.agent/runners/` — optional helper scripts to run local + validate suites consistently

## Suggested Initial Workflows
1. **Feature workflow**
   - Add/modify function
   - Add/update colocated `ieTest_*`
   - Run focused tests
   - Run relevant `isetvalidate` subset
   - Record migration note if behavior intentionally changes

2. **Regression workflow**
   - Reproduce issue
   - Add failing golden/characterization test
   - Implement fix
   - Re-run focused and broader suites

3. **Refactor workflow**
   - Add characterization checks first
   - Refactor in small steps
   - Keep public API and numerical behavior stable unless explicitly changing

## Practical Recommendation
Adopt the hybrid model now:
- Keep `isetvalidate` unchanged for stability.
- Build new function-level coverage in colocated `_tests_` using `ieTest_<functionname>.m`.
- Defer framework-wide migration until you have enough new tests to justify standardization effort.

This gives immediate productivity with low risk.
