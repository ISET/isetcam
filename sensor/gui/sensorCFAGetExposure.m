function sensor = sensorCFAGetExposure(sensor)

% Make a GUI to let the user specify separate exposure times for the
% different filters in the sensor.

if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end

filterOrder   = sensorGet(sensor,'pattern');
filterSpectra = sensorGet(sensor,'filterspectra');

[nRows,nCols] = size(filterOrder);

hCFAExp = cfaGetExposure;


%%
% Draw new figure

    function hCFAExp = cfaGetExposure()
        
        hCFAExp.sensor = sensor;
        hCFAExp.fig = figure;
        
        % Main window
        figPosition = get(hCFAExp.fig,'Position');
        figWidth  = nCols*50 + 100; % pixels
        figHeight = nRows*50 + 100; % pixels
        set(hCFAExp.fig,...
            'Tag', 'CFAexposure',...
            'NumberTitle','Off',...
            'Resize','Off',...
            'Position',[figPosition(1:2),figWidth,figHeight],...
            'Name','Set Exposure',...
            'Menubar','None'...
            );
        
        % Main panel
        hCFAExp.panel = uipanel(... % Main panel
            'Parent',hCFAExp.fig,...
            'Position', [0.01 0.21 0.98 0.78],...
            'BackgroundColor',get(gcf,'Color')...
            );
        
        % Done button
        hCFAExp.buttonDone = uicontrol(...  % Done button
            'Parent', hCFAExp.fig,...
            'Style','pushbutton',...
            'String', 'Done',...
            'Units','Normalized',...
            'Position',[0.30 0.03 0.4 0.14],...
            'BackgroundColor','w',...
            'Callback', {@doneCallback sensor},...
            'KeyPressFcn', {@doneCallback sensor}...
            );
        
        %%
        % CFA exposure fields etc.
        
        % Set dimensions (relative to the dimensions of the main panel) of the
        % editboxes that are used to enter exposure values
        
        editWidth    = 0.9/nCols;
        editHeight   = 0.9/nRows;
        editSpacingX = 0.1/(nCols + 1);
        editSpacingY = 0.1/(nRows + 1);
        
        % Get the sensitivity function of the color filters - we will use this to
        % show colors
        wave = sensorGet(sensor,'wave');
        bMatrix = colorBlockMatrix(wave,0.2);
        
        % We'll loop through CFA positions to put edit boxes in the panel. The CFA
        % is addressed with the origin on the top left, while the panel dimensions
        % have their origin on the bottom left. We either have to carefully figure
        % out dimensions while specifying editbox positions, or we can flip the
        % filterOrder to achieve the same effect
        filterOrder = flipud(filterOrder);
        
        for currentRow = 1:nRows
            for currentCol = 1:nCols
                
                xPos = editSpacingX + (currentCol - 1)*(editWidth + editSpacingX);
                yPos = editSpacingY + (currentRow - 1)*(editHeight + editSpacingY);
                
                pointIndex = sub2ind([nRows,nCols],currentRow,currentCol);
                filterIndex = filterOrder(currentRow,currentCol);
                
                colorFilter = filterSpectra(:,filterIndex);
                RGB = bMatrix'*colorFilter;
                RGB = RGB'/max(RGB(:));
                
                hCFAExp.exps(pointIndex).panel = uipanel(...
                    'Parent', hCFAExp.panel,...
                    'Units','normalized',...
                    'BackgroundColor', RGB,...
                    'Position',[xPos yPos editWidth editHeight]...
                    );
                
                hCFAExp.exps(pointIndex).units = uicontrol(...
                    'Parent',  hCFAExp.exps(pointIndex).panel,...
                    'Style','Text',...
                    'String','ms',...
                    'Units','normalized',...
                    'Position',[0.3 0.1 0.4 0.2],...
                    'BackgroundColor', RGB...
                    );
                
                hCFAExp.exps(pointIndex).val = uicontrol(...
                    'Parent',  hCFAExp.exps(pointIndex).panel,...
                    'Style','Edit',...
                    'Units','normalized',...
                    'Position',[0.1 0.4 0.8 0.5],...
                    'BackgroundColor', [0.9 0.9 0.9],...
                    'String', '0',...
                    'Callback', @editboxCallback...
                    );
                
            end
        end
        
        
        function editboxCallback(source,event)
            
            % Updates the exposure value string and the exposure units string
            
            nPixels = length(hCFAExp.exps);
            
            
            for currentPixel = 1:nPixels
                
                hUnits = hCFAExp.exps(currentPixel).units;
                hVal   = hCFAExp.exps(currentPixel).val;
                
                % Read exposure time
                expTime = str2double(get(hVal,'string'));
                
                % Convert units to seconds
                units = get(hUnits,'String');
                
                switch units
                    case 'sec'
                        sFactor = 1;
                    case 'us'
                        sFactor = 1e-6;
                    otherwise
                        sFactor = 1e-3;
                end
                
                expTime = expTime*sFactor;
                
                % Display expTime and units appropriately
                
                if expTime ~= 0
                    
                    u = log10(expTime);
                    
                    if u >= 0
                        str = sprintf('%.2f',expTime);
                        set(hUnits,'string','sec');
                    elseif u >= -3
                        str = sprintf('%.2f',expTime*10^3);
                        set(hUnits,'string','ms');
                    else
                        str = sprintf('%.2f',expTime*10^6);
                        set(hUnits,'string','us');
                    end
                    
                    set(hVal,'string',str);
                end
                
            end % end pixel by pixel string update
            
        end % end editboxCallback
        
        
        function hCFAExp = doneCallback(source,event,hCFAExp)
            
            % Reads exposure values from all the edit boxes and finds the expTimes
            % matrix. Also updates the sensor structure
            
            sensor = hCFAExp.sensor;
            filterOrder   = sensorGet(sensor,'pattern');
            [nRows,nCols] = size(filterOrder);
            
            expTimes = zeros(nRows,nCols);
            
            for currentRow = 1:nRows
                for currentCol = 1:nCols
                    
                    pointIndex = sub2ind([nRows, nCols], currentRow,currentCol);
                    hVal       = hCFAExp.exps(pointIndex).val;
                    hUnits     = hCFAExp.exps(pointIndex).units;
                    
                    expTime = str2double(get(hVal,'String'));
                    
                    % Convert units to seconds
                    units = get(hUnits,'String');
                    
                    switch units
                        case 'sec'
                            sFactor = 1;
                        case 'us'
                            sFactor = 1e-6;
                        otherwise
                            sFactor = 1e-3;
                    end
                    
                    expTime = expTime*sFactor;
                    
                    % convert to seconds
                    expTimes(currentRow,currentCol) = expTime;
                    
                end
            end
            
            % When we drew the GUI we flipped filterOrder to avoid conflicts with the
            % origin of filterOrder being different form the origin of the panel in
            % which we placed the edit boxes. So, we have to flip expTimes to be
            % consistent with filterOrder
            
            expTimes = flipud(expTimes);
            
            % Set the vector of exposure times
            sensor = sensorSet(sensor,'expTime',expTimes);
            
            % Replace the sensor and update the GUI handle with new data
            % vcReplaceObject(sensor);
            %         setappdata(hCFAExp.fig,'sensor',sensor);
            
            hCFAExp.sensor = sensor;
            %             uiresume(hCFAExp.fig)
            % Close the GUI
            close(hCFAExp.fig);
            
            
        end % end doneCallback
        
        %         uiwait(hCFAExp.fig);
    end % cfaGetExposure

% hCFA

end % end main function



