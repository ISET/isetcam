function [status, dat, e, fitme, esf, nbin, del2] = ieSFRmat4(io, deltaX, npol, weight, barImage)
%******************************************************************
% Slanted-edge Analysis with polynomial edge fit based on sfrmat4 (v5) 
%
%  ieSFRmat4(barImage, deltaX, weight, plotOptions)
%
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

if ieNotDefined('deltaX'), deltaX = .002;  warning('Assuming 2 micron pixel');  end
if ieNotDefined('weight'), weight = [0.213   0.715   0.072]; end  % RGB: Luminance weights
if ieNotDefined('plotOptions'), plotOptions = 'all'; end  % all or luminance or none

status = 0;
pflag = 0; %Used for diagnostic plotting, set pflag = 1 for lots of plots
 
defpath = path;            % save original path
home = pwd;                % add current directory to path                   

name =    'sfrmat4';
version = '5';
when =    '4 Feb. 2022';


%%
%{

status = 0;
pflag = 0; %Used for diagnostic plotting, set pflag = 1 for lots of plots
 
defpath = path;            % save original path
home = pwd;                % add current directory to path                   

name =    'sfrmat4';
version = '5';
when =    '4 Feb. 2022';

guidefweight =  ['0.213'
                 '0.715'
                 '0.072'];
% Default RGB -> luminance weights            
defweight = [0.213   0.715   0.072];
% Default order of polynomial edge fitting
defnpol = 1;
oename = 'none';

% Super-sampling factor for binning
nbin = 4;

% Burns deals with various types of input arguments.  BW adds the comments

switch nargin

    case 0
     % sfrmat4;
     io = 0;
     deltaX = 1;
     npol = defnpol;
     weight = guidefweight;

    case 1
      % sfrmat4(io)
      if isempty(io) ==1
          io =0;
      end
      deltaX = 1;
      npol = defnpol;
      weight = guidefweight;

    case 2
      % sfrmat4(io, deltaX)
     if isempty(io) == 1
         io = 0;
     end
     if isempty(deltaX) == 1
         deltaX = 1;
     end
     npol = defnpol;
     weight = guidefweight;
     
    case 3
      % sfrmat4(io, deltaX, npol)

      if isempty(io) == 1
         io = 0;
      end
      if isempty(deltaX) == 1
         deltaX = 1;
      end
      if isempty(npol) == 1
         npol = defnpol;  
      end
      
    case 4
      % sfrmat4(io, deltaX, npol, weight)

      if isempty(io) == 1
         io = 0;
      end
      if isempty(deltaX) == 1
         deltaX = 1;
      end
      if isempty(npol) == 1
         npol = defnpol;
      end
      if isempty(weight) == 1
         weight = guidefweight;
      else wsize = size(weight);
         if wsize ~= [1, 3]
           weight = guidefweight;
         end
      end
      
    case 5
      % sfrmat4(io, deltaX, npol, weight, barImage)

      if isempty(io) == 1
         io = 0;
      end
       if isempty(deltaX) == 1
         deltaX = 1;
      end
      if isempty(npol) == 1
         npol = defnpol;
      end

       barImage = double(barImage);
      
      if isempty(deltaX) == 1
         deltaX = 1;
      end
      if isempty(weight) == 1
           weight = guidefweight;
        else wsize = size(weight);
           if wsize ~= [1, 3]
             weight = guidefweight;
           end
       end
        
    otherwise
     disp('Incorrect number or arguments. There should be 1 - 6');
     status = 1;
     return

end

if exist('npol','var') ~=1
    norder = input(['Edge fit order? [',num2str(defnpol),']']);
    if isempty(norder)==1
        npol = defnpol;
    else npol = norder;
    end
end
if npol>5
    disp('* Edge fit order must be 5 or less *')
    npol = defnpol;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suppresses interpreting of e.g. filenames
%  set(0, 'DefaultTextInterpreter', 'none'); 
 
%  pflag = 0; %Used for diagnostic plotting

if io ~= 1
    swin = splash(name, version, when);
    % Select file name for reading
    % edit the next line to change the default path for input file selection
    def ='*.*';
    drawnow;
    [status, atemp, ~, pathname, f] = imageread;
    close(swin); drawnow;
    if status~=0
        disp('No file selected. To try again type: > sfrmat4');
        status = 1;
        return;
    end
    filename = [pathname,f];

    [nlin npix ncol] = size(atemp);

    % input sampling and luminance weights
    if ncol==1
        [deltaX, npol] = inbox2(deltaX, npol);
    else 
        [deltaX, weight, npol] = inbox4(deltaX, guidefweight, npol); 
    end
     if npol>3
       disp(['Warning: Polynominal fit to edge is of order ',num2str(npol)]);
    end
    % used for plotting and listing
    if deltaX==1
        sunit = 'pixel';
        funit =  'cy/pixel';
    else
        sunit = 'mm';
        funit = 'cy/mm';
    end
    sinfo.sunit = sunit;
    sinfo.funit = funit;
    
    cname = class(atemp);
    if cname(1:5) == 'uint1'   % uint16
        smax = 2^16-1;
    elseif cname(1:5) == 'uint8'
        smax = 255;
    else
        smax = 1e10;
    end

    [barImage, roi] = getroi(atemp);
    barImage = double(barImage);

    % extract Region of interest
    clear atemp                             % *******************************
    [nlow, nhigh, cstatus] = clipping(barImage, 0, smax, 0.005);
    if cstatus ~=1 
     disp('Fraction low data');
     disp(nlow);
     disp('Fraction high data');
     disp(nhigh);
    end

%     if oecfdatflag == 1
%      disp('Applying OECF look-up table');
%      [a, oestatus] = getoecf(a, oepath, oename);   % Transforms a using OECF LUT from file chosen
%     end

else                     % when io = 1

    barImage= double(barImage);
%     if oecfdatflag ~= 0
%       size(oecfdat)
%       [a, oestatus] = getoecf(a, oecfdat);
%      disp('oecfdat applied')
%     end
    
    samp = zeros(1,3);
    samp(1) = nbin;
    samp(2) = deltaX; % Image sampling
    if deltaX > 1
       deltaX = 25.4/deltaX;  % Assume input was in DPI convert to pitch in mm
    end

end

[nlin npix ncol] = size(barImage);

% Form luminance record using the weight vector for red, green and blue
if ncol ==3
    lum = zeros(nlin, npix);
    lum = weight(1)*barImage(:,:,1) + weight(2)*barImage(:,:,2) + weight(3)*barImage(:,:,3); 
    cc = zeros(nlin, npix*4);
    cc = [ barImage(:, :, 1), barImage(:, :, 2), barImage(:,:, 3), lum];
    cc = reshape(cc,nlin,npix,4);

    barImage = cc;
    clear cc;
    clear lum;
    ncol = 4; 
end

% Rotate horizontal edge so it is vertical
rflag = 0;
 [barImage, nlin, npix, rflag] = rotatev2(barImage);  %based on data values

loc = zeros(ncol, nlin);

lowhi = 0;
fil1 = [0.5 -0.5];
fil2 = [0.5 0 -0.5];
% We Need 'positive' edge
tleft  = sum(sum(barImage(:,      1:5,  1),2));
tright = sum(sum(barImage(:, npix-5:npix,1),2));
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

fitme = zeros(ncol, npol+1); %%%%%%%%%%%%%%%%%%%%%
slout = zeros(ncol, 1);

% Smoothing window for first part of edge location estimation - 
%  to be used on each line of ROI
 win1 = ahamming(npix, (npix+1)/2);    % Symmetric window

for color=1:ncol                      % Loop for each color
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    if pflag ==1
        pname = ' ';
        if ncol~=1
            pname =[' Red '
           'Green'
           'Blue '
           ' Lum '];
        end
        figure(1);
        ht = 400;
        rat = npix/nlin;
        if rat<=0.3
            rat = 0.3;
        end
        wid = round(ht*rat);
        pos = [25 0 0 0];
        pos(3) = wid;
        pos(4) = ht;
        set(gcf,'Position', pos);
        imagesc1(barImage(:,:, color));
        colormap('gray');
        title(pname(color,:));
    end % if pflag == 1

    if pflag ==1
        figure;
        mesh( barImage(:,:,color) ), colormap('default'), title(pname(color,:));
        xlabel('pixel'), ylabel('line'), zlabel('value'); % Pause to inspect data
        disp('********* Hit any key to continue***************');
        
    end  % if pflag == 1
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    c = deriv1(barImage(:,:,color), nlin, npix, fil1);
    size(barImage);
    
% compute centroid for derivative array for each line in ROI. NOTE WINDOW array 'win1'
    for n=1:nlin
        loc(color, n) = centroid( c(n, 1:npix )'.*win1) - 0.5;   % -0.5 shift for FIR phase
    end
    
    fitme(color,:) = findedge2(loc(color,:), nlin, npol); %%%%%%%%%%%%%%%%
    
    place = zeros(nlin,1);
    for n=1:nlin 
        place(n) = polyval(fitme(color,:), n-1);  %%%%%%%%%%%%%%%%%%%%%%%
        win2 = ahamming(npix, place(n));
        loc(color, n) = centroid( c(n, 1:npix )'.*win2) -0.5;
    end
   
    [fitme(color,:)] = findedge2(loc(color,:), nlin, npol);
% For comparison with linear edge fit
    [fitme1(color,:)] = findedge2(loc(color,:), nlin, 1);

%
    if npol>3
        x = 0: 1: nlin-1;
        y = polyval(fitme(color,:), x);%%
        y1 = polyval(fitme1(color,:),x);%%   
        [r2, rmse, merror] = rsquare(y,loc(color,:));
        disp(['mean error: ',num2str(merror)]);
        disp(['r2: ',num2str(r2),' rmse: ',num2str(rmse)]);
    end 
 
    if pflag ==1
        
        x = 0: 1: nlin-1;
        y = polyval(fitme(color,:), x);
        y1 = polyval(fitme1(color,:),x);  
        
        figure;
        image(barImage(:,:, color)), colormap('gray(256)');
        axis image
        hold on
        np = 8;
         ln = 1:length(loc(color,:));
        plot(loc(color,1:np:end),ln(1:np:end), 'ro','MarkerSize',7), hold on,
        plot(y1,x, 'b--','LineWidth',1);
        plot(y,x, 'r','LineWidth',1);
        title(pname(color,:)), xlabel('edge location'),ylabel('line');
        hold off;
        disp('Edge  location, pixel');
        tdat = zeros(nlin,2);
        tdat(:,1) = (1:nlin)';
        tdat(:,2) = (loc(color, :))';
       
        x = 0: 1: nlin-1;
        y = polyval(fitme(color,:), x);%%
        y1 = polyval(fitme1(color,:),x);%%   
        [r2, rmse, merror] = rsquare(y,loc(color,:));
        disp(['mean error: ',num2str(merror)]);
        disp(['r2: ',num2str(r2),' rmse: ',num2str(rmse)])
        diff = loc(color,:)-y; 
        
        figure
        plot(diff,x,'*');
        xlabel('Residual, pixel'),ylabel('line');
        hold on
        plot([0,0],[0,nlin],'k--')
        axis ij
        axis([-10 10 0 nlin])
        figure
        histogram(diff,15,'Normalization','probability');
         xlabel('Residual, pixel'),ylabel('Frequency, prob.');
        
%         axis([-1 1 0 nlin])
                    
    end   

end                                         % End of loop for each color
clear c
summary{1} = ' '; % initialize

midloc = zeros(ncol,1);
summary{1} = 'Edge location, slope'; % initialize
sinfo.edgelab = 'Edge location, slope';
for i=1:ncol
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    slout(i) = - 1./(fitme(i,end-1)); %%%%%% slope is as normally defined in image coods.
    if rflag==1                       % positive flag if ROI was rotated
        slout(i) =  - fitme(i,end-1); %%%%%%%
    end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % evaluate equation(s) at the middle line as edge location
    midloc(i) = polyval(fitme(i,:), (nlin-1)/2); %%%%%%%%%
    summary{i+1} = [midloc(i), slout(i)];
    sinfo.edgedat = [midloc(i), slout(i)];
end


if ncol>2
    summary{1} = 'Edge location, slope, misregistration (second record, G, is reference)';
    sinfo.edgelab = 'Edge location, slope, misregistration (second record, G, is reference)';
    misreg = zeros(ncol,1);
    temp11 = zeros(ncol,3);
    for i=1:ncol
        misreg(i) = midloc(i) - midloc(2);
        temp11(i,:) = [midloc(i), slout(i), misreg(i)];
        summary{i+1}=[midloc(i), slout(i), misreg(i)];      
       % fitme(i,end) =  misreg(i);
    end
    sinfo.edgedat = temp11;
    clear temp11
    if io == 5 
        disp('Misregistration, with green as reference (R, G, B, Lum) = ');
        for i = 1:ncol
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
    nlin1 = round(floor(nlin*abs(fitme(1,end-1)))/abs(fitme(1,end-1))); %%%
    barImage = barImage(1:nlin1, :, 1:ncol);           
    
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

delimage = deltaX;

%Correct sampling inverval for sampling normal to edge
delfac = cos(atan(vslope));
% delfac = 1; (future use)
deltaX = deltaX*delfac;  % input pixel sampling normal to the edge   
del2 = deltaX/nbin;   % Supersampling interval normal to edge

samp(3) = del2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ns = length(summary);
summary{ns+1} = [delimage, del2];
sinfo.samp = [delimage deltaX del2 nbin];

nn =   floor(npix *nbin);
mtf =  zeros(nn, ncol);
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
esf = zeros(nn,ncol);  

for color=1:ncol
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
dat = zeros(nn2out, ncol+1);
for i=1:nn2out
    dat(i,:) = [freq(i), mtf(i,:)];
end

% Add color misregistration to fitme matrix
temp1 = zeros(ncol, npol+2);
temp1(1:ncol,1:npol+1) = fitme;
if ncol>2
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
if ncol >1
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
	if ncol>1
		for n = 2:ncol-1
			plot( freq( 1:nn2out), mtf(1:nn2out, n), sym{n});
        end
		ndel = round(nn2out/30);
		plot(  freq( 1:ndel:nn2out), mtf(1:ndel:nn2out, ncol), 'ok',...
            freq( 1:nn2out), mtf(1:nn2out, ncol), 'k')
		
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
 
end

%}