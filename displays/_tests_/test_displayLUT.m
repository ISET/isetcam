function tests = test_displayLUT()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_displayLUT
%
%  Illustrate the use of the LUT conversion routines based on display gamma
%  and display inverse gamma tables. 
%
%  * Read a gamma table from a display and plot it
%  * Invert the gamma table and plot it
%  * Start with linear RGB and compute the nonlinear DAC (ieLUTLinear)
%  * Start with the DAC and recover the linear RGB (ieLUTDigital)
%  * Compare original RGB and recovered RGB
%
%
%  Use displayList; to get a set of possible displays
%
% See also
%  ieLUTInvert, ieLUTLinear, ieLUTDigital, displayList, dac2rgb, rgb2dac

%%
ieInit

%% Get a gamma table from a calibrated display

%d = displayCreate('OLED-Sony');
d = displayCreate('LCD-Apple');
gTable = displayGet(d,'gamma table');

igTable = ieLUTInvert(gTable,size(gTable,1));
assert(isequal(size(igTable),size(gTable)));

%% Suppose rgb is
RGB = repmat(linspace(0.1,1,10)', 1,3);
dac = ieLUTLinear(RGB,igTable);
assert(isequal(size(dac),size(RGB)));
assert(all(dac(:) >= 0));
assert(all(dac(:) <= size(gTable,1)));

%% Suppose we start with the DAC value and want linear RGB

estRGB = ieLUTDigital(round(dac),gTable);

%% Validate
assert(max(estRGB(:) - RGB(:)) < 0.01);

%% Now use the rgb2dac and dac2rgb variations

RGB = repmat(linspace(0.1,1,10)', 1,3);
dac = rgb2dac(RGB,igTable);
assert(isequal(size(dac),size(RGB)));
assert(all(dac(:) >= 0));
assert(all(dac(:) <= size(gTable,1)));

estRGB = dac2rgb(round(dac),gTable);

%% Validate
assert(max(estRGB(:) - RGB(:)) < 0.01);

%% END

end
