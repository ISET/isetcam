function ieInstall
%Install libraries and framework for ISET mex-files.
%
%   ieInstall
%
% This routine verifies the two ISET mex-files, md5 and ieGetMACAddress.
%
% In recent versions of Matlab, mex-files on PC Windows require Visual
% Studio C redistribution libraries. The executables can be obtained using
% the executables in isetRootPath/dll70/vcredist_XXX.exe.
%
% To learn more about the mex-files issues see the Mathworks page:
%
% http://www.mathworks.com/support/solutions/data/1-2223MW.html
%
% Copyright ImagEval Consultants, LLC, 2008.

fprintf('ISET mex-file verification.\n');

%% Test to see whether md5 is running on this computer
try
    tmp = md5('a');
    if strcmp(tmp,'0cc175b9c0f1b6a831c399e269772661')
        fprintf('  md5 is functioning.\n');
        
        % Check for shadow copy of md5
        if strcmp(computer,'PCWIN')
            [p,n,e] = fileparts( which('md5'));
            if strcmpi(e,'.mexw32')
                % Delete the dll version
                t = which('md5.dll');
                if ~isempty(t), delete(t); end
            end
        end
    else
        fprintf('md5 tuns but returns a bad value. Should never happen.')
    end
catch ME
    ME.stack,
    warndlg('Please run ieVCRedistribution or select (Initialize | Microsoft Lib) from the main window pulldown menu.');
    fprintf('Please run ieVCRedistribution\n or select (Initialize | Microsoft Lib) from the main window pulldown menu.\n');
end

%% Test ieGetMACAddress
try
    tmp = ieGetMACAddress;
    if length(tmp)==17
        fprintf('  ieGetMACAddress is functioning.\n');

        % Check for shadow copy of ieGetMACAddress
        if strcmp(computer,'PCWIN')
            [p,n,e] = fileparts( which('ieGetMACAddress'));
            if strcmpi(e,'.mexw32')
                % Delete the dll version
                t = which('ieGetMACAddress.dll');
                if ~isempty(t), delete(t); end
            end
        end
        return;
    else
        fprintf('ieGetMACAddress tuns but returns a bad value. Should never happen.')
    end
catch ME
    ME.stack
    warndlg('ieGetMACAddress needs to be compiled for this platform.');
end
   
return;




