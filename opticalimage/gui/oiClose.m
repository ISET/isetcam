function oiClose(oiW)
%Deprecated:  -  Close optical image window.  Now in the app
%
% Synopsis
%    oiClose(oiW)
%
% Input
%  oiW:  oiWindow_App class
%
% Output
%   N/A
%
% Description
%  Close window function for optical image and remove figure handle from
%  vcSESSION structure.
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%

error('Moved into the App');

end
%{
% If we are closing a selected window in the database, remove it from the
% database.
W = ieSessionGet('oi window');
if isequal(W,oiW)
    ieSessionSet('oi window',[]);
end

% Close the window.
closereq;

end
%}