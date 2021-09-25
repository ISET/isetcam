function ieVCRedistribution
% Install the Visual Studio C++ 2008 libraries needed for Mex files to run
%
%   ieVCRedistribution
%
% The download for x32 installation can be found at
% http://www.microsoft.com/downloads/details.aspx?FamilyID=9b2da534-3e03-43
% 91-8a4d-074b9f2bc1bf&displaylang=en
%
% The download for the x64 installation is
% http://www.microsoft.com/downloads/thankyou.aspx?familyId=bd2a6171-e2d6-4
% 230-b809-9a8d7548c1b6&displayLang=en
%
% The runnable installation files are included in the ISET package.
%
%Example:
% ieVCRedistribution
%

%% Perform architecture dependent installation
switch(computer)
    case 'PCWIN'
        
        fprintf('Installing Visual Studio C++ 2008 redistribution (x32) package.\n')
        fprintf('This requires the Internet and may require your participation.\n')
        
        % Visual C redistributable library installation
        visCexe = fullfile(isetRootPath,'dll70','vcredist_x86.exe');
        [s,r] = dos(visCexe);
        if s == 1602,  fprintf('Status: already installed.\n');
        elseif s == 0, fprintf('Status: install OK\n');
        else           fprintf('Status: %d, Result: %s\n',s,r);
        end
        
    case 'PCWIN64'
        
        % We are not sure whether PC compiled the 64-bit files with the
        % 2008 or the 2005 package. We include the 2008 libraries.  If they
        % don't work (we don't have a 64-bit machine to test it with) then
        % we can have the user recompile the source code (ieCompile) with
        % the freely downloadable 2008 compiler.
        fprintf('Installing Visual Studio C++ 2008 redistribution (x64) package.\n')
        fprintf('This requires the Internet and may require your participation.\n')
        
        visCexe = fullfile(isetRootPath,'dll70','vcredist_x64.exe');
        [s,r] = dos(visCexe);
        
        if s == 1602,  fprintf('Status: already installed.\n');
        elseif s == 0, fprintf('Status: install OK\n');
        else           fprintf('Status: %d, Result: %s\n',s,r);
        end
        
    case 'MACI'
        disp('Mac OSX on x86');
    case 'GLNX86'
        disp('GNU Linux on x86')
    case 'GLNXA64'
        disp('GNU Linux on x86_64-bit')
    otherwise
        disp('Unknown computer type.  No action taken');
end

return;