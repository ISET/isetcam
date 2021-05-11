%% t_codeStartup.m
%
% DEPRECATED
% deprecated
%
%  When you start Matlab, it looks for a file called startup.m on your path
%  and runs it. Many users have a personal startup.m file on their Matlab
%  path.
%
%  I have a directory named "paths" that I always keep on my Matlab path. I
%  keep my startup.m file  as well as various other path management files
%  in that directory.
%
%  This tutorial describes some simple ways to organize a startup.m file.
%
% Copyright ImagEval Consultants, LLC, 2012.

% %% Clear the Matlab path to its default state.  Add ISET.
%
% % This includes the toolboxes, but nothing else.
% restoredefaultpath;
%
% % Add the ISET directories.
% iset4Dir = 'C:\users\brian\Matlab\SVN\ISET-4.0';
% addpath(genpath(iset4Dir));
%
% %% Managing paths for different Matlab packages
%
% % You might use this method if you have different Matlab packages in
% % different programming sessions.
%
% % Set up the default path
% restoredefaultpath;
%
% % Add the directory that contains all of the functions you will use to set
% % up paths.  In this example, we have isetPath() and ptbPath() both in this
% % directory.
% addpath('C:\users\brian\Matlab\paths');
%
% % Use a line like this to select which paths you would like to include:
% resp = input('Enter: 1 (ISET4), 2 (ISET4-PTB) OR None: ');
%
% % Depending on the resp, you can use a switch statement to invoke the
% % functions that add the packages to your path.
% switch resp
%
%     case 1
%         % ISET
%         isetPath(iset4Dir);
%         chdir(iset4Dir);
%         disp('ISET path.')
%
%     case 2
%         % ISET and Psychtoolbox
%         isetPath(iset4Dir);
%         ptbPath(ptbDir);
%         disp('ISET and Psychtoolbox path.')
%
%     otherwise
%         disp('Default Matlab path.')
% end

%% End
