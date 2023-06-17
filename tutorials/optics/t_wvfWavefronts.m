%% Plot the wavefront aberrations of Zernike polynomial coefficients
%
% https://en.wikipedia.org/wiki/Zernike_polynomials
%
% We compare the computed wavefronts in wvf with the Zernike functions they
% are based on (zernfun), which are downloaded from the web.
%
% They are, of course, the same.  Except! there is a flipud somewhere.
%
% TO CHECK:  The amplitude is double for the wvf calculations compared to
% the straight zernfun.  I am not sure about the 
%
% See also
%  wvf2oi, wvfCreate, wvfCompute
%

%%
ieInit;

%% Create wavefront object and convert it to an optical image object

ieNewGraphWin([],'upper left big');
for ii=1:16
    subplot(4,4,ii);
    wvf = wvfCreate;
    wvf = wvfSet(wvf,'measured pupil size',10);   % This is diameter
    wvf = wvfSet(wvf,'calc pupil size',10);       % This is diameter
    wvf = wvfSet(wvf,'zcoeff',1,ii);
    wvf = wvfComputePSF(wvf);
    [n,m] = wvfOSAIndexToZernikeNM(ii);
    wvfPlot(wvf,'image wavefront aberrations','mm',550,5,'no window');
    colormap("gray"); title(sprintf('ZC_{%d}^{%d}',n,m));
end

%% Our values are flipped updown compared to these

ieNewGraphWin([],'upper left big');

% Over the unit disk.
x = -1:0.01:1;
[X,Y] = meshgrid(x,x);
[theta,r] = cart2pol(X,Y);
idx = r<=1;

% Makes the outside region 0 (gray)
z = zeros(size(X));

for ii=1:16
    subplot(4,4,ii);
    [n,m] = wvfOSAIndexToZernikeNM(ii);
    z(idx) = zernfun(n,m,r(idx),theta(idx)); 
    imagesc(flipud(z)); axis square;
    colormap('gray'); colorbar;
    title(sprintf('ZC_{%d}^{%d}',n,m));
end

%%
