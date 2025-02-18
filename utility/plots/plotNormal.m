function fig = plotNormal(m, s)
% Plots a normal distribution with specified mean and standard deviation.
%
% Synopsis
%  fig = plotNormal(m, s)
%
% Input:
%   m: Mean of the normal distribution.
%   s: Standard deviation of the normal distribution.
%
% See also
%

% Example:
%{
  fig = plotNormal(10,2);
  axesHandles = findobj(fig, 'Type', 'axes');
  gCurve = findobj(axesHandles,'Type','line')
%}

% Generate x-values for the plot.  We'll go out a few standard deviations
% on either side of the mean for a good visualization.  Adjust the range
% as needed.
x = linspace(m - 4*s, m + 4*s, 100);  % 100 points for a smooth curve

% Calculate the probability density function (PDF) of the normal distribution.
y = (1 / (s * sqrt(2*pi))) * exp(-((x - m).^2) / (2*s^2));

% Could use y = normpdf(x,m,s), from the statistics toolbox
% But we implemented the formula, directly.
%
% Create the plot.
fig = ieNewGraphWin;
plot(x, y, 'k-', 'LineWidth', 2); % Blue solid line, 2 pixels wide

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