function obj = gatherStruct(obj)
% Gather distributed struct to current working directory
%
% Syntax:
%	function obj = gatherStruct(obj)
%
% Description:
%    Gather distributed struct to current working directory. This
%    function is only useful in context of gpu  computing. If there's
%    no distributed field (e.g. gpuArray) in obj, the output will be
%    the same as the input.
%
% Inputs:
%	 obj  - A variable or structure, for structure, we will gather
%           recursively for all its sub-field(s)
%
% Outputs:
%	 obj  - The gathered obj
%
% Optional key/value pairs:
%    None.
%
% Notes:
%
% See Also:
%	 gather, vcAddObject, vcAddAndSelectObject
%

% History:
%    xx/xx/14  HJ   ISETBIO TEAM, 2014
%    12/15/17  jnm  Formatting
%    01/19/18  jnm  Formatting update to match Wiki.

% Examples:
%{
    scene = sceneCreate;
    scene = gather(scene);
%}

if notDefined('obj'), obj = []; return; end

if isstruct(obj)
    fNames = fieldnames(obj);
    for ii = 1:length(fNames)
        obj.(fNames{ii}) = gatherStruct(obj.(fNames{ii}));
    end
elseif isa(obj, 'gpuArray')
    obj = gather(obj);
end

end