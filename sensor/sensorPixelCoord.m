function [coordX,coordY] = sensorPixelCoord(ISA,quadrantType)
%
%   [coordX,coordY] = sensorPixelCoord(ISA)
%
% Authos: ImagEval
% Purpose:
%      Return the coordinates of the image sensor array pixels, possibly in
%      the upper right quadrant or in the full array.
%

% Setting up local variables
nRows = sensorGet(ISA,'rows'); nCols = sensorGet(ISA,'cols');
pitchX = sensorGet(ISA,'deltax'); pitchY = sensorGet(ISA,'deltay');

if strcmp(quadrantType,'upper-right')
    
    % Create coordinates of pixel centers for upper-right quadrant of ISA
    % We assume the center to be located at the center of a pixel if the number
    % of rows and columns is odd. If the number of rows and columns is even,
    % the center is in between the four center pixels.
    
    if mod(nCols,2) == 0    % even number of columns
        coordX = pitchX*(0:(nCols/2-1))+pitchX/2;
    else                    % odd number of columns
        coordX = pitchX*(0:nCols/2);
    end
    
    if mod(nRows,2) == 0    % even number of columns
        coordY = pitchY*(0:(nRows/2-1))+pitchY/2;
    else                    % odd number of columns
        coordY = pitchY*(0:nRows/2);
    end
    
elseif strcmp(quadrantType,'full')
    
    % Create coordinates of pixel centers for full ISA (all 4 quadrants)
    % We assume the center to be located at the center of a pixel if the number
    % of rows and columns is odd. If the number of rows and columns is even,
    % the center is in between the four center pixels.
    
    if mod(nCols,2) == 0    % even number of columns
        posCoordX = pitchX*(0:(nCols/2-1))+pitchX/2;
        coordX(1:length(posCoordX)) = -fliplr(posCoordX);
        coordX(length(posCoordX)+1:nCols) = posCoordX;
    else                    % odd number of columns
        posCoordX = pitchX*(0:nCols/2);
        coordX(1:length(posCoordX)) = -fliplr(posCoordX);
        coordX(length(posCoordX):nCols) = posCoordX;
    end
    
    if mod(nRows,2) == 0    % even number of columns
        posCoordY = pitchY*(0:(nRows/2-1))+pitchY/2;
        coordY(1:length(posCoordY)) = -fliplr(posCoordY);
        coordY(length(posCoordY)+1:nRows) = posCoordY;
    else                    % odd number of columns
        posCoordY = pitchY*(0:nRows/2);
        coordY(1:length(posCoordY)) = -fliplr(posCoordY);
        coordY(length(posCoordY):nRows) = posCoordY;
    end
    
end

return;