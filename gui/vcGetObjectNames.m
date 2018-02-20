function objNames = vcGetObjectNames(objType)
% Compile a list of object names from vcSESSION variable
%
%   objNames = vcGetObjectNames(objType)
%
% Returns the names of current objects of a given standard type. 
% This routine also checks for empty objects, which sometimes arise because
% of runtime errors, and deletes any empty objects of the given type.
%
% Example
%  vcGetObjectNames('oi')
%
% Copyright ImagEval Consultants, LLC, 2005.

%% PROGRAMMING
%
% Perhaps this should be done in some more open way, rather than buried
% inside of this routine

if ieNotDefined('objType'), objType = 'scene'; end

objects = vcGetObjects(objType);
nObj = length(objects);

% There may be just one, empty object.  In which case, send back a null
% list of names.
if nObj == 1 && isempty(objects{1})
    objNames = [];
    % nObj = 0;
    return;
else
    % Sometimes during programming empty objects arise.  This can happen
    % because of run time errors.  This routine identifies any empty objects
    % and deletes them
    deleteList = [];
    for ii=1:nObj
        if isempty(objects{ii})
            deleteList = [deleteList,ii]; %#ok<AGROW>
        end
    end
    
    % Sort the list from highest to lowest.  This prevents renumbering the
    % objects in the list as we delete. For example, if we delete 4 and 6, then
    % deleting 6 first leaves 4 in the 4th position.
    deleteList = sort(deleteList,'descend');
    for ii=1:length(deleteList)
        vcDeleteObject(objType,deleteList(ii));
    end
    
    % Every remaining object should have a name.
    objects = vcGetObjects(objType); 
    nObj = length(objects);
    for ii=1:nObj
        if ~checkfields(objects{ii},'name')
            warning('Missing object name.  %s\n',objType);
        end
        objNames{ii} = objects{ii}.name; %#ok<AGROW>
    end
end

return


