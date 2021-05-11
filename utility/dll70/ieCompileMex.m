function ieCompileMex(fList)
% Compile ISET mex files named in the fList cell array
%
%  ieCompileMex(fList)
%
% This routine assumes you have a compiler installed on your computer. To
% set up the Matlab mex function for a compiler you can use the command
%
%   mex -setup
%
% See the Matlab manual about compiler options.
%
% md5 is used on all architectures.
%
% ieGetMACAddress is compiled for PC architecture, but not Mac/Linux.  In
% those cases, there is an m-file implementation.  This function is not
% typically used for key/license verification.  It is used to set up the
% original, and it is used in some special cases when the license is locked
% to a particular computer (rather than a matlab-user arrangement).
%
%Example:
%   fList{1} = 'md5'; ieCompileMex(fList)
%   fList{1} = 'ieGetMACAddress'; ieCompileMex(fList)
% All files
%   ieCompileMex
%
% Copyright, ImagEval 2006

if ieNotDefined('fList')
    % All known files
    fList = {'md5', 'ieGetMACAddress'};
end

fprintf('Compiling %d ISET mex file(s): \n', length(fList));

for ii = 1:length(fList)
    switch fList{ii}
        case 'md5'
            fprintf('   md5...');
            % We have problems with move if the file exists, because the
            % file is locked by Matlab and cannot be over-written.
            if exist(['md5.', mexext], 'file')
                warning('MATLAB:deleteMD5', 'You must delete md5 for this architecture.');
                    which('md5')
                    break;
                end

                chdir(fullfile(isetRootPath, 'dll70', 'md5'));
                mex md5.cpp
                if ~exist(['./md5.', mexext], 'file')
                    error('Compilation probably for md5.')
                    else
                        movefile(['md5.', mexext], fullfile(isetRootPath, 'dll70'));
                        path(path)
                        fprintf('\ninstalled %s\n', which('md5'));

                    end

                    % Eliminate shadowing problem
                    if exist('md5.dll', 'file')
                        fprintf('Removing old md5.dll: %s\n', which('md5.dll'));
                        delete(which('md5.dll'));
                    end

                    if strcmp(md5('test'), '098f6bcd4621d373cade4e832627b4f6')
                        disp('md5 verified')
                    else
                        error('Problem with md5 verification');
                    end

                case 'ieGetMACAddress'
                    fprintf('   ieGetMACAddress...');

                    % We have problems with move if the file exists, because the
                    % file is locked by Matlab and cannot be over-written.
                    if exist(['ieGetMACAddress.', mexext], 'file')
                        warning('MATLAB:deleteMAC', 'You must delete ieGetMACAddress for this architecture.');
                            which('ieGetMACAddress')
                            break;
                        end
                        chdir(fullfile(isetRootPath, 'license', 'src'));
                        if strncmp(computer, 'PC', 2)
                            fprintf('PC architecture ... ')
                            mex ieGetMACAddress_PC.cpp netapi32.lib
                            if ~exist(['./ieGetMACAddress_PC.', mexext], 'file')
                                error('Compilation problem for ieGetMACAddress_PC.')
                                else
                                    movefile(['ieGetMACAddress_PC.', mexext], ...
                                        fullfile(isetRootPath, 'dll70', ['ieGetMACAddress.', mexext]));
                                    fprintf('\ninstalled %s\n', which('ieGetMACAddress'));
                                end
                            else
                                fprintf('For Linux/Apple architectures\n')
                                fprintf('we use the m-file.\n');
                            end

                            % Eliminate shadowing problem
                            if exist('ieGetMACAddress.dll', 'file')
                                fprintf('Removing old ieGetMACAddress.dll: %s\n', which('ieGetMACAddress.dll'));
                                delete(which('ieGetMACAddress.dll'));
                            end

                            % MAC address
                            fprintf('Your MAC address is: %s \n', ieGetMACAddress)

                        otherwise
                            error('Unknown file %s\n', fList{ii});

                        end
                    end

                    return;