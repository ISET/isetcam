function fig = plotNormal(m, s, varargin)
% Plot normal distributions with specified mean and standard deviation.
%
% Synopsis
%  fig = plotNormal(m, s, varargin)
%
% Input:
%   m: Vector of means of the normal distribution.
%   s: Vector of standard deviations of the normal distribution.
%
% Key/Val
%   color - Cell array of possible colors
%
% See also
%   xaxisLine, identityLine, plotRadiance

% Example:
%{
  fig = plotNormal(10,2);
  axesHandles = findobj(fig, 'Type', 'axes');
  gCurve = findobj(axesHandles,'Type','line')
%}
%{
  fig = plotNormal([1 2],[0.1 .5],'color',{'k','r'});
%}

%% Parse inputs
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('m',@isnumeric);
p.addRequired('s',@isnumeric);
p.addParameter('color','',@iscell);
p.parse(m,s,varargin{:});
color = p.Results.color;

% Generate x-values for the plot.  We'll go out a few standard deviations
% on either side of the min and max mean for a good visualization.  Adjust
% the range as needed.
x = linspace(min(m) - 4*max(s), max(m) + 4*max(s), 200);  % 100 points for a smooth curve

fig = ieNewGraphWin;

for ii=1:numel(m)

    % Calculate the probability density function (PDF) of the normal distribution.
    y = (1 / (s(ii) * sqrt(2*pi))) * exp(-((x - m(ii)).^2) / (2*s(ii)^2));

    % Could use y = normpdf(x,m,s), from the statistics toolbox
    % But we implemented the formula, directly.
    %
    % Create the plot.

    plot(x, y, [color{ii},'-'], 'LineWidth', 2); % Blue solid line, 2 pixels wide

    hold on;

end

% Add labels and title.
xlabel('x');
ylabel('Probability Density');
% title(['Normal Distribution (m = ' num2str(m) ', s = ' num2str(s) ')']);

% Add a grid for better readability (optional).
grid on;

% Make sure the plot looks nice.
axis tight; % Removes extra whitespace around the plot
% You can also set specific axis limits if you want:
% xlim([m - 5*s, m + 5*s]);  % Example: x-axis from mean +/- 5 std dev
% ylim([0, max(y)*1.1]); % Example: y-axis from 0 to a little above the max PDF value

end