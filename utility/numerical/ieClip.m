function im = ieClip(im,lowerBound, upperBound)
%Clip data to range specified arguments.
%
%    im = ieClip(im,[lowerBound], [upperBound])
%
% Purpose:
%   Various types of clipping of data are supported.  These are
%
%    ieClip(im,[],255) sets the upper bound to 255, no lower bound
%    ieClip(im,0,1)    sets the lower to 0 and upper to 1
%    ieClip(im,0,[])   sets the lower to 0, no upper bound
%    ieClip(im)        defaults to 0 1 range
%    ieClip(im,bound)  sets bound to +/- bound
%
% See also
%

% Examples:
%{
   im = 2*randn([5,5])
   ieClip(im,[],1)
   ieClip(im,0,[])
   ieClip(im,1.35789)
%}


% Set up various
if nargin == 1
    % Only im sent in.  Default is [0,1]
    lowerBound = 0;
    upperBound = 1;
    disp('ieClip:  Setting range to 0 1');
elseif nargin == 2
    % Reads this as [-l,l]
    lowerBound = -abs(lowerBound);
    upperBound = abs(lowerBound);
    s = sprintf('ieClip:  Setting range to [%.3e,%.3e]',lowerBound,upperBound);
    disp(s);
end

if ~(~exist('lowerBound','var') || isempty(lowerBound))
    im(im<lowerBound) = lowerBound;
end

if ~(~exist('upperBound') || isempty(upperBound))
    im(im>upperBound) = upperBound;
end

return;


