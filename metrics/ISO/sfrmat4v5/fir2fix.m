function [correct] = fir2fix(n, m)
% [correct] = fir2fix(n, m);
% Correction for MTF of derivative (difference) filter
%  n = frequency data length [0-half-sampling (Nyquist) frequency]
%  m = length of difference filter
%       e.g. 2-point difference m=2
%            3-point difference m=3
% correct = nx1  MTF correction array (limited to a maximum of 10)
%
%Example plotted as the MTF (inverse of the correction)
%  2-point
%   [correct2] = fir2fix(50, 2);
%  3-point
%   [correct3] = fir2fix(50, 3);
%   figure,plot(1./correct2), hold on
%   plot(1./correct3,'--')
%   legend('2 point','3 point')
%   xlabel('Frequency index [0-half-sampling]');
%   ylabel('MTF');
%   axis([0 length(correct) 0 1])
%
% 24 July 2009
% Copyright (c) Peter D. Burns 2005-2009
%

correct = ones(n, 1);
m=m-1;
scale = 1;
for i = 2:n
    correct(i) = abs((pi*i*m/(2*(n+1))) / sin(pi*i*m/(2*(n+1))));
    correct(i) = 1 + scale*(correct(i)-1);
  if correct(i) > 10  % Note limiting the correction to the range [1, 10]
    correct(i) = 10;
  end
end

