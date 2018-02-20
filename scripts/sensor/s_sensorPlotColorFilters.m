%% Plots the transmissivities of color filters 
%
% These are calibrated the data/sensor/colorfilters directory. 
%
% To create your own filters, have a look at the function
% sensorColorFilter. This creates Gaussian color filters with a
% specification of wavelength, wavelength center and bandwidth.
%
%   cfType = 'gaussian'; wave = [350:850];
%   cPos = 450:50:750; width = ones(size(cPos))*25;
%   fData = sensorColorFilter(cfType,wave, cPos, width);
%   plot(wave,fData)
%
% See also:  ieReadColorFilter, sensorColorFilter
%
% Copyright ImagEval Consultants, LLC, 2010


%%
ieInit

%% Example calibrated camera color filters 
cList = {'NikonD1','NikonD70','NikonD100','NikonD200IR','interleavedRGBW'};
wavelength = 400:1000;  % Out through IR in some cases

%% Plot the filters for each camera
for ii=1:length(cList)
    data = ieReadColorFilter(wavelength,cList{ii});
    vcNewGraphWin;
    plot(wavelength,data); 
    xlabel('Wavelength (nm)'); ylabel('Transmissivity');
    title(cList{ii});
    drawnow; pause(1);
end

%%