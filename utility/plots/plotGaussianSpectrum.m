function tran=plotGaussianSpectrum(wavelength,mu,sig)
% Deprecated
%
%
% Plots a transmittance curve
% Used primarily by the makeCustomCFApattern UI

% wavelength - range over which transmittance is defined
% mu - center of transmittance along the wavelength range
% sig - variance of transmittance curve

%sig=sqrt(sig);
tran=exp( -(1/(2*sig^2)) * (wavelength-mu).^2  );

plot(wavelength,tran,'k');
axis tight
hold on;

% Load LUT that maps spectral wavelengths to visible colors
load spectrumLUT
%                     bbI       1x1377            11016  double
%                     ggI       1x1377            11016  double
%                     rrI       1x1377            11016  double
%                     xxI       1x1377            11016  double
yyI=interp1(wavelength,tran,xxI); % xxI is resolution of LUT;  may be changed
irGrayLevel=0.3;

for kk=1:length(xxI) %% Fix gray-level in LUT after finalizing it
    if rrI(kk)==0 && ggI(kk)==0 && bbI(kk)==0
        rrI(kk)=irGrayLevel;
        ggI(kk)=irGrayLevel;
        bbI(kk)=irGrayLevel;
    end
    line(repmat(xxI(kk),2,1),[0,yyI(kk)],...
        'color',[rrI(kk) ggI(kk) bbI(kk)]);
end
set(gca,'Xtick',[],'Ytick',[]);


end