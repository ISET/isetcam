function [out]= clip(in, low, high)
%out= clip(in, low, high)
% Clips data (scalar, vector or matrix) so that for every element
% LOW <= IN<= HIGH. LOW can be '-inf', and HIGH can be 'inf', for
% one sided operations.
%
% data   = input matrix, vector or scalar
% low    = lower scalar value
% high   = (optional) upper scaler value
% out    = clipped output data.
%
%Examples:  out = clip(in, 0)  all   values < 0 set = 0
%           out = clip(in, 0, 255)   clip to [0, 255]
%           out = clip(in, -inf, 10) out < or = 10
%        
%Peter Burns 16 March 2004

if isempty(in), out=[];
 return;
end
if nargin < 2
 out = in;
 return;

elseif nargin ==2
 out = max(in, low);
 return

else
 out = max(in, low);
 out = min(out, high);
end
