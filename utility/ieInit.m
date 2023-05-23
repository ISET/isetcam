%% ieInit
%
% This script
%
%   * Closes down any current ISET session
%   * Clears the workspace
%   * Starts a fresh version of ISET
%   * Hides the main window
%
% We might want to clear out the ISET session file to prevent it from
% loading with the new ISET session.
%
% Copyright ImagEval Consultants, LLC, 2011.

%% Make sure we don't have both isetcam and isetbio in our path
%  This test is not great.   But the idea is that imgproc is not in isetbio.
% if ieContains(path,'imgproc') && ieContains(path,'cones')
%     error("Isetcam & Isetbio contain over-lapping functionality. Only one at a time should be in your path");
% end

if ieContains(version,'2019b')
    warning('Windows do not run correctly under version 2019b');
end

%% Close the ISET windows and all others

% Close the ISET windows and remove any invalid apps
ieMainClose;

% Close the other windows
close all

% Clear vcSESSION
clear global;  % Made consistent with ISETBIO

% There has been some indecision about whether to clear all or not in this
% command.  So, I am making it a settable preference for now.  I had a need
% to make it settable when producing the tutorials.  So, let's try it for a
% while.

% In ISETBIO this is false.
% Determine if you want to clear session variables
if ieSessionGet('init clear'), clearvars;  end


%% Initialize ISET database variable

ieInitSession;

% Load required packages if running under GNU Octave.
if ~isempty(ver('Octave'))
    pkg load general
    pkg load image
    pkg load io
    pkg load optiminterp
    pkg load signal
    pkg load statistics
    warning('off', 'Octave:data-file-in-path')
end

%%
