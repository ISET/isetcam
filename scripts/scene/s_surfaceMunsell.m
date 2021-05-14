%% Load the Munsell chip data and create images
%
% <https://en.wikipedia.org/wiki/Albert_Henry_Munsell Albert
% Munsell> invented the
% <https://en.wikipedia.org/wiki/Munsell_color_system Munsell
% color system>.  This system is widely used by artists and
% industry to describe colors.
%
% The Munsell Corporation produced a set of surfaces that
% represent equally spaced samples in that color system.  The
% data here represent 261 little surfaces (chips) in that space.
% The surfaces are at different hue, chroma and value levels.
%
% The data include XYZ values and a specified illuminant ('C').
% We plot the illuminant and an sRGB rendering of many of the
% Munsell chips
%
% See also:  munsell.mat, chromaticity, chromaticityPlot,
%
% Copyright Imageval Consulting, LLC 2015

%%
ieInit

%% Load the data from data/surfaces in iSET
load('munsell');

%% Here are the munsell XYZ values
mXYZ = munsell.XYZ;

% Reshape
mXYZ = reshape(mXYZ,261,9,3);

% Convert to srgb
srgb = xyz2srgb(mXYZ);

% Have a look
imagesc(srgb);

%% Plot the illuminant C, which is a kind of blue sky daylight

vcNewGraphWin;
plot(munsell.wavelength,munsell.illuminant);
grid on;

%% Here are the chromaticity coordinates of the surfaces

xy = chromaticity(munsell.XYZ);
chromaticityPlot(xy,'white')

%% Here are the LAB coordinates of the surfaces

vcNewGraphWin;
plot3(munsell.LAB(:,2),munsell.LAB(:,3),munsell.LAB(:,1),'o')
grid on;
xlabel('a'); ylabel('b'); zlabel('L');

%% The data also have a representation in terms of hue and angle

% This is the famous Munsell notation
for idx = 1:45
    fprintf('Index %d: Munsell notation (hue value/chroma): %s %.1f/%.1f \n',idx,munsell.hue{idx},munsell.value(idx),munsell.angle(idx));
end

%%

