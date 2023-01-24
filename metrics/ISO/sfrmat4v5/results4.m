function status = results4(dat, datfile, roi, oename, sinfo, filename)
% results: Matlab function saves results computed by sfrmat4.m.
%  Data stored is in an Excel format file.
%
%  Usage: status =  results(dat, datfile, roi, memo, filename)
%  dat =      spatial frequency, (srf array) in either a 2 column or
%             4 column (frq, r, g, b) form
%  datfile =  image file used for input data
%  roi =      pixel coordinates that define the Region of Interest in
%             datfile
%  oename =    name of OECF file applied (or 'none'). 
%  sinfo =     structure with various fields for sfrmat4 results
%  filename = optional name of file where results are to be saved. If
%             this is not supplied, the user is prompted by a dialog
%             window.  
% 19 July 2019
%
% Copyright (c) Peter D. Burns 2019
% 
pfilename = filename;


if nargin<5
   filename = '';
end
if nargin<4
   memo = ' ';
end
if nargin<3
   disp('* Error in results function, at least 3 arguments needed *');
   return;
end

pdatfile = datfile;

disp(['* Writing results to file: ',filename])

 [rows, cols] = size(dat);
 

edgelab = sinfo.edgelab;
edgedat = sinfo.edgedat;
misreg = edgedat(:,end)';
samp = sinfo.samp;
nbin = samp(4);
fitme = sinfo.fitme;
se = sinfo.se;
sfr1050 = sinfo.sfr1050;
npol = sinfo.npol;
sunit = sinfo.sunit;
funit = sinfo.funit;

% Slope in degrees
dslope = 180*atan(edgedat(:,2))/pi;

sfil = filename;

line1 = {'Output from Matlab function sfrmat4.m'};
line3 = {'Analysis:  Spatial Frequency Response'};
line4 = {datestr(now,1)};
line5 = {'Image/data evaluated', pdatfile};
line6 = {'This output file', pfilename};
line7 = {'Selected region' ,['(', num2str(roi(1)), ', ',num2str(roi(2)),...
                     '), to (',num2str(roi(3)),', ',num2str(roi(4)),')']};
line8 = {'OECF applied', oename};
% line8a = {'Sampling intervals', num2str(tt1(1),3),num2str(tt1(2),3)};
% line8a = {'Sampling, Image', num2str(samp(2),3)};

if strcmp(sunit, 'mm')
    line8a = {['Sampling (Image), ',sunit], num2str(samp(1),3),'PPI',num2str(round(25.4/samp(1)),3) };
else    
    line8a = {['Sampling (Image), ',sunit], num2str(samp(1),3)};
end
line8b = {'Edge fit order', num2str(npol,2)};
line8c = {'Binning', num2str(nbin, 2)};
line8d = {['ESF Sampling, ',sunit], num2str(samp(3),3)};
if cols>2
    line8e = {'  ','Red', 'Green','Blue', 'Lum'};
    line8f = {'Slope, degrees',num2str(dslope(1),3),num2str(dslope(2),3),...
               num2str(dslope(3),3),num2str(dslope(4),3)};
    line9  = {'Color Misreg, pixels',num2str(misreg(1),2),...
               num2str(misreg(2),2),num2str(misreg(3),2),num2str(misreg(4),2)};
    line10 = {'Sampling Efficiency',num2str(se(1,1),3),...
               num2str(se(1,2),3),num2str(se(1,3),3),num2str(se(1,4),3)};        
    line11 = {['SFR50, ',funit],num2str(sfr1050(2,1),3),...
               num2str(sfr1050(2,2),3),num2str(sfr1050(2,3),3),num2str(sfr1050(2,4),3)};
  
   line12 = {['SFR10, ',funit],num2str(sfr1050(1,1),3),...
               num2str(sfr1050(1,2),3),num2str(sfr1050(1,3),3),num2str(sfr1050(1,4),3)};
else
    line8e = ' ';
    line8f = {'Slope, degrees',num2str(dslope(1),3)};
    line9 = ' ';
    line10 = {'Sampling Efficiency',num2str(se(1),3)};
    line11 = {['SFR50, ',funit],num2str(sfr1050(2),3)};
    line12 = {['SFR10, ',funit],num2str(sfr1050(1),3)};
end
if cols<4
    line13 = {['Frequency, ',funit],  'SFR'};
else
    line13 = {['Frequency, ',funit],'SFR-r','SFR-g','SFR-b','Lum'};
end

if exist(sfil,'file')==2
    disp(['Deleting: ', sfil])
    delete(sfil);
end

xlswrite(sfil, line1,1,'B1');
% xlswrite(sfil, line2,1,'B2');
xlswrite(sfil, line3,1,'B2');
xlswrite(sfil, line4,1,'B4');
xlswrite(sfil, line5,1,'B5');
xlswrite(sfil, line6,1,'B6');
xlswrite(sfil, line7,1,'B7');
xlswrite(sfil, line8,1,'B8');
xlswrite(sfil, line8a,1,'B9');
xlswrite(sfil, line8b,1,'B10');
xlswrite(sfil, line8c,1,'B11');
xlswrite(sfil, line8d,1,'B12');
xlswrite(sfil, line8e,1,'B13');
xlswrite(sfil, line8f,1,'B14');
xlswrite(sfil, line9,1,'B15');
xlswrite(sfil, line10,1,'B16');
xlswrite(sfil, line11,1,'B17');
xlswrite(sfil, line12,1,'B18');
xlswrite(sfil, line13,1,'B20');
xlswrite(sfil, round(dat,3),1,'B21');
pause(3);
