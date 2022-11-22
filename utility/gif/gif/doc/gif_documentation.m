%% |gif| documentation
% The |gif| function is the simplest way to make gifs. Simply call
% 
%   gif('myfile.gif') 
% 
% to first the first frame, and then call 
% 
%   gif
% 
% to write each subsequent frame. That's it. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  gif('filename.gif') 
%  gif(...,'DelayTime',DelayTimeValue,...) 
%  gif(...,'LoopCount',LoopCountValue,...) 
%  gif(...,'frame',handle,...) 
%  gif(...,'resolution',res)
%  gif(...,'nodither') 
%  gif(...,'overwrite',true)
%  gif 
%  gif('clear') 
% 
%% Description 
% 
% |gif('filename.gif')| writes the first frame of a new gif file by the name |filename.gif|. 
% 
% |gif(...,'DelayTime',DelayTimeValue,...)| specifies a the delay time in seconds between
% frames. Default delay time is |1/15|. 
% 
% |gif(...,'LoopCount',LoopCountValue,...)| specifies the number of times the gif animation 
% will play. Default loop count is |Inf|. 
% 
% |gif(...,'frame',handle,...)| uses the frame of the given figure or set of axes. The default 
% frame handle is |gcf|, meaning the current figure. To turn just one set of axes into a gif, 
% use |'frame',gca|. This behavior changed in Jan 2021, as the default option changed from
% gca to gcf.
% 
% |gif(...,'resolution',res)| specifies the resolution (in dpi) of each frame. This option
% requires <https://www.mathworks.com/matlabcentral/fileexchange/23629 |export_fig|>.
% 
% |gif(...,'nodither')| maps each color in the original image to the closest color in the new 
% without dithering. Dithering is performed by default to achieve better color resolution, 
% albeit at the expense of spatial resolution.
% 
% |gif(...,'overwrite',true)| bypasses a dialoge box that would otherwise verify 
% that you want to overwrite an existing file by the specified name. 
%
% |gif| adds a frame to the current gif file. 
% 
% |gif('clear')| clears the persistent variables associated with the most recent gif. 
% 
%% Example 
% Consider this sample surface that changes over time: 

% Some sample data: 
t = sin(linspace(0,2*pi,30)); 
[X,Y,Z] = peaks(500); 

% Plot the first frame: 
h = surf(X,Y,Z*t(1)); 
shading interp
axis([-3 3 -3 3 -9 9])

% Make it fancy: 
camlight
set(gca,'color','k') 
set(gcf,'color','k') 
caxis([min(Z(:)) max(Z(:))])

%% Write the first frame: 
% When your plot looks the way you want the first frame of the gif to look, create a new gif file
% and write the first frame like this: 
% 
%  gif('myfile.gif') 
% 
% If you want to specify certain options, include them the first time you call |gif|. For example, 
% if you want a 1/24 second delay between each frame, you want the loop to run five times, and you 
% want to use the entire figure window rather than the current axes, specifying all those options
% would look like this: 
% 
%  gif('myfile.gif','DelayTime',1/24,'LoopCount',5)
%  
% Or, if you want a high-resolution gif that uses |export_fig|, specify a resolution
% in units of dpi. This option is slower and creates larger files, but in some cases
% the difference in image quality may be significant. Here's how you might specify 400 dpi: 
% 
% gif('myfile.gif','DelayTime',1/24,'resolution',400)
%
%% Write the rest of the frames 
% After the first frame has been written, write each subsequent frame simply by calling |gif| without
% any options. Here we loop through the remaining 29 frames:
% 
%  for k = 2:29
%     set(h,'Zdata',Z*t(k))
%     gif
%  end
% 
%% 
% And that's it. Here's what the final product looks like using the default
% resolution: 
% 
% <<myfile.gif>>

%% View the gif in Matlab 
% Did you know you can view gifs in Matlab? Here's how: 
% 
%  web('myfile.gif') 

%% Speeding up animation creation 
% You'll notice that in the loop above, we only changed the bare minimum number of things in the plot. 
% We did not clear the plot and regenerate the plot each time through the loop, because the more things
% you do, and the more things you plot, the longer it takes for each iteration. As with any loop, try to 
% minimize the number of operations inside the loop. 
% 
%% Author Info
% This function and supporting documentation were written by <http://www.chadagreene.com Chad A. Greene> 
% of the University of Texas Institute for Geophysics (UTIG), June 2017. 
