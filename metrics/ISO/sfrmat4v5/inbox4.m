function [del, weights, npol] = inbox4(del, weights, npol)   %GUI for sampling and lum weights
% Dialog box for input of data sampling and weights for red, green 
% and blue signals for luminance calculation for SFR calculation
%  Usage: [del, weights] = inbox4(def_del, def_weights, npol)
%   def_del     = (optional) default sampling interval in mm or dpi
%                 if not used, def_del = 1
%   def_weights = (optional) default 3x1 array of luminance weights  for R, G, B
%                 if not used, def_weights = [0.3  0.6  0.1]
%
%   del         = output sampling interval in mm
%   weights     = output 3x1 array of luminance weights  for R, G, B
%   npol        = order of polynomial edge fit (1 = linear, default)
%            
% Calls inputdlg function, supplied with the toolbox
% matlab/uitools. If you have problems, check which version of
% inputdlg.m (or corresponding inputdlg.p) is being called. You need
% version 1.48 or later.
% 3 May 2017
%
% Copyright (c) 2017 Peter D. Burns

fmt = '%5.3f';    %  2 decimal digits  

if nargin < 1
 del = 1;
end
if nargin < 2
 weights =[0.213
             0.715
             0.072];
end
if nargin < 3
    npol = 1;
end

if del > 1;
 def={num2str(del), '-', [num2str(weights(1,:), fmt)
                          num2str(weights(2,:), fmt)
                          num2str(weights(3,:), fmt)],num2str(npol)};
else
 def={'-', num2str(del), [num2str(weights(1,:), fmt)
                          num2str(weights(2,:), fmt)
                          num2str(weights(3,:), fmt)],num2str(npol)};

end

title='  Data sampling, weights & edge fit ';
prompt={'Data sampling in dpi',' or mm', 'Luminance weights  for R, G, B', 'Edge fit order, linear (default) = 1' };
%   def={'-', '1', ['0.3'
%                     '0.6'
%                     '0.1']};
lineNo=[1, 1, 3, 1]';
AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';
answer=inputdlg(prompt, title, lineNo, def, AddOpts);

% Catch for CANCEL button
if isempty(answer) == 1
    weights = weights';

 return
end


sflag = 0;
if length(char(answer(1)))~=1
 sflag = 1;
 elseif char(answer(1))~='-'
 sflag = 1;
end;
if sflag==0
  del =  str2num(char(answer(2)));  
 else;
  del =  str2num(char(answer(1)));
  del = 25.4/del;
end; 

weights = str2num(char(answer(3)))';   %%

if sum(weights) > 1.0;
 beep
 disp(' ***  WARNING: Sum of Luminance weights is greater than 1  ***');
end;
del = abs(del);
npol = str2num(char(answer(4)))';   %%
