function metricsClose
%
% Author: ImagEval
% Purpose:
%    Close window function for Metrics.

global vcSESSION;

if checkfields(vcSESSION,'GUI','metricsWindow')
    vcSESSION.GUI = rmfield(vcSESSION.GUI,'metricsWindow');
end

closereq;

return;