function [cfaOrdering, cfaMap] = sensorColorOrder(format)
%Return the list of ISET letters used for basic color descriptions
%
%   [cfaOrdering, cfaMap]  = sensorColorOrder([format])
%
%  The function stores how ISET associates color filter names with color
%  map values.  The cfaOrdering is a list that describes letters associated
%  with color names.  The cfaMap are the color values associated with these
%  letters.
%
%  The first letter in a filter name (e.g., rStanford) is a hint about the
%  color appearance of that filter (e.g., red).  The associations between
%  the hint ('r') and color appearance are contained here. The letter 'r'
%  is associated with the color map entry of (1,0,0).  Other filter names
%  used by the simulator are given plausible color hints:
%
%  The set of color hints are r,g,b,c,y,m,w(hite), and k (black).
%
%  The letter 'i' is useful for infrared (0.3, 0.2, 0.3) (brownish)
%
%  There are a few other free letters (u,x,z,o) that are available
%  for experimenting.  These are given color map entries of
%
%       u -> [.4 .7  0.3]; (greenish)
%       x -> [.7 .5  0.3]; (reddish)
%       z -> [.2 .5  0.8]  (bluish)
%       o -> [1  .6  0]; (orangeish)
%
%  The set of filter names in an ISA have distinct color hints.  So, using
%  rStanford, gStanford is OK; but do not use rStanford, rSony.  Even if
%  both filters are red, use a different color hint, say rStanford, xSony.
%
%  The normal format used to return the list of color letters is a cell
%  array.  If the input argument (format) is set to 'string', then the
%  cfaOrdering is returned as a string. 
%
%  Example:
%   [c,mp] = sensorColorOrder('string');
%   img = 1:size(mp,1); image(img); colormap(mp)
%
%  Cell array
%   [c,mp] = sensorColorOrder;
%
%  See also:  sensorImageColorArray, sensorDetermineCFA
%
% Copyright ImagEval Consultants, LLC, 2003.

if ~exist('format','var'), format = 'cell'; end

% The x,y,z and place holders, only loosely connected to XYZ.  
cfaOrdering = {'r','g','b','c','y','m','w','i','u','x','z','o','k'};

% The ordering of these color map entries must map cfaOrdering, above.
cfaMap = [1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 1 0; 1 0 1; 1 1 1; .3 .3 .3; ...
        .4, .7, .3; .9 .6 .3; .2 .5 .8; 1 .6 0; 0 0 0];

% If the user asks for the data to be returned as a string, do this.
% tmp = char(length(cfaOrdering),1);
if strcmp(format,'string')
        for ii=1:length(cfaOrdering)
            tmp(ii)= char(cfaOrdering{ii});  %#ok<AGROW>
        end
        cfaOrdering = tmp;
end

return;
