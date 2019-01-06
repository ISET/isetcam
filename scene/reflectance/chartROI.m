function [patchLocs,rect] = chartROI(currentLoc,delta)
% Derive the locations within a region of interest for a patch in a chart
%
% Syntax:
%  [patchLocs,rect] = chartROI(currentLoc,delta)
%
% Description:
%    Find all the locations for a patch centered at the currentLoc and with a
%    spacing of delta.  The format of a rect is (colMin,rowMin,width,height).
%    
% Inputs:
%   currentLoc:  A location in the chart
%   delta:  
%
% Outputs:
%   patchLocs - All the locations within this patchs
%   rect      - The rect for this patch location
%
% Copyright ImagEval Consultants, LLC, 2014
%
% See also: 
%   chartPatchData, chartRectangles,ieRoi2Locs

%%
if ieNotDefined('currentLoc'), error('current location in chart is required'); end
if ieNotDefined('delta')
    warning('Assuming a square patch size of 10.')
    delta = 10; 
end  % Get a better algorithm for size

%% Build the rect.
rect(1) = currentLoc(2) - round(delta/2);
rect(2) = currentLoc(1) - round(delta/2);
rect(3) = delta;
rect(4) = delta;

%% Convert the rect into the positions
patchLocs = ieRoi2Locs(rect);

end

