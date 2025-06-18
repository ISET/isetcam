%% FISE Defaults
%
% See the bottom for some code that creates a nice looking plot and
% was the inspiration for this setup.  This is still a work in
% progress.
%
% See also
%   nicePlot.m

% Maybe I should try 'Helvetica'

% Set default Axes properties on the graphics root (groot)
set(groot, 'DefaultAxesFontName', 'Georgia');
set(groot, 'DefaultAxesFontSize', 16);
set(groot, 'DefaultAxesBox', 'off');
set(groot, 'DefaultAxesTickDir', 'out');
set(groot, 'DefaultAxesLineWidth', 1.2);
set(groot, 'DefaultAxesXColor', [0.3 0.3 0.3]);
set(groot, 'DefaultAxesYColor', [0.3 0.3 0.3]);

% --- Optional: Set related font defaults for consistency ---
% Axes title, labels, legends, and text objects often use Text properties
set(groot, 'DefaultTextFontName', 'Georgia');
set(groot, 'DefaultTextFontSize', 12); % Match axes font size or adjust
set(groot, 'DefaultTextColor', [0.3 0.3 0.3]); % Match axis color

% Legend properties (can also inherit from Text, but can be set explicitly)
set(groot, 'DefaultLegendFontName', 'Georgia');
set(groot, 'DefaultLegendFontSize', 11); % Slightly smaller is common
set(groot, 'DefaultLegendTextColor', [0.2 0.2 0.2]);
set(groot, 'DefaultLegendBox', 'off'); % Default legend box off

%% This test is failing.  Will try rebooting.

%{
% Ensure the default is set (or reset it)
set(groot, 'DefaultAxesTickDir', 'out');
disp(['Default TickDir is: ', get(groot, 'DefaultAxesTickDir')]); % Verify again

% Create a completely new figure and simple plot
figure;
plot(1:10);
title('Minimal Test Plot');

% Get the handle of the *current* axes and check its actual property
ax_test = gca;
actual_tickdir = get(ax_test, 'TickDir') % Or use ax_test.TickDir
%}

%{
% --- Data ---
x = linspace(0, 2*pi, 150); % More points for smoother curves
y1 = sin(x);
y2 = 0.8*cos(x);
y3 = sin(x + pi/4) * 0.6;

% --- Setup Figure and Colors ---
figure('Color', 'w'); % White background
my_colors = [0.1 0.1 0.1;       % Near Black
             0   0.4470 0.7410; % Blue
             0.8500 0.3250 0.0980]; % Orange/Red

% --- Create Axes and Set Properties ---
ax = gca; % Get current axes
hold on; % Hold on to plot multiple lines

% Set color order *before* plotting
ax.ColorOrder = my_colors;

% --- Plot Data ---
plot(x, y1, 'LineWidth', 1.8); % Slightly thicker lines
plot(x, y2, 'LineWidth', 1.8);
plot(x, y3, 'LineWidth', 1.8);

clear xlim
clear ylim

hold off;

% --- Customize Axes Appearance ---
ax.FontName = 'Helvetica'; % Clean sans-serif font
ax.FontSize = 16;
ax.Box = 'off';         % Remove box outline
ax.TickDir = 'out';      % Ticks point out
ax.LineWidth = 1.2;     % Axis line weight
ax.XColor = [0.3 0.3 0.3]; % Axis color (dark gray)
ax.YColor = [0.3 0.3 0.3];

% Add padding (adjust values as needed)
axis tight; % Start with tight axes to encompass the data range

% Get the current tight limits
current_xlim = xlim;
current_ylim = ylim;

% Calculate the span (range) of the tight limits
x_span = diff(current_xlim); % diff([min max]) gives max-min
y_span = diff(current_ylim);

% Define padding factor (e.g., 0.05 for 5% on each side)
x_pad_factor = 0.05;
y_pad_factor = 0.1; % Can use different padding for X and Y

% Calculate new limits by adding padding relative to the span
new_xlim = current_xlim + [-x_pad_factor, x_pad_factor] * x_span;
new_ylim = current_ylim + [-y_pad_factor, y_pad_factor] * y_span;

% Handle cases where span might be zero (e.g., plotting a constant value)
if x_span == 0
    new_xlim = current_xlim + [-1, 1]; % Add a default absolute padding
end
if y_span == 0
    new_ylim = current_ylim + [-1, 1]; % Add a default absolute padding
end

% Apply the new, padded limits
xlim(new_xlim);
ylim(new_ylim);
grid off; % Ensure grid is off

% --- Add Labels and Title ---
title('Clean Plot of Signals', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'normal', 'Color', [0.1 0.1 0.1]);
xlabel('Phase (radians)', 'FontName', 'Helvetica', 'FontSize', 12, 'Color', [0.3 0.3 0.3]);
ylabel('Value', 'FontName', 'Helvetica', 'FontSize', 12, 'Color', [0.3 0.3 0.3]);

% --- Customize Legend ---
lgd = legend('Sine Wave', 'Cosine Wave', 'Shifted Sine');
lgd.FontName = 'Helvetica';
lgd.FontSize = 11;
lgd.TextColor = [0.2 0.2 0.2];
lgd.Box = 'off';          % No box around legend
lgd.Location = 'northwest'; % Adjust location as needed

% --- Enable Smoothing ---
set(gcf, 'GraphicsSmoothing', 'on');

% --- Optional: Save High-Quality Figure ---
% Use exportgraphics for best results (newer MATLAB versions)
% exportgraphics(ax, 'clean_plot.png', 'Resolution', 300); % For PNG
% exportgraphics(ax, 'clean_plot.pdf', 'ContentType', 'vector'); % For PDF (vector)
%}