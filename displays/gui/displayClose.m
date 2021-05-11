function displayClose(varargin)
% DEPRECATED
%
%     This is GUI callback function which is invoked when the display
%     window is to be closed.
%
%  (HJ) May, 2014

% Close figure
global vcSESSION;

if checkfields(vcSESSION, 'GUI', 'vcDisplayWindow')
    vcSESSION.GUI = rmfield(vcSESSION.GUI, 'vcDisplayWindow');
end

closereq;

end