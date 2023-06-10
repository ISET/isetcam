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
%  ieLUTInvert, displayList

%%
ieInit

%% Get a gamma table from a calibrated display


%d = displayCreate('OLED-Sony');
d = displayCreate('LCD-Apple');
gTable = displayGet(d,'gamma table');

%% Show the gamma table
ieNewGraphWin;
plot(gTable(:,1));
xlabel('DAC value'); ylabel('Linear intensity'); title('Gamma Table')
grid on;

%% Show the inverted gamma table
ieNewGraphWin;
igTable = ieLUTInvert(gTable,size(gTable,1));
plot(igTable(:,1));
ylabel('DAC value'); xlabel('Linear intensity'); title('Inverted Gamma Table')
grid on;

%% Suppose rgb is
RGB = repmat(linspace(0.1,1,10)', 1,3);
dac = ieLUTLinear(RGB,igTable);
ieNewGraphWin; plot(RGB(:,1),dac(:,1),'o');
xlabel('Linear rgb'); ylabel('DAC value'); grid on;

%% Suppose we start with the DAC value and want linear RGB

estRGB = ieLUTDigital(round(dac),gTable);
ieNewGraphWin; plot(dac(:,1),estRGB(:,1),'o');
xlabel('DAC value'); ylabel('Linear rgb'); grid on;

%% Round trip
ieNewGraphWin;
plot(RGB(:,1),estRGB(:,1),'o-');
ylabel('Estimated linear rgb');
xlabel('Original linear rgb');
grid on;
title('Round trip');
identityLine;

%% Check that we are good to less than one percent

assert(max(estRGB(:) - RGB(:)) < 0.01);

%% END
