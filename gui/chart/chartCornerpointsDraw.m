function chartCornerpointsDraw(objType,cp)
% Draw the corner points of a chart on the proper window
%
% Synopsis
%    chartCornerpointsDraw(objType,cp)
%
% Inputs
%   objType - A string or the struct of a scene, oi, sensor, ip
%
% Outputs
%   N/A

% See also
%   chart<>
%

% Should check for valid type
[~,ax] = ieAppGet(objType);

for ii=1:4
    drawpoint(ax,'Position',cp(ii,:),'color','w');
end

end

