function ret = checkToolbox(toolboxName)
% Checks whether certain matlab toolbox has been installed
%
%   ret = checkToolbox(toolboxName)
%
% Example:
%   ret = checkToolbox('Parallel Computing Toolbox');
%         checkToolbox('Statistics and Machine Learning Toolbox')
%
% (c) ISETBIO TEAM, 2014

% Returns all of the toolbox names
vv = ver;
ret = any(strcmp({vv.Name}, toolboxName));

end