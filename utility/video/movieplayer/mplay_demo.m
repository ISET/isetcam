echo on
% Demonstrate MPLAY movie player and various movie formats

% Load movie data
%       I: intensity image frames, 3-D array
load video1
%   R,G,B: intensity image frames, each one a 3-D array.
%          representing the RGB planes of a color video
load video2

% Convert data to various movie types

% Basic intensity movie: 3-D array, MxNxF
% I (no conversion necessary)

% MATLAB movie structure, containing intensity images
Q = int2struct(I);

% RGB movie array: 4-D array, MxNx3xF
P = int2rgbm(R,G,B);

% MATLAB movie structure, containing RGB images
R = int2struct(R,G,B);

whos

% Launch movie players
mplay(I);
%mplay(P);
mplay(Q);
%mplay(R);

% Also, try this:
%   crulspin  % or, logospin
% Run logospin, a standard MATLAB demo of a rotating L-shaped
% membrane.  Watch as the movie being is constructed and 
% watch the standard MATLAB movie playback.  Then, use MPLAY.
% logospin; mplay(m)
% crulspin; mplay(m)

