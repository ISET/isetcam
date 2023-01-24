function [results, fitme, esf, h, sinfo] = ISO12233v4(barImage, deltaX, weight, plotOptions)
% ISO 12233 (slanted bar) spatial frequency response (SFR) updated for sfrmat4
%
%  [results, fitme, esf, h, sinfo] = ISO12233v4(barImage, deltaX, weight,plotOptions);
%
% Brief description
%   Slanted-edge MTF calculation
%
% Inputs
%  barImage:  The RGB image of the slanted bar
%  deltaX:    The sensor sample spacing in millimeters (expected). It
%   is possible to send in a display spacing in dots per inch (dpi), in
%   which case the number is > 1 (it never is for sensor sample spacing).
%   In that case, the value returned is cpd on the display at a 1m viewing
%   distance.
%
%   See notes below about translating to cyc/deg in the original scene. See
%   TODO in code about this practice.
%
%   weight:    RGB weights to calculate luminance
%
% Outputs:
%   results - This is a struct that includes the MTF and LSF data.
%   fitme -
%   esf -
%   h - Figure handle
%
% Notes:
%   1 cycle on the sensor has frequency: 1/sensorGet(sensor,'width','mm')
%   1 cycle on the sensor is 1/sensorGet(sensor,'fov') cycles in the
%     original image.
%
% Code snippet for conversion - Assume you ran with sensor pixel as dx
%   sw = sensorGet(sensor,'width','mm');       % Sensor with in mm
%   cycPerSensor = 1/sw;                       % 1 Cycle/Sensor in lpm
%   cycPerScene  = 1/sensorGet(sensor,'fov');  % 1 Cycle/sensor in cpd
%   lpm2cpd = cycPerScene/cycPerSensor;        % Converts lpm to cpd
%   results.freq = results.freq*lpm2cpd;
%
% Run like this
%
%     ISO12233;
%
% You are prompted for a bar file and other parameters:
%
% Reference
%  This code originated with Peter Burns, now a consultant
%  http://burnsdigitalimaging.com/software/sfrmat/
%
%  Substantially re-written by Wandell (again)
%
% See also:
%   ieISO12233, ISOFindSlantedBar, s_metricsMTFSlantedBar
%

% PROGRAMMING TODO:
%  Rather than decode pixelWidth and dpi based on the value, we should
%  probably set a flag and be explicit.

%% Switch this over to inpurParser

if ieNotDefined('deltaX'), deltaX = .002;  warning('Assuming 2 micron pixel');  end
if ieNotDefined('npol'), npol = 1; end  % Not sure what the default should be (BW)
if ieNotDefined('weight'), weight = [0.213   0.715   0.072]; end  % RGB: Luminance weights for sfrmat4
if ieNotDefined('plotOptions'), plotOptions = 'all'; end  % all or luminance or none
if ieNotDefined('barImage')
    % If there is no image, then you can read a file with the bar image.
    % You are also asked to specify a look-up table file that converts the
    % data in the edgeFile into linear units appropriate for the MTF
    % calculation.  If no lutFile is selected, then we assume this
    % transformation is not necessary for your data.
    edgeFile = vcSelectDataFile('stayput','r',[],'Select slanted bar image');
    [barImage,smax] = readBarImage(edgeFile);
    lutFile = vcSelectDataFile('stayput','r',[],'Select LUT file');
    
    if isempty(lutFile)
        % oename='none';
    else
        [oepath,oename,oeext] = fileparts(lutFile);
        % Convert through LUT and make sure data are in double format
        barImage = getoecf(barImage, oepath, [oename,oeext]);
    end
    barImage = double(barImage);
elseif isstruct(barImage) && isequal(barImage.type,'vcimage')
    % The barImage is really the image processor (ip)
    ip = barImage;
    rect = ISOFindSlantedBar(ip);
    roiLocs = ieRect2Locs(rect);
    barImage = vcGetROIData(ip,roiLocs,'results');
    col = rect(3)+1;
    row = rect(4)+1;
    barImage = reshape(barImage,row,col,3);
    smax = max(barImage(:));
else
    smax = max(barImage(:));
    % edgeFile = 'Input data';
end

% Extract region of interest
[nlow, nhigh, cstatus] = clipping(barImage, 0, smax, 0.005);
if cstatus ~=1
    fprintf('Fraction low data: %.3f\n',nlow);
    fprintf('Fraction high data: %.3f\n',nhigh);
end

% Default sampling and color weights
if deltaX == 1
    % Unknown physical units.  Not preferred.
    funit =  'cy/pixel';
elseif deltaX > 1
    % Spacing is with respect to the display RGB (dpi).  We assume a 1m
    % viewing distance.
    deltaX = 25.4/deltaX;
    funit =  'cy/deg at 1m distance';
else
    % Spacing is with respect to the sensor surface.  Value should be in
    % mm.
    funit = 'cy/mm on sensor';
end

% Default:  weight = [0.3, 0.6, 0.1];
[nRow, nCol, nWave] = size(barImage);
if (nRow < 5) || (nCol < 5), warning('Image region too small'); return; end

%% Start computations

% Form luminance record using the weight vector for red, green and blue
% Add this as a fourth image to barImage
if nWave == 3
    % lum = zeros(nRow, nCol);
    lum = weight(1)*barImage(:,:,1) + weight(2)*barImage(:,:,2) + weight(3)*barImage(:,:,3);
    barImage(:,:,4) = lum;
    nWave = 4;
end

% rotate horizontal edge to vertical
[barImage, nRow, nCol, rflag] = rotatev2(barImage);
loc = zeros(nWave, nRow);

% Need 'positive' edge for good centroid calculation
fil1 = [0.5 -0.5];
fil2 = [0.5 0 -0.5];
tleft  = sum(sum(barImage(:, 1:5,1),2));
tright = sum(sum(barImage(:, nCol-5:nCol,1),2));
if tleft>tright
    fil1 = [-0.5 0.5];
    fil2 = [-0.5 0 0.5];
end

% Test for low contrast edge;
test = abs( (tleft-tright)/(tleft+tright) );
if test < 0.2
    disp(' ** WARNING: Edge contrast is less that 20%, this can');
    disp('             lead to high error in the SFR measurement.');
end

fitme = zeros(nWave, 2);
slout = zeros(nWave, 1);

% smoothing window for first part of edge location estimation -
% to used on each line of ROI (l 317 in sfrmat4)
win1 = ahamming(nCol, (nCol+1)/2);      % Symmetric window
for color=1:nWave                       % Loop for each color
    %     if nWave == 1, pname = ' ';
    %     else pname =[' Red ' 'Green'  'Blue ' ' Lum '];
    %     end
    lsf = deriv1(barImage(:,:,color), nRow, nCol, fil1); % l 355 in sfrmat4
    % vcNewGraphWin; imagesc(c); colormap(gray(64))
    % compute centroid for derivative array for each line in ROI. NOTE WINDOW array 'win'
    for n=1:nRow
        % -0.5 shift for FIR phase
        loc(color, n) = pbCentroid( lsf(n, 1:nCol )'.*win1) - 0.5;
    end
    % clear c
    
    fitme(color,:) = findedge2(loc(color,:), nRow, npol); %%%%%%%%%%%%%%%%
    place = zeros(nRow,1);
    for n=1:nRow
        place(n) = fitme(color,2) + fitme(color,1)*n;
        win2 = ahamming(nCol, place(n));
        loc(color, n) = pbCentroid( lsf(n, 1:nCol )'.*win2) -0.5;
    end
    
    [fitme(color,:)] = findedge2(loc(color,:), nRow, npol);
    % fitme(color,:) = findedge(loc(color,:), nRow); % OLD
    % fitme(color,:); % used previously to list fit equations
    
    % For comparison with linear edge fit (to delete, I think, BW)
    [fitme1(color,:)] = findedge2(loc(color,:), nRow, 1);

    %{
    % Not sure this does anything besides print.  It is from the new code,
    % though.  Maybe y or y1 are used later?
    if npol>3
        x = 0: 1: nRow-1;
        y = polyval(fitme(color,:), x);   %%
        y1 = polyval(fitme1(color,:),x);  %%   
        [r2, rmse, merror] = rsquare(y,loc(color,:));
        disp(['mean error: ',num2str(merror)]);
        disp(['r2: ',num2str(r2),' rmse: ',num2str(rmse)]);
    end 
    %}
end

summary{1} = ' ';                 % initialize
nWaveOut = nWave;                 % output edge location listing
if nWave == 4, nWaveOut = nWave - 1; end

midloc = zeros(nWaveOut,1);
summary{1} = 'Edge location, slope';     % initialize
sinfo.edgelab = 'Edge location, slope';  % New sfrmat4 parameter
for i=1:nWaveOut
    slout(i) = - 1./fitme(i,1);     % slope is as normally defined in image coords.
    if rflag==1                     % positive flag if ROI was rotated
        slout(i) =  -fitme(i,1);
    end
    
    % evaluate equation(s) at the middle line as edge location
    % midloc(i) = fitme(i,2) + fitme(i,1)*((nRow-1)/2); % OLD code
    midloc(i) = polyval(fitme(i,:), (nRow-1)/2); %% Changed for sfrmat4

    summary{i+1} = [midloc(i), slout(i)];
    sinfo.edgedat = [midloc(i), slout(i)];   % New sfrmat4 parameter

end
% {
% Newer code with nWaveOut replacing nWave.  Confused but seems OK. (BW).
if nWave>2
    summary{1} = 'Edge location, slope, misregistration (second record, G, is reference)';
    sinfo.edgelab = 'Edge location, slope, misregistration (second record, G, is reference)';
    misreg = zeros(nWaveOut,1);
    temp11 = zeros(nWaveOut,3);
    for i=1:nWaveOut
        misreg(i) = midloc(i) - midloc(2);
        temp11(i,:)   = [midloc(i), slout(i), misreg(i)];
        summary{i+1}  = [midloc(i), slout(i), misreg(i)];      
       % fitme(i,end) =  misreg(i);
    end
    sinfo.edgedat = temp11;
    clear temp11
% Display code, commented out
%     if io == 5 
%         disp('Misregistration, with green as reference (R, G, B, Lum) = ');
%         for i = 1:nWave
%             fprintf('%10.4f\n', misreg(i))
%         end
%     end  % io ==5
end  % ncol>2
%}

%{
% Older code, should be replaced by above above.
% Could insert a display flag
% disp('Edge location(s) and slopes = ' ), disp( [midloc(1:nWaveOut), slout(1:nWaveOut)]);
if nWave>2
    summary{1} = 'Edge location, slope, misregistration (second record, G, is reference)';
    misreg = zeros(nWaveOut,1);
    for i=1:nWaveOut
        misreg(i) = midloc(i) - midloc(2);
        summary{i+1}=[midloc(i), slout(i), misreg(i)];
    end
    
    % Turned off display
    %     disp('Misregistration, with green as reference (R, G, B, Lum) = ');
    %     for i = 1:nWaveOut
    %         fprintf('%10.4f\n', misreg(i));
    %     end
end
%}

% Full linear fit is available as variable fitme. Note that the fit is for
% the projection onto the X-axis,
%       x = fitme(color, 1) y + fitme(color, 2)
% so the slope is the inverse of the one that you may expect
nbin = 4;
nn =   floor(nCol * nbin);
mtf =  zeros(nn, nWave);
nn2 =  nn/2 + 1;

% We compute the frequencies in terms of the deltaX spacing.  Ordinarily,
% deltaX is in terms of the pixel pitch on the sensor in millimeters.  Some
% convenient facts:
%  1 cycle on the sensor is the frequency: 1/sensorGet(sensor,'width','mm')
%  1 cycle on the sensor is 1/sensorGet(sensor,'fov') cycles in the original image.
%  1 cycle in the barImage is 1/barImageWidthDeg
%
% If the deltaX input is > 1, however, we interpret the parameter as
% display dpi.  In this case the cycles are converted from cy/mm to cy/deg
% assuming a viewer located 1 m from the display.
%
% The first step in the code converts the frequencies into lines per
% millimeter on the sensor or display surface.
freq = zeros(nn, 1);
for n=1:nn; freq(n) = nbin*(n-1)/(deltaX*nn); end
% limits plotted sfr to 0-1 cy/pxel freqlim = 2 for all data
freqlim = 1;
nn2out = round(nn2*freqlim/2);    % What is this?
nfreq = n/(2*deltaX*nn);          % half-sampling (Nyquist) frequency

% If the units are for the display surface, we further convert to cycles
% per degree on the display by converting lpm and assuming a viewing
% distance of 1M
if strncmpi(funit,'cy/deg',6)
    % We currently have cyc/mm, so we need mm/deg for the conversion.
    %
    % The right angle from the viewer to screen produces the equation:
    % Opposite = X; Adjacent = 1;
    % tan(X/adjacent) = deg2rad(0.5)
    % X = 2*atan(deg2rad(0.5))*adjacent  is the answer in meters.
    % Multiply by 1000 to get mm per deg on the display surface
    mmPerDeg = 2*atan(deg2rad(0.5))*1e+3;
    
    % cyc/mm * mm/deg give us cyc/deg
    freq  = freq *mmPerDeg;
    nfreq = nfreq*mmPerDeg;
end

win = ahamming(nbin*nCol,(nbin*nCol+1)/2);      % centered Hamming window

% Loop for each color record.  This variable is returned.  It seems to
% be the interpolated edge for each of the color channels. Maybe edge
% spread function?
esf = zeros(nn,nWave);

for color=1:nWave
    % project and bin data in 4x sampled array

    % Old
    point = project(barImage(:,:,color), loc(color, 1), fitme(color,1), nbin); 
    % point = project2(barImage(:,:,color), fitme(color,:), nbin);

    % vcNewGraphWin; plot(point); colormap(gray(64))
    esf(:,color) = point;  % Not sure what esf stands for. Estimated spatial frequency?
    
    % compute first derivative via FIR (1x3) filter fil
    lsf = deriv1(point', 1, nn, fil2);  % vcNewGraphWin; plot(c)
    lsf = lsf';
    mid = pbCentroid(lsf);
    temp = cent(lsf, round(mid));       % shift array so it is centered
    lsf = temp;
    clear temp;
    
    % apply window (symmetric Hamming)
    lsf = win.*lsf;    % vcNewGraphWin; plot(c)
    
    % Transform, scale %% The FFT of the point spread
    % c is the line spread function
    temp = abs(fft(lsf, nn));    % vcNewGraphWin; plot(temp)
    mtf(1:nn2, color) = temp(1:nn2)/temp(1);
end

dat = zeros(nn2out, nWave+1);
for i=1:nn2, dat(i,:) = [freq(i), mtf(i,:)]; end


%% Plot SFRs on same axes
if nWave >1
    sym{1} = '-r';
    sym{2} = '-g';
    sym{3} = '-b';
    sym{4} = '-k';
else
    sym{1} = 'k';
end
% ttext = sprintf('ISO 12233: %s',edgeFile);

% screen = get(0, 'ScreenSize');
% % defpos = get(0, 'DefaultFigurePosition');
% set(0, 'DefaultFigurePosition', [15 25 0.6*screen(3) 0.4*screen(4)]);

results.freq = freq(1:nn2out);
results.mtf  = mtf(1:nn2out,:);
results.nyquistf = nfreq;   % cyc/mm
results.lsf = lsf/max(lsf(:));

% Create the spatial samples for the linespread.
x = (1:numel(lsf)); x = x - mean(x);
% The highest spatial frequency needs to samples.  So there are two
% samples per the wavelength of the highest frequency.
x = x * 0.5 * (1/max(results.freq(:)));
results.lsfx = x;  % mm

lumMTF = results.mtf(:,end);
belowNyquist = (results.freq < nfreq);

% Sometimes, if the image is very noisy, lumMTF has a number of NaNs. We
% won't find mtf50 in such cases.
if ~isnan(lumMTF)
    % Old calculation
    %   results.mtf50 = interp1(lumMTF,results.freq,0.5);
    % New calculation
    %   Sample freq finely
    %   Find the below-nyquist freq closest to an MTF value of 0.5
    iFreq = 0:0.2:results.nyquistf;
    iLumMTF = interp1(results.freq(belowNyquist),lumMTF(belowNyquist),iFreq);
    [~,idx] = min(abs(iLumMTF - 0.5));
    results.mtf50 = iFreq(idx);
else
    fprintf('NaN lumMTF values.  No plot is generated.\n');
    return
end

% The area under the curve to the right of the nyquist as a percentage of
% the total area in the green channel (when RGB), or in the luminance
% (first channel) when a monochrome image.
if nWave == 4
    results.aliasingPercentage = 100*sum(results.mtf(~belowNyquist,2))/sum(results.mtf(:,2));
elseif nWave == 1
    results.aliasingPercentage = 100*sum(results.mtf(~belowNyquist,1))/sum(results.mtf(:,1));
end

switch plotOptions
    case 'all'
        % Set data into the figure
        h = ieNewGraphWin;
        set(h,'userdata',results);
        % Draw the luminance term
        p = plot(freq( 1:nn2out), mtf(1:nn2out, 1), sym{1});
        set(p,'linewidth',2);
        
        title('ISO 12233');
        xlabel(['Spatial frequency (', funit,')']);
        ylabel('Contrast reduction (SFR)');
        
        hold on;
        if nWave>1
            for n = 2:nWave
                p = plot( freq( 1:nn2out), mtf(1:nn2out, n), sym{n});
                set(p,'linewidth',2);
            end
        end
        
        % Half-sampling line on graph
        line([nfreq ,nfreq],[0.05,0]),
        
        % TODO: Put little box or legend, or some kind lines/points to
        % indicate these on the graph.
        txt1 = sprintf('Nyquist = %0.2f\n',nfreq);
        txt2 = sprintf('Mtf50 = %0.2f\n',results.mtf50);
        txt3 = sprintf('Percent alias = %0.2f\n',results.aliasingPercentage);
        txt = addText(txt1,txt2);
        txt = addText(txt,txt3);
        
        % delta is (x,y)
        plotTextString(txt,'ur',[0.4 0.2],18);
        
        hold off;
        
        grid on
    case 'luminance'
        % Set data into the figure
        h = vcNewGraphWin;
        set(h,'userdata',results);
        
        p = plot(freq( 1:nn2out), mtf(1:nn2out, 1), sym{1});
        set(p,'linewidth',2);
        
        % [p,fname,e] = fileparts(ttext);
        title('ISO 12233');
        xlabel(['Spatial frequency (', funit,')']);
        ylabel('Contrast reduction (SFR)');
        
        % Half-sampling line on graph
        line([nfreq ,nfreq],[0.05,0]),
        
        % TODO: Put little box or legend, or some kind lines/points to
        % indicate these on the graph.
        % See above for a fix to this.
        txt = sprintf('Nyquist = %0.2f\n',nfreq);
        newText = sprintf('Mtf50 = %0.2f\n',results.mtf50);
        txt = addText(txt,newText);
        newText = sprintf('Percent alias = %0.2f',results.aliasingPercentage);
        txt = addText(txt,[newText,' %']);
        plotTextString(txt,'ur');
        hold off;
    case 'none'
        % Do nothing, we don't want a plot
        h = [];
    otherwise
        error('Unknown plotOptions: %s\n',plotOptions);
end

end

%---------------------------------------------------
% ISO 12233 subroutines
%---------------------------------------------------
function [barImage,smax] = readBarImage(edgeFile)
%
tempBarImage = imread(edgeFile);
% [nRow nCol nWave] = size(tempBarImage);

switch (lower(class(tempBarImage)))
    case 'uint8'
        smax = 255;
    case 'uint16'
        smax = 2^16-1;
    otherwise
        smax = 1e10;
end
barImage = getroi(tempBarImage);

end

%----------------------------------------------------
function [data] = ahamming(n, mid)
% [data] = ahamming(n, mid)
% function generates a general asymmetric Hamming-type window
% array. If mid = (n+1)/2 then the usual symmetric Hamming 
% window is returned
%  n = length of array
%  mid = midpoint (maximum) of window function
%  data = window array (nx1)
%
%  Author: Peter Burns, 1 Oct. 2008
%  Copyright (c) 2007 Peter D. Burns

data = zeros(n,1);
%
mid = mid+0.5;  % added 13 June 2019

wid1 = mid-1;
wid2 = n-mid;
wid = max(wid1, wid2);
pie = pi;
for i = 1:n
	arg = i-mid;
	data(i) = cos( pie*arg/(wid) );
end
data = 0.54 + 0.46*data;
end

%----------------------------------------------------
function [b] = cent(a, center)
%
%   b = cent(a, center)  Array shift for centering data
%
%  Shift one-dimensional array, so that a(center) is located at
%  b(round((n+1)/2).
%  Written to shift a line-spread function array prior to
%  applying a smoothing window.
%   a      = input array
%   center = location of signal center to be shifted
%   b      = output shifted array
%  Peter Burns 5 Aug. 2002
%  Copyright (c) International Imaging Industry Association

n = length(a);
b = zeros(n, 1);
mid = round((n+1)/2);

del = round(center - mid);

if del > 0
    for i = 1:n-del
        b(i) = a(i + del);
    end
    
elseif del < 1
    for i = -del+1:n
        b(i) = a(i + del);
    end
    
else, b = a;
end

end

%----------------------------------------------------
function [loc] = pbCentroid(x)
% Peter Burns method for finding a centroid
%
% [loc] = pbCentroid(x)  
%
% (We should try to replace with the Matlab routine)
%
%  Returns centroid location of a vector
%   x   = vector
%   loc = centroid in units of array index
% Peter Burns 5 Aug. 2002
% Copyright (c) International Imaging Industry Association

loc = 0;
for n=1:length(x), loc = loc + n*x(n); end

if sum(x) == 0, warndlg('Values are all zero.  Invalid centroid'); end
loc = loc/sum(x);
end

%----------------------------------------------------
function [nlow, nhigh, status] = clipping(barImage, low, high, thresh1)
% Checks for data clipping
%
% [n, status] = clipping(barImage, low, high, thresh1) 
%
% Function checks for clipping of data array
%  barImage= array
%  low     = low clip value
%  high    = high clip value
%  thresh1 = threshhold fraction [0-1] used for warning
%            if thresh1 = 0, all clipping is reported
% Peter Burns 5 Aug. 2002
% Copyright (c) International Imaging Industry Association

status = 1;

[nRow, nCol, nW] = size(barImage);
nhigh = zeros(nW, 1);
nlow =  zeros(nW, 1);

for k = 1: nW
    for j = 1: nCol
        for i = 1: nRow
            if barImage(i, j, k) < low
                nlow(k) = nlow(k) + 1;
            end
            if barImage(i, j, k) > high
                nhigh(k) = nhigh(k) + 1;
            end
            
        end
    end
end

nhigh = nhigh./ (nRow*nCol);
for k =1: nW
    if nlow(k) > thresh1
        disp([' *** Warning: low clipping in record ', num2str(k)]);
        status = 0;
    end
    if nhigh(k) > thresh1
        disp([' *** Warning: high clipping in record ', num2str(k)]);
        status = 0;
    end
end
nlow = nlow./(nRow*nCol);

if status ~= 1, warndlg('Data clipping errors detected','ClipCheck'); end

end

%% Newer deriv1 calculation
function b = deriv1(a, nRow, nCol, fil)
%  Computes first derivative via FIR (1xn) filter
%  Edge effects are suppressed and vector size is preserved
%  Filter is applied in the npix direction only
%   a = (nlin, npix) data array
%   fil = array of filter coefficients, eg [-0.5 0.5]
%   b = output (nlin, npix) data array
%  Author: Peter Burns, 1 Oct. 2008
%                       27 May 2020 updated to use 'same' conv option
%  Copyright (c) 2020 Peter D. Burns
%

b = zeros(nRow, nCol);

% Not sure what PB is doing here (BW).  Probably the 'edge effects'
for ii=1:nRow
    temp = squeeze(conv(a(ii,:),fil,'same'));

    b(ii, :)   = temp;
    b(ii,1)    = b(ii,2);
    b(ii,nCol) = b(ii,nCol-1);
end

end

%% findedge2 - seems to be an update on findedge
function  [p, s, mu] = findedge2(cent, nlin, nn)
% [slope, int] = findedge2(cent, nlin, nn)  Fits polynomial equation to data
% Fits poly. equation to data, written to process edge location array
%   cent = array of (centroid) values
%   nlin = length of cent
%   p values are coefficients from the least-square fit
%    x = int + slope*cent(x)
%  Note that this is the inverse of the usual cent(x) = int + slope*x
%  form
% Author: Peter Burns, pdburns@ieee.org
% Updated version of findedge using scaled x values 16 July 2019
% Copyright 2019 by Peter D. Burns. All rights reserved.

if nargin<3
    nn=1;
end
%  if nn>3
%      disp(['Warning: Polynominal fit to edge is of order ',num2str(nn)]);
%  end
index=0:nlin-1;
% Adding output variable mu makes the fit in centered and scaled x values
% this improves the fitting, 16 July 2019
[p, s, mu] = polyfit(index, cent, nn); % x = f(y)
% Next we 'unscale' the polynomial coefficients so we can use them easily
% later directly in sfrmat4
p = polyfit_convert(p, index);
end

%----------
function retval = polyfit_convert(p2, x) 
% Convert scaled polynomial fit vector to unscaled version  
%  
% p1 = polyfit(x,y,n); 
% [p2,S,mu] = polyfit(x,y,n); 
% p3 = polyfit_convert(p2); 
%   
% Peter Burns 5 June 2019
%             Based on a post by Wilburt van Hamm on Google Groups

n = numel(p2)-1; 
m = mean(x); 
s = std(x); 

retval = zeros(size(p2)); 
for i = 0:n 
  for j = 0:i 
     retval(n+1-j) = retval(n+1-j) + p2(n+1-i)*nchoosek(i, j)*(-m)^(i-j)/s^i; 
  end 
end

end

%-------------
function [r2, rmse, merror] = rsquare(y,f,varargin)
% Compute coefficient of determination of data fit model and RMSE
%
% [r2 rmse] = rsquare(y,f)
% [r2 rmse] = rsquare(y,f,c)
%
% RSQUARE computes the coefficient of determination (R-square) value from
% actual data Y and model data F. The code uses a general version of 
% R-square, based on comparing the variability of the estimation errors 
% with the variability of the original values. RSQUARE also outputs the
% root mean squared error (RMSE) for the user's convenience.
%
% Note: RSQUARE ignores comparisons involving NaN values.
% 
% INPUTS
%   Y       : Actual data
%   F       : Model fit
%
% OPTION
%   C       : Constant term in model
%             R-square may be a questionable measure of fit when no
%             constant term is included in the model.
%   [DEFAULT] TRUE : Use traditional R-square computation
%            FALSE : Uses alternate R-square computation for model
%                    without constant term [R2 = 1 - NORM(Y-F)/NORM(Y)]
%
% OUTPUT 
%   R2      : Coefficient of determination
%   RMSE    : Root mean squared error
%
% EXAMPLE
%   x = 0:0.1:10;
%   y = 2.*x + 1 + randn(size(x));
%   p = polyfit(x,y,1);
%   f = polyval(p,x);
%   [r2 rmse] = rsquare(y,f);
%   figure; plot(x,y,'b-');
%   hold on; plot(x,f,'r-');
%   title(strcat(['R2 = ' num2str(r2) '; RMSE = ' num2str(rmse)]))
%   
% Jered R Wells
% 11/17/11
% jered [dot] wells [at] duke [dot] edu
%
% v1.2 (02/14/2012)
%
% Thanks to John D'Errico for useful comments and insight which has helped
% to improve this code. His code POLYFITN was consulted in the inclusion of
% the C-option (REF. File ID: #34765).

if isempty(varargin); c = true; 
elseif length(varargin)>1; error 'Too many input arguments';
elseif ~islogical(varargin{1}); error 'C must be logical (TRUE||FALSE)'
else, c = varargin{1}; 
end

% Compare inputs
if ~all(size(y)==size(f)); error 'Y and F must be the same size'; end

% Check for NaN
tmp = ~or(isnan(y),isnan(f));
y = y(tmp);
f = f(tmp);

if c; r2 = max(0,1 - sum((y(:)-f(:)).^2)/sum((y(:)-mean(y(:))).^2));
else, r2 = 1 - sum((y(:)-f(:)).^2)/sum((y(:)).^2);
    if r2<0
    % http://web.maths.unsw.edu.au/~adelle/Garvan/Assays/GoodnessOfFit.html
        warning('Consider adding a constant term to your model') %#ok<WNTAG>
        r2 = 0;
    end
end

rmse = sqrt(mean((y(:) - f(:)).^2));
merror = mean(f(:) - y(:));

end

%{
%----------------------------------------------------
function  [slope, int] = findedge(cent, nRow)
% [slope, int] = findedge(cent, nRow)  Fits linear equation to data
% Fit linear equation to data, written to process edge location array
%   cent = array of (centroid) values
%   nRow = length of cent
%   slope and int are from the least-square fit
%    x = int + slope*cent(x)
%  Note that this is the inverse of the usual cent(x) = int + slope*x
%  form
% Peter Burns 5 Aug. 2002
% Copyright (c) International Imaging Industry Association

index = 0:nRow-1;
[slope, int] = polyfit(index, cent, 1);            % x = f(y)
end
%}

%----------------------------------------------------
function [array, status] = getoecf(array, oepath,oename)
% [array, status] = getoecf(array, oepath,oename)  Read and apply oecf
% Reads look-up table and applies it to a data array
%   array = data array (nRow, pnix, nWave)
%   oepath = table pathname, e.g. /home/sfr/dat
%   oename = tab-delimited text file for table (256x1, 256,3)
%   array = returns transformed array
%   status = 0  OK,
%          = 1 bad table file
% Peter Burns 5 Aug. 2002
% Copyright (c) International Imaging Industry Association

status = 0;
stuff = size(array);
nRow = stuff(1);
nCol = stuff(2);
if isequal(size(stuff),[1 2]),  nWave = 1;
else                            nWave = stuff(3);
end

temp = fullfile(oepath,oename);
oedat =load(temp);
%oedat = oename;
dimo = size(oedat);
if dimo(2) ~=nWave
    status = 1;
    return;
end
if nWave==1
    for i=1: nRow
        for j = 1: nCol
            array(i,j) = oedat( array(i,j)+1, nWave);
        end
    end
else
    for i=1: nRow
        for j = 1: nCol
            for k=1:nWave
                array(i,j,k) = oedat( array(i,j,k)+1, k);
            end
        end
    end
end
end

%----------------------------------------------------
function [select, coord] = getroi(array)
% [select, coord] = getroi(array)  Select and return region of interest
%
% Select and return image region of interest (ROI) via a GUI window and
% 'right-button-mouse' operation. If the mouse button is clicked and
%  released without movement, the entire displayed image will be selected.
%   array  (uint8)  - input image array(nRow, nCol [, ncolor])
%   select (double) - output ROI as an array(newlin, newpix[, ncolor])
%   coord is list of coordinates of ROI (upperleft(x,y),lowerright(x,y))
% Peter Burns 5 Aug. 2002
% Copyright (c) International Imaging Industry Association

dim = size(array);
nRow = dim(1);
nCol = dim(2);
if isequal(size(dim),[1 2]),  nWave =1;
else,                         nWave = dim(3);
end
screen = 0.95*(get(0, 'ScreenSize'));
% 0.95 is to allow a tolerance which I need so very large narrow images stay
% visible

% screen = get(0, 'ScreenSize');

% Set aspect ratio approx to that of array
rat = nCol/nRow;
if rat<0.25     % following lines make ROI selection of narrow images easier
    rat=0.25;
elseif rat>4
    rat = 4;
end
if nRow>=nCol
    if nRow > 0.5*screen(4)
        ht = min(nRow, 0.8*screen(4));    % This change helps with large images
    else
        ht = 0.5*screen(4);
    end
    wid = round(ht*rat);
else
    if nCol > 0.5*screen(3)
        wid = min(nCol, 0.8*screen(3));   % This change helps with large images
    else
        wid = 0.5*screen(3);
    end
    ht = round(wid/rat);
end
pos = round([screen(3)/10 screen(4)/10 wid ht]);
figure(1), set(gcf,'Position', pos);

disp(' ');
disp('Select ROI with right mouse button, no move = all');
disp(' ');

% This code may not be correct or used.
temp = class(array);
if ~strcmp(temp(1:5),'uint8')
    imagesc( double(array)/double(max(max(max(array))))),
    colormap(gray(64)),
    title('Select ROI');
elseif nWave == 1
    imagesc(array),
    colormap(gray(64)),
    title('Select ROI');
end
%axis off

% junk = waitforbuttonpress;
waitforbuttonpress;
ul=get(gca,'CurrentPoint');
% final_rect = rbbox;
rbbox;
lr=get(gca,'CurrentPoint');
ul=round(ul(1,1:2));
lr=round(lr(1,1:2));

if ul(1,1) > lr(1,1)             % sort x coordinates
    mtemp = ul(1,1);
    ul(1,1) = lr(1,1);
    lr(1,1) = mtemp;
end
if ul(1,2) > lr(1,2)             % sort y coordinates
    mtemp = ul(1,2);
    ul(1,2) = lr(1,2);
    lr(1,2) = mtemp;
end

roi = [lr(2)-ul(2)  lr(1)-ul(1)];  % if del x,y <10 pixels, select whole array
if roi(1)<10
    ul(2) =1;
    lr(2) =nRow;
end
if roi(2)<10
    ul(1) =1;
    lr(1) =nCol;
end
select=double( array(ul(2):lr(2), ul(1):lr(1), :) );
coord = [ul(:,:), lr(:,:)];
close;
end

%---------
function [point, status] = project2(bb, fitme, fac)
% [point, status] = project2(bb, fitme, fac)
% Projects the data in array bb along the direction defined by
%  npix = (1/slope)*nlin.  Used by sfrmat3, sfrmat4 functions.
% Data is accumulated in 'bins' that have a width (1/fac) pixel.
% The smooth, supersampled one-dimensional vector is returned.
%  bb = input data array
%  slope and loc are from the least-square fit to edge
%    y = loc + slope*cent(x)
%  fitme = polynomial fit for the edge (ncolor, npol+1), npol = polynomial
%          fit order. For a vertical edge, the fit is x = f(y). For a linear
%          fit, npol =1, e.g., fitme = [slope, offset]
%          
%  fac = oversampling (binning) factor, default = 4
%  Note that this is the inverse of the usual cent(x) = int + slope*x
%  status =1;
%  point = output edge profile vector
%  status = 1, OK
%  status = 1, zero counts encountered in binning operation, warning is
%           printed, but execution continues
%
% Copyright (c) Peter D. Burns, 2020
% Modified on 4 April 2017 to correct zero-count handling
%             24 June 2020
status =0;
[nlin, npix]=size(bb);

if nargin<3
 fac = 4 ;
end

slope = fitme(end-1);

nn = floor(npix *fac) ;

 slope =  1/slope;
  offset =  round(  fac*  (0  - (nlin - 1)/slope )   );

 del = abs(offset);
 if offset>0
     offset=0;
 end
 bwidth = nn + del+150;
 barray = zeros(2, bwidth);  %%%%%
 
 % Projection and binning
 p2 = zeros(nlin,1);
 
for m=1:nlin
    y = m-1;
    p2(m) =  polyval(fitme,y)-fitme(end);
end

% Projection and binning

for n=1:npix
    for m=1:nlin
        x = n-1;
        y = m-1;      
        ling =   ceil( (x - p2(m))*fac ) + 1 - offset;
        if ling<1
           ling = 1;
        elseif ling>bwidth     
           ling = bwidth;
        end
        barray(1,ling) = barray(1,ling) + 1;
        barray(2,ling) = barray(2,ling) + bb(m,n);
    end
end

 point = zeros(nn,1);
 start = 1+round(0.5*del); %*********************************

% Check for zero counts
  nz =0;
 for i = start:start+nn-1 % ********************************
% 
  if barray(1, i) ==0
   nz = nz +1;
   status = 0;  
   if i==1
    barray(1, i) = barray(1, i+1);
    barray(2, i) = barray(2, i+1); % Added the following steps
    elseif i==start+nn-1            
     barray(1, i) = barray(1, i-1);
     barray(2, i) = barray(2, i-1);
     
   else                           % end of added code
    barray(1, i) = (barray(1, i-1) + barray(1, i+1))/2;
    barray(2, i) = (barray(2, i-1) + barray(2, i+1))/2; % Added
   end
  end
 end
 % 
 if status ~=0
  disp('                            WARNING');
  disp('      Zero count(s) found during projection binning. The edge ')
  disp('      angle may be large, or you may need more lines of data.');
  disp('      Execution will continue, but see Users Guide for info.'); 
  disp(nz);
 end

 for i = 0:nn-1 
  point(i+1) = barray(2, i+start)/ barray(1, i+start);
 end
point = point';   % 4 Nov. 2019
end

%--------------------
function [correct] = fir2fix(n, m)
% [correct] = fir2fix(n, m);
% Correction for MTF of derivative (difference) filter
%  n = frequency data length [0-half-sampling (Nyquist) frequency]
%  m = length of difference filter
%       e.g. 2-point difference m=2
%            3-point difference m=3
% correct = nx1  MTF correction array (limited to a maximum of 10)
%
%Example plotted as the MTF (inverse of the correction)
%  2-point
%   [correct2] = fir2fix(50, 2);
%  3-point
%   [correct3] = fir2fix(50, 3);
%   figure,plot(1./correct2), hold on
%   plot(1./correct3,'--')
%   legend('2 point','3 point')
%   xlabel('Frequency index [0-half-sampling]');
%   ylabel('MTF');
%   axis([0 length(correct) 0 1])
%
% 24 July 2009
% Copyright (c) Peter D. Burns 2005-2009
%

correct = ones(n, 1);
m=m-1;
scale = 1;
for i = 2:n
    correct(i) = abs((pi*i*m/(2*(n+1))) / sin(pi*i*m/(2*(n+1))));
    correct(i) = 1 + scale*(correct(i)-1);
  if correct(i) > 10  % Note limiting the correction to the range [1, 10]
    correct(i) = 10;
  end
end

end

function [eff, freqval, sfrval] = sampeff(dat, val, del, fflag, pflag)
%sampeff(datout{ii}, [0.1, 0.5],  del, 1, 0);
%[eff, freqval, sfrval] = sampeff2(dat, val, del, fflag, pflag) Sampling efficiency from SFR
% First clossing method with local interpolation
%dat   = SFR data n x 2, n x 4 or n x 5 array. First col. is frequency
%val = (1 x n) vector of SFR threshold values, e.g. [0.1, 0.5]
%del = sampling interval in mm (default = 1 pixel)
%fflag = 1 filter [1 1 1 ] filtr applied to sfr
%      = 0 (default) no filtering
%pflag = 0 (default) plot results
%      = 1 no plots
%
%Peter Burns 6 Dec. 2005, modified 19 April 2009
%
if nargin < 4;
    pflag = 0;
    fflag =0;
end
if nargin < 3;
    del = 1;
end
if nargin < 2;
    val = 0.1;
end


%hs = 0.48/del;  changed 19 April 2009
hs = 0.495/del;
imax= length(dat(:,1)); % added 19 April 2009
x = find(dat(:,1) > hs);
if isempty(x) == 1;
    disp(' Missing SFR data, frequency up to half-sampling needed')
    eff = 0;  %%%%%
    freqval = 0;
    sfrval = 0;
    return
end
nindex = x(1);  % added 19 April 2009
%imax = x(1);   % Changed 19 April 2009
dat = dat(1: imax, :);

[n, m, nc] = size(dat);
nc = m - 1;
imax = n;
nval = length(val);
eff = zeros(nval, nc);
freqval = zeros(nval, nc);
sfrval = zeros(nval, nc);

for v = 1: nval;
 [freqval(v, :), sfrval(v, :)] = findfreq(dat, val(v), imax, fflag);
 freqval(v, :)=clip(freqval(v, :),0, hs); %added 19 April 2009 ****************
for c = 1:nc
  %eff(v, c) = min(round(100*freqval(v, c)/dat(imax,1)), 100);
  eff(v, c) = min(round(100*freqval(v, c)/hs), 100); %  ************************
end
end

if pflag ~= 0;
    
for c =1:nc
 se = ['Sampling efficiency ',num2str(eff(1,c)),'%'];
  
 disp(['  ',se])
 figure,
	plot(dat(:,1),dat(:,c+1)),
	hold on
    for v = 1:nval
     plot(freqval(v, c),sfrval(v, c),'r*','Markersize', 12),
    end
     plot(dat(:,1),0.1*ones(length(dat(:,1))),'b--'),
     plot([dat(nindex,1),dat(nindex,1)],[0,.1],'b--'),
%     title(fn),
     xlabel('Frequency'),
     ylabel('SFR'),
     text(0.8*dat(end,1),0.95, ['SE = ',num2str(eff(1,c)),'%'])
     axis([0, dat(imax, 1), 0, 1]),
     hold off
end

end   
end

%----------
function [freqval, sfrval] = findfreq(dat, val , imax, fflag)
%[freqval, sfrval] = findfreq(dat, val, imax, fflag) find frequency for specified
%SFR value
% dat   = SFR data n x 2, n x 4 or n x 5 array. First col. is frequency
% val = threshold SFR value, e.g. 0.1
% imax = index of half-sampling frequency (normally n)
%fflag = 1  filter [1 1 1] SFR data
%      = 0 no filter (default)
% freqval = frequency corresponding to val; (1 x ncolor)
% SFR corresponding to val (normally = val) (1 x ncolor)
%
%Peter Burns 6 Dec. 2005

if nargin < 4;
    fflag = 0;
end

[n, m, nc] = size(dat);
nc = m - 1;
frequval = zeros(1, nc);
sfrval = zeros(1, nc);

maxf = dat(imax,1);
fil = [1, 1, 1]/3;
fil = fil';
for c = 1:nc;
    if fflag ~= 0;
        temp = conv2(dat(:, c+1), fil, 'same');
	    dat(2:end-1, c+1) = temp(2:end-1);
    end
    test = dat(:, c+1) - val;
	x = find(test < 0) - 1; % First crossing of threshold
   
	if isempty(x) == 1 | x(1) == 0;
        
		s = maxf;
        sval = dat(imax, c+1);

		else                 % interpolation
        x = x(1);
        sval = dat(x, c+1);
        s = dat(x,1);
		y = dat(x, c+1);
        y2 = dat(x+1, c+1);
        slope = (y2-y)/dat(2,1);
        dely =  test(x, 1);
        s = s - dely/slope;
        sval = sval - dely; 
    end
    if s > maxf;
       s = maxf;
       sval = dat(imax, c+1);
    end
    
    freqval(c) = s;
    sfrval(c) = sval;
    
end

end

% {
% This should be replaced by project2 when I understand it (BW)
%----------------------------------------------------
function [point, status] = project(barImage, loc, slope, fac)
%Projects data along the slanted edge to a common line
%
%  [point, status] = project(barImage, loc, slope, fac)
%
% The data in array barImage are projected along the direction defined by
%
%    nCol = (1/slope)*nRow
%
% Data are accumulated in 'bins' that have a width (1/fac) pixel.
%
% The supersampled one-dimensional vector is returned.
%
% Variables:
%  barImage:        input data array of image
%  slope.loc: calculated from the least-square fit to edge in a
%  separate routine ()
%
%    x = loc + slope*cent(x)
%         Note that this is the inverse of the usual cent(x) = int + slope*x
%
%  fac:    oversampling (binning) factor  (default = 4)
%  point:  output vector of
%  status = 1, OK
%  status = 0, zero counts encountered in binning operation
%              arning is printed, but execution continues
%
% See also: sfrmat11 and sfrmat2 functions.
%
% Peter Burns 5 Aug. 2002
% Copyright (c) International Imaging Industry Association
%
% Edited by ImagEval, 2006-2007
%
% Notes:  This so-called projection operator is really an alignment
% operation.  The data along the different rows are slid so that the
% edge of the slanted bar on the different lines is the same.  I
% think.

if (nargin < 4), fac = 4 ; end

status = 1;                      % Assume we are good to go
[nRow, nCol] = size(barImage);   % Size of the bar image
% figure(1); imagesc(barImage); axis image; colormap(gray(255))

% big = 0;
nn = nCol *fac ;

% smoothing window.  Why is this not used?  I commented out.
% win = ahamming(nn, fac*loc(1, 1));
% plot(win)
slope =  1/slope;
offset =  round(  fac * (0  - (nRow - 1)/slope )   );

del = abs(offset);
if offset>0, offset=0; end

barray = zeros(2, nn + del + 100);

% Projection and binning
for n=1:nCol
    for m=1:nRow
        x = n-1;
        y = m-1;
        ling =  ceil((x  - y/slope)*fac) + 1 - offset;
        barray(1,ling) = barray(1,ling) + 1;
        barray(2,ling) = barray(2,ling) + barImage(m,n);
    end
end

% Initialize
point = zeros(nn,1);
start = 1+round(0.5*del);

% Check for zero counts
nz =0;
for i = start:start+nn-1
    if barray(1, i) == 0
        nz = nz +1;
        status = 0;
        if i==1,  barray(1, i) = barray(1, i+1);
        else,     barray(1, i) = (barray(1, i-1) + barray(1, i+1))/2;
        end
    end
end

if status == 0
    disp('                            WARNING');
    disp('      Zero count(s) found during projection binning. The edge ')
    disp('      angle may be large, you may need more lines of data.');
    disp('      Or the short edges of the rect may not cover the line');
    disp('      Execution will continue, but see Users Guide for info.');
    disp(nz);
end

% Combine into a single edge profile, point
for i = 0:nn-1
    point(i+1) = barray(2, i+start)/ barray(1, i+start);
end

% This is the returned unified edge profile
% figure(1); plot(point);

end
%}
%----------------------------------------------------
function [a, nlin, npix, rflag] = rotatev2(a)
%[a, nlin, npix, rflag] = rotatev2(a)     Rotate edge array vertical
% Rotate array so that the edge feature is in the vertical orientation
% Test based on array values not dimensions.
% a = input array(npix, nlin, ncol)
% nlin, npix are after rotation if any
% flag = 0 no roation, = 1 rotation was performed
%
% Needs: rotate90
%
% 24 Sept. 2008
% Copyright (c) 2008 Peter D. Burns

dim = size(a);
nlin = dim(1);
npix = dim(2);
a = double(a);

% Select which color record, normally the second (green) is good
if length(dim) == 3
    mm = 2;
else
    mm =1;
end

nn = 3;  % Limits test area. Normally not a problem.
%Compute v, h ranges
testv = abs(mean(a(end-nn,:,mm))-mean(a(nn,:,mm)));
testh = abs(mean(a(:,end-nn,mm))-mean(a(:,nn,mm)));

 rflag =0;
 if testv > testh
     rflag =1;
     a = rotate90(a);
     temp=nlin;
     nlin = npix;
     npix = temp;
 end

 end

%% --------- Could be put inside rotatev2

function out = rotate90(in, n)
%rotate90: 90 degree counterclockwise rotations of matrix
%
%[out] = rotate90(in, n) 
% in  = input matrix (n,m) or (n,m,k)
% n   = number of 90 degree rotation
% out = rotated matrix
%       default = 1
% Usage:
%  out = rotate90(in)
%  out = rotate90(in, n)
% Needs:
%  r90 (in this file)
%
% Author: Peter Burns
% Copyright (c) 2015 Peter D. Burns

if nargin < 2
 n = 1;
end

nd = ndims(in);

if nd < 1
 error('input to rotate90 must be a matrix');
end

for i = 1:n
 out = r90(in);
 in = out;
end

end


%%
function [out] = r90(in)

[nlin, npix, nc] = size(in);
temp = zeros (npix, nlin);
temp = 0*in(:,:,1);
cl = class(temp);
arg1=['out = ',cl,'(zeros(npix, nlin, nc));'];
eval(arg1);

for c = 1: nc

    temp =  in(:,:,c);
    temp = temp.';
    out(:,:,c) = temp(npix:-1:1, :);
                     
end

out = squeeze(out);
end

%{
%-----------------------Deprecated in sfrmat4----------------------
function [a, nRow, nCol, rflag] = rotatev(a)
% [a, nRow, nCol, rflag] = rotatev(a)    Rotate array
%
% Rotate array so that long dimensions is vertical (line) drection
% a = input array(nCol, nRow, nWave)
% nRow, nCol are after rotation if any
% flag = 0 no roation, = 1 rotation was performed
%
% Peter Burns 5 Aug. 2002
% Copyright (c) International Imaging Industry Association

dim = size(a);
nRow = dim(1);
nCol = dim(2);

if isequal(size(dim),[1 2]), nWave =1;
else,                        nWave = dim(3);
end

rflag =0;
if nCol>nRow
    rflag =1;
    b    = zeros(nCol, nRow, nWave);
    % temp = zeros(nCol, nRow);
    for i=1:nWave
        temp = a(:, :, i)';
        b(:,:,i) = temp;
    end
    a = b;
    temp=nRow;
    nRow = nCol;
    nCol = temp;
end

end
%}