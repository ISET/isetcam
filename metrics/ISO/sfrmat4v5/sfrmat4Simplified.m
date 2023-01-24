function [status, dat, e, fitme, esf, nbin, del2] = sfrmat4(io, del, npol, weight, barImage)
%******************************************************************
% MATLAB function: sfrmat4 (v5) Slanted-edge Analysis with polynomial edge fit
%  [status, dat, e, fitme, esf, nbin, del2] = sfrmat4(io, del, npol,weight, a);
%       From a selected edge area of an image, the program computes
%       the ISO slanted edge SFR. Input file can be single or
%       three-record file. Many image formats are supported. The image
%       is displayed and a region of interest (ROI) can be chosen, or
%       the entire field will be selected by not moving the mouse
%       when defining an ROI. Either a vertical or horizontal edge
%       feature. 
%  Input arguments:
%      io  (optional)
%        0 = (default) R,G,B,Lum SFRs + edge location(s)
%        1 = Non GUI usage with supplied image data array
%      del (optional) sampling interval in mm or pixels/inch
%          If dx < 1 it is assumed to be sampling pitch in mm
%          If io = 1 (see below, no GUI) and del is not specified,
%          it is set equal to 1, so frequency is given in cy/pixel.
%      npol = order of polynomial fit to edge [1-5]
%           = 1 (default) linear fit as per current ISO 12233 Standard
%           = 2 second-order fit
%           = 3 third-order fit
%      weight (optiona) default 1 x 3 r,g,b weighs for luminance weighting
%      a   (required if io =1) an nxm or nxmx3 array of data
%
% Returns: 
%       status = 0 if normal execution
%       dat = computed sfr data
%       e = sampling efficiency
%       fitme = coefficients for the linear equations for the fit to
%               edge locations for each color-record. For a 3-record
%               data file, fitme is a (4 x 3) array, with the last column
%               being the color misregistration value (with green as 
%               reference).
%       esf = supersampled edge-spread function array
%       nbin = binning factor used
%       del2 = sampling interval for esf, from which the SFR spatial
%              frequency sampling is was computed. This will be 
%              approximately 4 times the original image sampling.
%
%EXAMPLE USAGE:
% sfrmat4     file and ROI selection and 
% sfrmat4(1) = Non-GUI usage
% sfrmat4(0, del) = GUI usage with del as default sampling in mm 
%                   or dpi 
% sfrmat4(0, del, weight) = GUI usage with del as default sampling
%                   in mm or dpi and weight as default luminance
%                   weights
% sfrmat4(1, dat) = non-GUI usage for data array, dat, with default
%                   sampling and weights aplied (del =1, 
%                   weights = [0.213   0.715   0.072])
% [status, dat, fitme] = sfrmat4(1, del, weight, a);
%                   sfr and edge locations, are returned for data
%                   array a, with specified sampling interval and luminance
%                   weights
% 
%Author: Peter Burns, Based on sfrmat3, adapted for polynomial edge fitting                    
%         27 Oct. 2020 Updated with support for *.ptw and *.ptm image files
%                      from FLIR (forward-looking infrared) cameras.
%          4 Feb. 2022 added setting of default polynomial fit order
% Copyright (c) 2009-2022 Peter D. Burns, pdburns@ieee.org
%
%****************************************************************************
[nRow, nCol, nWave] = size(barImage);

% Form luminance record using the weight vector for red, green and blue
if nWave ==3
    % lum = zeros(nRow, nCol);
    lum = weight(1)*barImage(:,:,1) + weight(2)*barImage(:,:,2) + weight(3)*barImage(:,:,3); 
    % cc = zeros(nRow, nCol*4);
    cc = [ barImage(:, :, 1), barImage(:, :, 2), barImage(:,:, 3), lum];
    cc = reshape(cc,nRow,nCol,4);

    barImage = cc;
    clear cc;
    clear lum;
    nWave = 4; 
end

% Rotate horizontal edge so it is vertical
% Deleted: rflag = 0;
 [barImage, nRow, nCol, rflag] = rotatev2(barImage);  %based on data values

loc = zeros(nWave, nRow);

lowhi = 0;
fil1 = [0.5 -0.5];
fil2 = [0.5 0 -0.5];
% We Need 'positive' edge
tleft  = sum(sum(barImage(:,      1:5,  1),2));
tright = sum(sum(barImage(:, nCol-5:nCol,1),2));
if tleft>tright
    lowhi = 1;
    fil1 = [-0.5 0.5];
    fil2 = [-0.5 0 0.5];
end
% Test for low contrast edge;
 test = abs( (tleft-tright)/(tleft+tright) );
 if test < 0.2
    disp(' ** WARNING: Edge contrast is less that 20%, this can');
    disp('             lead to high error in the SFR measurement.');
 end

fitme = zeros(nWave, npol+1); %%%%%%%%%%%%%%%%%%%%%
slout = zeros(nWave, 1);

% Smoothing window for first part of edge location estimation - 
%  to be used on each line of ROI
 win1 = ahamming(nCol, (nCol+1)/2);    % Symmetric window

for color=1:nWave                      % Loop for each color
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    c = deriv1(barImage(:,:,color), nRow, nCol, fil1);
    
% compute centroid for derivative array for each line in ROI. NOTE WINDOW array 'win1'
    for n=1:nRow
        loc(color, n) = centroid( c(n, 1:nCol )'.*win1) - 0.5;   % -0.5 shift for FIR phase
    end
    
    fitme(color,:) = findedge2(loc(color,:), nRow, npol); %%%%%%%%%%%%%%%%
    
    place = zeros(nRow,1);
    for n=1:nRow 
        place(n) = polyval(fitme(color,:), n-1);  %%%%%%%%%%%%%%%%%%%%%%%
        win2 = ahamming(nCol, place(n));
        loc(color, n) = centroid( c(n, 1:nCol )'.*win2) -0.5;
    end
   
    [fitme(color,:)] = findedge2(loc(color,:), nRow, npol);
% For comparison with linear edge fit
    [fitme1(color,:)] = findedge2(loc(color,:), nRow, 1);

%???
    if npol>3
        x = 0: 1: nRow-1;
        y = polyval(fitme(color,:), x);%%
        y1 = polyval(fitme1(color,:),x);%%   
        [r2, rmse, merror] = rsquare(y,loc(color,:));
        disp(['mean error: ',num2str(merror)]);
        disp(['r2: ',num2str(r2),' rmse: ',num2str(rmse)]);
    end 
 
end                                         % End of loop for each color
clear c
summary{1} = ' '; % initialize

midloc = zeros(nWave,1);
summary{1} = 'Edge location, slope'; % initialize
sinfo.edgelab = 'Edge location, slope';
for i=1:nWave
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    slout(i) = - 1./(fitme(i,end-1)); %%%%%% slope is as normally defined in image coods.
    if rflag==1                       % positive flag if ROI was rotated
        slout(i) =  - fitme(i,end-1); %%%%%%%
    end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % evaluate equation(s) at the middle line as edge location
    midloc(i) = polyval(fitme(i,:), (nRow-1)/2); %%%%%%%%%
    summary{i+1} = [midloc(i), slout(i)];
    sinfo.edgedat = [midloc(i), slout(i)];
end


if nWave>2
    summary{1} = 'Edge location, slope, misregistration (second record, G, is reference)';
    sinfo.edgelab = 'Edge location, slope, misregistration (second record, G, is reference)';
    misreg = zeros(nWave,1);
    temp11 = zeros(nWave,3);
    for i=1:nWave
        misreg(i) = midloc(i) - midloc(2);
        temp11(i,:) = [midloc(i), slout(i), misreg(i)];
        summary{i+1}=[midloc(i), slout(i), misreg(i)];      
       % fitme(i,end) =  misreg(i);
    end
    sinfo.edgedat = temp11;
    clear temp11
    if io == 5 
        disp('Misregistration, with green as reference (R, G, B, Lum) = ');
        for i = 1:nWave
            fprintf('%10.4f\n', misreg(i))
        end
    end  % io ==5
end  % ncol>2

% end                             %************ end of check if io > 0


% Full linear fit is available as variable fitme. Note that the fit is for
% the projection onto the X-axis,
%       x = fitme(color, 1) y + fitme(color, 2)
% so the slope is the inverse of the one that you may expect

% Limit number of lines to integer(npix*line slope as per ISO algorithm  
    nRow1 = round(floor(nRow*abs(fitme(1,end-1)))/abs(fitme(1,end-1))); %%%
    barImage = barImage(1:nRow1, :, 1:nWave);           
    
if npol>3
        disp(['Edge fit order = ',num2str(npol)]);
end

vslope = fitme(end,end-1);                      % Based on luminance record
slope_deg= 180*atan(abs(vslope))/pi;
disp(['Edge angle: ',num2str(slope_deg, 3),' degrees'])
if slope_deg < 1
%   beep, warndlg(['High slope warning ',num2str(slope_deg,3),' degrees'], 'Watch it!')
end

% For future use
% nbin = nbin*cos(atan(vslope)); %%%%%%%%%%%%%%%%%%%%%%%%%%%%

delimage = del;

%Correct sampling inverval for sampling normal to edge
delfac = cos(atan(vslope));
% delfac = 1; (future use)
del = del*delfac;  % input pixel sampling normal to the edge   
del2 = del/nbin;   % Supersampling interval normal to edge

samp(3) = del2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ns = length(summary);
summary{ns+1} = [delimage, del2];
sinfo.samp = [delimage del del2 nbin];

nn =   floor(nCol *nbin);
mtf =  zeros(nn, nWave);
nn2 =  floor(nn/2) + 1;

%   disp('Derivative correction')
    dcorr = fir2fix(nn2, 3);   % dcorr corrects SFR for response of FIR filter
    
freqlim = 1;
if nbin == 1
    freqlim = 2;  %%%%%%%%%%%%
end
nn2out = round(nn2*freqlim/2);
nfreq = nn/(2*delimage*nn);    % half-sampling frequency

% %%%%%%%%%%%%                      Large SFR loop for each color record
esf = zeros(nn,nWave);  

for color=1:nWave
  % project and bin data in 4x sampled array  
    [esf, status] = project2(barImage(:,:,color), fitme(color,:), nbin);
    esf = esf';
%%%%%%%%%%% added 21 June 2018 for use with circular edge analysis %%%%%%%
%    n1 =  find(isnan(esf));
%    if isempty(n1)~=1
%     esf = esf(n1(end)+1:end,:);
%    end
%     nn = length(esf);    
%     esf1(1:nn,color) = esf;  
%%%%%%%%%%%%

c = deriv1(esf', 1, nn, fil2); 

% Added 19 April 2017
if c(1) == 0
   c(1) = c(2);
elseif c(end) == 0
   c(end) = c(end-1);
end  
%%%%%%%%%%%%%%%%%%%%%
% 21 June 2018
nn = length(c);
% mid = round(nn/2);
mid = find(c==max(c));
mid = mean(mid);
win = ahamming(nn, mid);   

    c = win.*c(:); 
    
    if pflag ==1
        figure;
        plot(c); hold on,
        xlabel('n'), ylabel('PSF'),title('psf with window');
        hold off;      
    end
    
    % Transform, scale and correct for derivative filter response

    temp = abs(fft(c, nn));
    mtf(1:nn2, color) = temp(1:nn2)/temp(1);         
    mtf(1:nn2, color) = mtf(1:nn2, color).*dcorr;
    
end     % color=1:ncol

esf = esf(1:nn,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
freq = zeros(nn, 1);
for n=1:nn   
    freq(n) = (n-1)/(del2*nn);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dat = zeros(nn2out, nWave+1);
for i=1:nn2out
    dat(i,:) = [freq(i), mtf(i,:)];
end

% Add color misregistration to fitme matrix
temp1 = zeros(nWave, npol+2);
temp1(1:nWave,1:npol+1) = fitme;
if nWave>2
 temp1(:,end) = misreg;
fitme = temp1;
end
ns = length(summary);
summary{ns+1}=fitme; 
sinfo.fitme = fitme;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Sampling efficiency
%Values used to report: note lowest (10%) is used for sampling efficiency
val = [0.1, 0.5];

[e, freqval, sfrval] = sampeff(dat, val, delimage, 0, 0);  %%%%% &&&
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ns = length(summary);
summary{ns+1} = e;
summary{ns+2} = freqval;
summary{ns+3} = npol;
summary{ns+4} = samp;

sinfo.se = e;
sinfo.sfr1050 = freqval;
sinfo.npol = npol;

if io ==1         
    return
end
% Plot SFRs on same axes
if nWave >1
  sym{1} = []; 
  sym{1} = '--r';
  sym{2} = '-g';
  sym{3} = '-.b';
  sym{4} = '*k';
  ttext = [filename];
  legg = [{'r'},{'g'},{'b'},{'lum'}];
else
  ttext = filename;
  sym{1} = 'k';
end

pos = round(centerfig(1, 0.6,0.6));
  
%%%%%%%%
figure('Position',pos)
 plot( freq( 1:nn2out), mtf(1:nn2out, 1), sym{1});
 hold on;
  title(ttext, 'interpreter','none');
  xlabel(['     Frequency, ', funit]);
  ylabel('SFR');
	if nWave>1
		for n = 2:nWave-1
			plot( freq( 1:nn2out), mtf(1:nn2out, n), sym{n});
        end
		ndel = round(nn2out/30);
		plot(  freq( 1:ndel:nn2out), mtf(1:ndel:nn2out, nWave), 'ok',...
            freq( 1:nn2out), mtf(1:nn2out, nWave), 'k')
		
            line([nfreq ,nfreq],[.05,0]); 
            h=legend(['r   ',num2str(e(1,1)),'%'],...
                        ['g   ',num2str(e(1,2)),'%'],...
                        ['b   ',num2str(e(1,3)),'%'],...
                        ['L   ',num2str(e(1,4)),'%']);
                    
            pos1 =  get(h,'Position');
            set(h,'Position', [0.97*pos1(1) 0.93*pos1(2) pos1(3) pos1(4)])
            set(get(h,'title'),'String','Sampling Efficiency');             
				
		else % (ncol ==1)
                line([nfreq ,nfreq],[.05,0]);
                h = legend([num2str(e(1)),'%']);
                get(h,'Position');
                pos1 =  get(h,'Position');
                set(h,'Position', [0.97*pos1(1) 0.93*pos1(2) pos1(3) pos1(4)])
                set(get(h,'title'),'String','Sampling Efficiency');          			

    end % ncol>1

   text(.95*nfreq,+.08,'Half-sampling'),

 hold off;
 maxfplot = max(freq(round(0.75*nn2out)), 1.04*nfreq);
 axis([0 maxfplot,0,max(max(mtf(1:nn2out,:)))]);

drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
defname = [pathname,'*.xls'];
   [outfile,outpath]=uiputfile(defname,'File name to save results (.xls will be added)');
   foutfile=[outpath,outfile];

   if size(foutfile)==[1,2]
      if foutfile==[0,0]
         disp('Saving results: Cancelled')
      end
   else
       
    nn = find(foutfile=='.', 1);
    if isempty(nn) ==1
       foutfile=[foutfile,'.xls'];
    end

    results4(dat, filename, roi, oename, sinfo, foutfile);
   end

% Clean up

% Reset text interpretation
  set(0, 'DefaultTextInterpreter', 'tex')
  path(defpath);           % Restore path to previous list
  cd(home);                % Return to working directory
 
return;

