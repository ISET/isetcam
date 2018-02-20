function [slope, offset] = ieFitLine(x,y,method)
%Fit a line to the data in x,y
%
%    [slope, offset] = ieFitLine(x,y,[method])
%
%   Solve least squares line y = a*x + b
%   Returns slope (a) and offset (b)
%
%   The data must be in the columns of x and y
%   
%   methods:
%   {'oneline','onelineleastsquares','leastsquares'}
%   {'multiplelines','multiplelinesleastsquares'}
%
%   This routine has not been used yet or debugged carefully.
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('method'), method = 'leastSquares'; end
method = ieParamFormat(method);

nData = size(y,2);
nSamples = size(y,1);
   
% We can have one x-variable generating many y-variables, such as one
% exposure time list producing voltages at many pixels
if nData > 1 && size(x,2) == 1
    % Could set up a flag and just store the x variable once, rather than
    % waste space like this
    x = repmat(x,1,nData);
end

switch method
    case {'oneline','onelineleastsquares','leastsquares'}
        x = [x(:), ones(length(x),1)];  y = y(:);
        val = pinv(x)*y;
        slope  = val(1);
        offset = val(2);
        % There is a simpler formula.  Must re-derive and use it instead of
        % this.
    case {'multiplelines','multiplelinesleastsquares'}

        % y = Ax, so we solve x = A\y;
        onesCol = ones(nSamples,1);
        
        for ii=1:nData    
            thisX = [x(:,ii), onesCol]; 
            val = pinv(thisX)*thisY;
            slope(ii) = val(1);
            offset(ii) = val(2);
        end
        
    otherwise
        error('unknown method')
end

return;