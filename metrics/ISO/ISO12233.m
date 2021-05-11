function [results, fitme, esf, h] = ISO12233(barImage, deltaX, weight, plotOptions)
% ISO 12233 (slanted bar) spatial frequency response (SFR) analysis.
%
%  [results, fitme, esf, h] = ISO12233(barImage, deltaX, weight,plotOptions);
%
% Slanted-edge and color mis-registration analysis.
%
% barImage:  The RGB image of the slanted bar
% deltaX:    The sensor sample spacing in millimeters (expected). It
%   is possible to send in a display spacing in dots per inch (dpi), in
%   which case the number is > 1 (it never is for sensor sample spacing).
%   In that case, the value returned is cpd on the display at a 1m viewing
%   distance.
%
%   See notes below about translating to cyc/deg in the original scene. See
%   TODO in code about this practice.
%
% weight:    The luminance weights; these are [0.3R +  0.6G + 0.1B] by
%            default.
%
% fitme:  The full linear fit to something
% esf:    Not sure
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
%   ISO12233;
% You are prompted for a bar file and other parameters:
%
% Reference
%  This code originated with Peter Burns, peter.burns@kodak.com
%  12 August 2003, Copyright (c) International Imaging Industry Association
%  Substantially re-written by ImagEval Consulting, LLC
%
% See also: ieISO12233, ISOFindSlantedBar
%
% Copyright ImagEval Consultants, LLC, 2005.

% Examples:
%{
  % Interactive usage 
  ISO12233;
   
  %
  deltaX = 0.006; % Six micron pixel
  [results, fitme, esf] = ISO12233([],deltaX,[]);

  deltaX = 90; % Dots per inch.  Hunh?
  [results, fitme, esf] = ISO12233([],deltaX,[]);

  %The whole thing and cpd assuming a 1m viewing distance
  rectMTF    = [xmin ymin width height];
  c = rectMTF(3)+1; r = rectMTF(4)+1;
  roiMTFLocs = ieRect2Locs(rectMTF);
  barImage   = vcGetROIData(vciBlurred,roiMTFLocs,'results');
  barImage = reshape(barImage,r,c,3);
  wgts = [ 0.3 0.6 0.1];
  [results, fitme, esf] = ISO12233(barImage,deltaX,wgts,'luminance');
%}

% PROGRAMMING TODO: 
%  Rather than decode pixelWidth and dpi based on the value, we should
%  probably set a flag and be explicit.

%%
if ieNotDefined('deltaX'), deltaX = .002;  warning('Assuming 2 micron pixel');  end
if ieNotDefined('weight'), weight = [0.3, 0.6, 0.1]; end  % RGB: Luminance weights
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
[barImage, nRow, nCol, rflag] = rotatev(barImage);
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
% to used on each line of ROI
win1 = ahamming(nCol, (nCol+1)/2);      % Symmetric window
for color=1:nWave                       % Loop for each color
    %     if nWave == 1, pname = ' ';
    %     else pname =[' Red ' 'Green'  'Blue ' ' Lum '];
    %     end
    c = deriv1(barImage(:,:,color), nRow, nCol, fil1);
    % vcNewGraphWin; imagesc(c); colormap(gray)
    % compute centroid for derivative array for each line in ROI. NOTE WINDOW array 'win'
    for n=1:nRow
        % -0.5 shift for FIR phase
        loc(color, n) = centroid( c(n, 1:nCol )'.*win1) - 0.5;
    end
    % clear c
    
    fitme(color,:) = findedge(loc(color,:), nRow);
    place = zeros(nRow,1);
    for n=1:nRow
        place(n) = fitme(color,2) + fitme(color,1)*n;
        win2 = ahamming(nCol, place(n));
        loc(color, n) = centroid( c(n, 1:nCol )'.*win2) -0.5;
    end
    
    fitme(color,:) = findedge(loc(color,:), nRow);
    % fitme(color,:); % used previously to list fit equations
end

summary{1} = ' ';                 % initialize
nWaveOut = nWave;                 % output edge location listing
if nWave == 4, nWaveOut = nWave - 1; end

midloc = zeros(nWaveOut,1);
summary{1} = 'Edge location, slope'; % initialize

for i=1:nWaveOut
    slout(i) = - 1./fitme(i,1);     % slope is as normally defined in image coords.
    if rflag==1                     % positive flag it ROI was rotated
        slout(i) =  -fitme(i,1);
    end
    
    % evaluate equation(s) at the middle line as edge location
    midloc(i) = fitme(i,2) + fitme(i,1)*((nRow-1)/2);
    
    summary{i+1} = [midloc(i), slout(i)];
end

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
% be the interpolated edge for each of the color channels.
esf = zeros(nn,nWave);

for color=1:nWave
    % project and bin data in 4x sampled array
    point = project(barImage(:,:,color), loc(color, 1), fitme(color,1), nbin);
    % vcNewGraphWin; plot(point); colormap(gray)
    esf(:,color) = point;  % Not sure what esf stands for. Estimated spatial frequency?
    
    % compute first derivative via FIR (1x3) filter fil
    c = deriv1(point', 1, nn, fil2);  % vcNewGraphWin; plot(c)
    c = c';
    mid = centroid(c);
    temp = cent(c, round(mid));       % shift array so it is centered
    c = temp;
    clear temp;
    
    % apply window (symmetric Hamming)
    c = win.*c;    % vcNewGraphWin; plot(c)
    
    % Transform, scale %% The FFT of the point spread, 
    temp = abs(fft(c, nn));    % vcNewGraphWin; plot(temp)
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
results.nyquistf = nfreq;
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
    [v,idx] = min(abs(iLumMTF - 0.5));
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
        h = vcNewGraphWin;
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

return;

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

return;

%----------------------------------------------------
function [data] = ahamming(n, mid)
%
% [data] = ahamming(n, mid)  Generates asymmetrical Hamming window
%  array. If mid = (n+1)/2 then the usual symmetrical Hamming array
%  is returned
%   n = length of array
%   mid = midpoint (maximum) of window function
%   data = window array (nx1)
% Peter Burns 5 Aug. 2002
% Copyright (c) International Imaging Industry Association

data = zeros(n,1);

wid1 = mid-1;
wid2 = n-mid;
wid = max(wid1, wid2);
for i = 1:n
    arg = i-mid;
    data(i) = 0.54 + 0.46*cos( pi*arg/wid );
end
return;

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

%----------------------------------------------------
function [loc] = centroid(x)
%
% [loc] = centroid(x)  Finds centroid of vector
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
return;

%----------------------------------------------------
function [nlow, nhigh, status] = clipping(barImage, low, high, thresh1)
%
% [n, status] = clipping(a, low, high, thresh1) Checks for data clipping
%
% Function checks for clipping of data array
%  barImage= array
%  low     = low clip value
%  high    = high clip value
%  thresh1 = threshhold fraction [0-1] used for warning,
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

return;
%----------------------------------------------------
function  [b] = deriv1(a, nRow, nCol, fil)
%
% [b] = deriv1(a, nRow, nCol, fil)   First derivative of array
%  Computes first derivative via FIR (1xn) filter
%  Edge effects are suppressed and vector size is preserved
%  Filter is applied in the nCol direction only
%   a   = (nRow, nCol) data array
%   fil = array of filter coefficients, eg [[-0.5 0.5]
%   b   = output (nRow, nCol) data array
% Peter Burns 5 Aug. 2002
% Copyright (c) International Imaging Industry Association

b = zeros(nRow, nCol);
nn = length(fil);
for i=1:nRow
    temp = conv(fil, a(i,:));
    b(i, nn:nCol) = temp(nn:nCol);    %ignore edge effects, preserve size
    b(i, nn-1) = b(i, nn);
end

return;

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
return

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
return;
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

temp = class(array);
if ~strcmp(temp(1:5),'uint8')
    imagesc( double(array)/double(max(max(max(array))))),
    colormap('gray'),
    title('Select ROI');
else
    if nWave == 1
        imagesc(array),
        colormap('gray'),
        title('Select ROI');
    else
        imagesc(array),
        colormap('gray'),
        title('Select ROI');
    end
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
return;

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

return;


%----------------------------------------------------
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

return
