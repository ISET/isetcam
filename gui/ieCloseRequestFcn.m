function ieCloseRequestFcn
%M ethod used for closing ISET windows
%
%   ieCloseRequestFcn
%
% When we close a graph window, we set the vcSESSION.GRAPHWIN slot to
% empty.  Otherwise, we just close the window.
%
% Copyright ImagEval Consultants, LLC, 2003.

% If this is the current graph window, then we set the figure information
% to empty before exiting.
if (gcf == ieSessionGet('graph window')), ieSessionSet('graph window',[]); end

closereq;

return;