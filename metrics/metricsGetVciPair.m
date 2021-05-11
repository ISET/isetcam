function [vci1, vci2] = metricsGetVciPair(handles);
%
%    [vci1, vci2] = metricsGetVciPair(handles);
%
% Author:  ImagEval
% Purpose:
%    Find the two virtual camera images used for the metric comparison
%    The handles to the ISET-metrics window is passed in.

global vcSESSION

contents = get(handles.popImageList1, 'String');
vcName{1} = contents(get(handles.popImageList1, 'Value'));
contents = get(handles.popImageList1, 'String');
vcName{2} = contents(get(handles.popImageList2, 'Value'));

% Find the number of the images that have the two names
val1 = ieFindObjectByName('vcimage', vcName{1});
val2 = ieFindObjectByName('vcimage', vcName{2});

% Get the two vc images
vci1 = vcSESSION.VCIMAGE{val1};
vci2 = vcSESSION.VCIMAGE{val2};
return;