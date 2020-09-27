function hdl = LFMicrolensGeometry(pixelSize,mLensSize)
% Make a  picture showing the microlenses and pixel samples
%
% Synopsis
%   hdl = LFMicrolensGeometry(pixelSize,mLensSize)
%
% Inputs
%   pixelSize:  Size of the image pixel (meters)
%   mLensSize:  Diameter of the microlens (meters)
%
% Output
%   hdl:  FIgure handle
%
% See also
%   fcl_piLightfieldCamera.mlx
%

% Examples:
%{
  mLensSize = 12*1e-6;  % 12 microns
  pixelSize = mLensSize/5;
  hdl = LFMicrolensGeometry(pixelSize,mLensSize)
%}


%%
hdl = ieNewGraphWin;

%% We show 5 x 5 array of microlens positions. These are the Positions of
% the microlens centers. 
M = (-2:2)*mLensSize;
[X,Y] = meshgrid(M,M);
mLensPos = [X(:),Y(:)];

%% Pixel positions
P = min(X(:)):pixelSize:max(X(:));
[U,V] = meshgrid(P,P);

plot(U(:),V(:),'sr','Markersize',14);
hold on;

%%
for ii=1:size(mLensPos,1)
    drawcircle('Center',[X(ii),Y(ii)],'Radius',mLensSize/2);
end

axis image;
xlabel('Position (m)')
ylabel('Position (m)')

end
