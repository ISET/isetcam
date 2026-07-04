# Publishing Tutorials and Examples

ISETCam provides `iePublish` and the `s_publish*.m` helper scripts for
converting MATLAB tutorials and examples into HTML files that can be linked
from wiki pages.

The publishing helpers are intended to create self-contained HTML files. Figures
are embedded directly in the HTML as base64 images, so the result can be served
as one file without copying a companion folder of PNG files.

## Publish One File

From a MATLAB session with ISETCam on the path:

```matlab
htmlFile = iePublish('tutorials/scene/t_sceneIntroduction.m');
web(htmlFile, '-browser');
```

For tutorials in a dependent repository, pass the full path to the source
script after that repository is on the MATLAB path:

```matlab
htmlFile = iePublish(fullfile(isetbioRootPath, ...
    'tutorials', 'cmosaic', 't_cMosaicBasic.m'));
```

`iePublish` writes the HTML file next to the source `.m` file, using the same
base name and the `.html` extension.

## Publish a Set of Files

ISETCam provides these batch scripts:

```matlab
s_publishTutorials
s_publishExamples
```

Both scripts call `iePublish` with `imageFormat` set to `'inline'`. This is the
setting that embeds figures in the HTML and makes the output suitable for
serving from a web page and linking from a wiki.

The default `s_publishTutorials` run publishes all known ISETCam tutorial
directories. The default `s_publishExamples` run currently publishes the
selected example directory listed in the script; edit `sDir` in that file to
publish a different example subset.

## Useful Options

The defaults are chosen for wiki-linkable tutorial output:

```matlab
htmlFile = iePublish(sourceFile, ...
    'evalCode', true, ...
    'showCode', true, ...
    'imageFormat', 'inline', ...
    'maxHeight', 512, ...
    'maxWidth', 512);
```

Common adjustments are:

- `evalCode`: Set to `false` for a quick code-only preview. Figures and command
  output are only regenerated when this is `true`.
- `showCode`: Set to `false` when the HTML should show output without source
  code.
- `maxHeight` and `maxWidth`: Resize embedded figures for more manageable HTML
  pages.
- `catchError`: Leave as `true` for most publishing runs so one script error
  does not terminate a batch unexpectedly.
- `stylesheet`: Pass a CSS file when a project needs custom HTML styling.

For wiki-linked pages, keep `imageFormat` set to `'inline'`. Other formats,
such as `'png'`, require the external image files to be copied and linked along
with the HTML file.

## GitHub and Wiki Links

The generated files are ordinary HTML and should render correctly when served
as HTML, for example from GitHub Pages or another static web server. A GitHub
repository `blob` URL may show the HTML source instead of rendering the page;
use a served HTML URL when linking from wiki pages.

## Recommended Workflow

1. Edit and run the tutorial or example interactively.
2. Close unrelated figures and make sure the script runs without manual input.
3. Publish the script with `iePublish`, `s_publishTutorials`, or
   `s_publishExamples`.
4. Open the generated HTML locally and inspect the figures, output, and links.
5. Commit the source `.m` file and the generated `.html` file when the project
   tracks published HTML.
6. Link the served HTML file from the relevant wiki page.

Re-run the publisher whenever the source tutorial or example changes. Embedded
figures make the generated HTML self-contained, but they can also make the file
large, so use the figure-size options when a script creates large displays.
