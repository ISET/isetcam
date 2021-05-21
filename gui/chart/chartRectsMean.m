function roiV = chartRectsMean(sensor,rects,dataType)
% Deprecated.  Return mean values from rect ROIs of an object
%
%    USE chartRectsData
%
%    roiV = chartRectsMean(sensor,rects,dataType)
%
% Inputs:
%  sensor:   Will be general object some day
%  rects:    Matrix of N rects (Nx4)
%  dataType: Depends on object.
%
% Returns
%   roiV:  Region of interest mean values.  Data for each ROI is in a
%    column.  So if there are 6 rects and 5 sensor bands, the returned
%    matrix is 5 x 6.
%
% See also:  Based on macbethSelect and related routines.
%
% (c) Imageval Consulting, 2012

roiV = zeros(sensorGet(sensor,'n sensor'),size(rects,1));
for ii=1:size(rects,1)
    sensor = sensorSet(sensor,'roi',rects(ii,:));
    switch dataType
        case 'volts'
            roiV(:,ii)   = sensorGet(sensor,'roi volts mean');  % (row,col,w)
        case 'electrons'
            roiV(:,ii)   = sensorGet(sensor,'roi electrons mean');  % (row,col,w)
        otherwise
    end
end

end
