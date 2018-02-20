% Script to write out and plot the luminosity function and the Judd 1951
% luminosity function 

% Write Luminosity (V-lambda)
[XYZ,wave] = ieReadSpectra('XYZ');
oname = fullfile(isetRootPath,'data','human','luminosity.mat');
ieSaveSpectralFile(wave,XYZ(:,2),'Luminosity (Vlambda) in energy format',oname);

% Plot the data to check.
vLambda = ieReadSpectra('luminosity',wave);
vcNewGraphWin;
plot(wave,vLambda);

% Now save the vLambda data in the luminosityQuanta.mat file.
% In this case, the calculation will be correct when the input is quanta,
% not energy.
q2e = Quanta2Energy(wave,ones(length(wave),1));

% By multiplying with quanta2Energy, when the data come in as quanta they
% are converted to energy.
dataQuanta = q2e(:).* vLambda(:);
oname = fullfile(isetRootPath,'data','human','luminosityQuanta.mat');
ieSaveSpectralFile(wave,dataQuanta,'Luminosity in a quantal input format',oname);

% Show the effect of wavelength ... not important.  Just a check.
vcNewGraphWin; plot(wave,dataQuanta./vLambda); grid on


%% Now the Judd luminosity function in Energy units
juddL = [  370,    0.0001
  380,    0.0004
  390,    0.0015
  400,    0.0045
  410,    0.0093
  420,    0.0175
  430,    0.0273
  440,    0.0379
  450,    0.0468
  460,    0.0600
  470,    0.0910
  480,    0.1390
  490,    0.2080
  500,    0.3230
  510,    0.5030
  520,    0.7100
  530,    0.8620
  540,    0.9540
  550,    0.9950
  560,    0.9950
  570,    0.9520
  580,    0.8700
  590,    0.7570
  600,    0.6310
  610,    0.5030
  620,    0.3810
  630,    0.2650
  640,    0.1750
  650,    0.1070
  660,    0.0610
  670,    0.0320
  680,    0.0170
  690,    0.0082
  700,    0.0041
  710,    0.0021
  720,    0.0011
  730,    0.0005
  740,    0.0002
  750,    0.0001
  760,    0.0001
  770,    0.0000];

%% Get ready to store them in a file
wave = juddL(:,1);
data = juddL(:,2);
comment = 'Downloaded from the Stockman site, http://cvrl.ucl.ac.uk/.   This is linear Judd modified photopic luminosity, w.r.t. Energy input';

% Save the file, being careful to include the filterNames cell array
oname = fullfile(isetRootPath,'data','human','juddLuminosity.mat');
ieSaveSpectralFile(wave,data,'Judd luminosity in an energy input format',oname);

%% Convert to quantal format
q2e = Quanta2Energy(wave,ones(length(wave),1));
dataQuanta = q2e(:).* data(:);
oname = fullfile(isetRootPath,'data','human','luminosityJuddQuanta.mat');
ieSaveSpectralFile(wave,dataQuanta,'Judd luminosity in a quantal input format',oname);

vcNewGraphWin; plot(wave,dataQuanta./data); grid on

%% Scratch calculations to verify the accuracy of the curves
%
%  We compared the Judd modified luminosity with the CIE luminosity and
%  with the 2*L + M from the Smith-Pokorny fundamentals.  
%
%  The Smith-Pokorny are supposed to be (and are) aligned with the Judd
%  modified luminosity.  The CIE values differs from these in the blue by a
%  slight amount (though a lot in ratio).

wavelength = [400:5:700];
lumJudd = ieReadSpectra('luminosityJudd',wavelength);

smithPokornyCones = ieReadSpectra('smithPokornyCones',wavelength);
tmp = smithPokornyCones*[1,.5,0]';
tmp = tmp/max(tmp(:));

lum = ieReadSpectra('luminosity',wavelength);
lum = lum/max(lum(:));

plot(wavelength,tmp,'--',wavelength,lum,'ro',wavelength,lumJudd,'g.');
semilogy(wavelength,tmp,'--',wavelength,lum,'ro',wavelength,lumJudd,'g.');

%  Here is a comparison of the SmithPokorny and the Stockman Fundamentals
%
plot(wavelength,smithPokornyCones,'o',wavelength,stockman,'--')

stockman = ieReadSpectra('stockman.mat',wavelength);
tmp = stockman*[1,.5,0]';
tmp = tmp/max(tmp(:));

w1 = pinv(stockman)*lumJudd;
w1/max(w1(:))

w2 = pinv(smithPokornyCones)*lumJudd;

w2/max(w2(:))
spApproxJudd = smithPokornyCones*w2;

spApproxJudd2 = smithPokornyCones*[1,.5,0]';
spApproxJudd2 = spApproxJudd2/max(spApproxJudd2(:));

plot(wavelength,spApproxJudd,'b--',wavelength,spApproxJudd2,'g--',wavelength,lumJudd,'ro')
