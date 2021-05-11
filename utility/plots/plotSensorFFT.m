function plotSensorFFT(ori, dataType, figNum)
% Obsolete
%
% Plot the spatial frequency magnitude spectrum along a line in the sensor window
%
%   plotSensorFFT([ori = 'h'], [dataType = 'volts'], [figNum = GRAPHWIN])
%
% Purpose:
%    The magnitude spectrum of the sensor data along a line ('h' or 'v')
%    can be computed as abs(fft(voltageData)).  These are plotted in a
%    graph window.
%
%    The data are extracted from the selected ISA.
%
%    This routine is normally applied to Monochrome sensor data.
%    We apply the routine to color data by interpolating the data in the color
%    channels and then computing the separate FFT images.
%
%Example:
%   plotSensorFFT('h', 'volts')
%
% Copyright ImagEval Consultants, LLC, 2005.

if ~exist('ori', 'var') | isempty(ori), ori = 'h'; end
if ~exist('dataType', 'var') | isempty(dataType), dataType = 'volts'; end
if ~exist('figNum', 'var') | isempty(figNum), figNum = vcSelectFigure('GRAPHWIN'); end

[val, isa] = vcGetSelectedObject('ISA');
nSensors = sensorGet(isa, 'nSensors');
if nSensors > 1
    warndlg('FFT not yet implemented for color images.');
        return;
    end

    % Find the line in the sensor window.
    sensorHandle = ieSessionGet('sensorimagehandle');
    switch lower(ori)
        case 'h'
            ieInWindowMessage('Select horizontal line', sensorHandle, []);
        case 'v'
            ieInWindowMessage('Select vertical line', sensorHandle, []);
        otherwise
            error('Unknown orientation')
    end

    % Make sure the cursor is in the sensor image (call back) window
    figure(gcbf);
    [x, y, button] = ginput(1);
    ieInWindowMessage('', sensorHandle);
    xy = [round(x(end)), round(y(end))];

    data = sensorGet(isa, dataType);
    if isempty(data), warndlg(sprintf('Data type %s unavailable.', dataType));
        return;
    end

    fov = sensorGet(isa, 'fov');

    plotSetUpWindow(figNum);
    if nSensors > 1
        [data, cfaVals] = plane2rgb(data, isa, NaN);
        plotColorISALines(xy, data, ori, nSensors, dataType, figNum);
    elseif nSensors == 1
        plotMonochromeFFT(xy, data, fov, ori, dataType, figNum);
    end

    return;

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    function plotColorISALines(xy, data, ori, nSensors, dataType, figNum)
        %
        % Internal routine:  Deal with color sensor case, both CMY and RGB.
        %

        errordlg('Not yet implemented.');

        switch lower(ori)
            case {'h', 'horizontal'}
                for ii = 1:nSensors
                    lData{ii} = data(xy(2), :, ii);
                end
                titleString = sprintf('ISET:  Horizontal line %.0f', xy(2));
                xstr = 'Col number';
            case {'v', 'vertical'}
                for ii = 1:nSensors
                    lData{ii} = data(:, xy(1), ii);
                end
                titleString = sprintf('ISET:  Vertical line %.0f', xy(1));
                xstr = 'Row number';
            otherwise
                error('Unknown line orientation');
        end


        % Extract the data and assign a line color corresponding to the cfa color.
        [cfaOrdering, cfaMap] = sensorColorOrder;
        nColors = 0;
        for ii = 1:nSensors
            d = lData{ii};
            l = find(~isnan(d));
            if isempty(l),;
            else
                nColors = nColors + 1;
                idx = 1:length(d);
                pixPlot{nColors} = [cfaOrdering{ii}, '-'];
                pixData(:, nColors) = interp1(l, d(l), idx, 'linear', NaN)';
            end
        end

        % Build the subplot panels using the appropriate colors.
        for ii = 1:nColors
            subplot(nColors, 1, ii);
            plot(idx, pixData(:, ii), pixPlot{ii});
            xlabel(xstr);
            ystr = sprintf('%s', dataType);
            ylabel(ystr);
            grid on;
        end

        uData.pixData = pixData;
        uData. pixPlot = pixPlot;

        % Attach data to figure and label.
        set(figNum, 'userdata', uData);
        set(figNum, 'Name', titleString);

        return;

        %%%%%%%%%%%%%%%%%%%%%%%%%%
            function plotMonochromeFFT(xy, data, fov, ori, dataType, figNum)
                %

                switch lower(ori)
                    case {'h', 'horizontal'}
                        pixData = data(xy(2), :);
                        titleString = sprintf('ISET:  Horizontal fft %.0f', xy(2));
                        xstr = 'Cycles/deg (col)';
                    case {'v', 'vertical'}
                        pixData = data(:, xy(1));
                        titleString = sprintf('ISET:  Vertical fft %.0f', xy(1));
                        xstr = 'Cycles/deg (row)';
                    otherwise
                        error('Unknown linear orientation')
                end

                cpd = [0:round((length(pixData)-1) / 2)] / fov;
                nFreq = length(cpd);

                mn = mean(pixData);
                amp = abs(fft(pixData - mn));

                % To derive the true amplitude, we must divide by half the number of samples
                amp = amp / nFreq;

                plot(cpd, amp(1:nFreq), 'b-');
                xlabel(xstr);
                ylabel('Abs(fft(data))');
                txt = sprintf('Mean: %.4f\nPeak cont. %.4f', mn, max(amp(:))/mn);
                t = plotTextString(txt, 'ur');

                grid on;

                uData.cpd = cpd;
                uData.amp = amp;

                % Attach data to figure and label.
                set(figNum, 'userdata', uData);
                set(figNum, 'Name', titleString);

                return;