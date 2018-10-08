function y=MonitorGamma(x,x0,g)
% y=MonitorGamma(x,x0,gamma)
%
% This function is commonly used to describe the "gamma" function of a video
% monitor. x represents input voltage and y represents luminance. There are two
% parameters: threshold x0, and the exponent gamma. In my applications, x and y
% have been normalized so that the gamma curve always goes through (0,0) and (1,1),
% so I've built that constraint into the function:
%    if x<=x0 then y=0
%    if x>x0 then y=((x-x0)/(1-x0))^gamma
% The arguments can be scalars or matrices; MonitorGamma will do the right thing.
% Note that it is unreasonable for x0 to be outside the unit interval, or for g to
% be negative, but these constraints are not enforced here.
%
% See MonitorGammaError.
%
% Denis Pelli 5/28/96

x=(x-x0)./(1-x0);
y=zeros(size(x));
i=find(x>0);
if ~isempty(i)
	y(i)=x(i).^g;
end
