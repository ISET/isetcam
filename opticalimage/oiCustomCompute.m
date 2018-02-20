function [bool,customOI] = oiCustomCompute(oi);
% Check whether the user has selected custom compute method
%
%     [bool,customOI] = oiCustomCompute(oi);
%
% If bool = 1, custom computation is selected. The name of the method can be
% returned in customOI.  The existence of the method is verified. 
% 
% The routine first checks whether the OI stores custom compute
% information.  If there are no data structures in the OI, then the routine
% checks the GUI
%
% Copyright ImagEval Consultants, LLC, 2005.

% TODO:
%  This routine is a historical artifact that exists because we stored the
%  custom compute only in the window at first.  Now we have OI variables
%  that store the customCompute state, so that this routine should probably
%  go away and be replaced by oiGet(oi,'customCompute') and
%  oiGet(oi,'customComputeMethod')

warning('oiCustomCompute: Obsolete')

if ieNotDefined('oi'), oi = vcGetObject('OI'); end
customOI = [];

bool = oiGet(oi,'customCompute');
if ~bool, return;
elseif bool && (nargout == 2)
    customOI = oiGet('customComputeMethod');
elseif isempty(bool)
    handles = ieSessionGet('oiwindowHandles');
    if ~isempty(handles) && get(handles.btnCustom,'Value')
        bool = 1;
        if nargout == 2
            contents = get(handles.popCustom,'string');
            customOI = contents{get(handles.popCustom,'value')};
        end
    end
end

if (nargout ==2) && (exist(customOI) ~= 2)
    errordlg('Customer oiCompute function not found.');
    bool = 0;
    return;
end

return;
