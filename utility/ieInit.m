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

%% 
