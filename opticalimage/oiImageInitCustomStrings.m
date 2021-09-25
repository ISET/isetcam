function handles = oiImageInitCustomStrings(handles);
% Initialize the strings in the OI window custom popup menu
%
%    handles = oiInitCustomStrings(handles);
%
% Purpose:
%    The popup strings in the OI window are initialized by data in the the
%    .fig file.  Then, the strings are modified using data contained in the
%    global variable, vcSESSION.CUSTOM.
%
%    The popup menu strings can also  maniuplated using the Add Custom line.
%
% Copyright ImagEval Consultants, LLC, 2005.

defaultOICompute = get(handles.popCustom,'String');
customOI =  ieSessionGet('oicomputelist');
list = cellMerge(defaultOICompute,customOI);
set(handles.popCustom,'String',list);

return;