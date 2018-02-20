%% s_humanConeAbsorptions 
%
% Calculate the cone absorptions rates per second to a range of blackbody
% radiators.
%
% The rough rule of thumb is 95,66,7 absorptions/sec per candela/m2 for the
% L, M and S cones.  This is governed by the scaling of the photopigment
% peaks, of course.
%
% A 100 cd/m2 5000 deg blackbody radiator causes about 10,000 absorptions
% in a second in the L cones.
%
% BW Vistasoft Team, 2014

%%
ieInit;

%%
lum       = 100;                           % cd/m2
noiseFlag = 0;

oi     = oiCreate('human');
sensor = sensorCreate('human');            %
sensor = sensorSet(sensor,'exp time',1);   % One second integration
sensor = sensorSet(sensor,'noise flag',noiseFlag);

%% Set variables
cTemp       = 3000:1000:7000;
absorptions = zeros(length(cTemp),3);

for ii=1:length(cTemp)
    scene = sceneCreate('uniform bb',128,cTemp(ii));
    scene = sceneAdjustLuminance(scene,lum);
    scene = sceneSet(scene,'fov',20);
    oi = oiCompute(oi,scene);
    sensor = sensorCompute(sensor,oi);
    
    roi    = sensorROI(sensor,'center');
    sensor = sensorSet(sensor,'roi',roi);
    elROI  = sensorGet(sensor,'roi electrons');
    for jj=2:4
        a = elROI(:,jj);
        absorptions(ii,jj-1) = mean(a(~isnan(a)));
    end
end

% ieAddObject(sensor); sensorWindow;

%%
vcNewGraphWin;
surf(cTemp,1:3,absorptions');
set(gca,'zscale','log')
xlabel('Color temperature');
ylabel('Cone type');
set(gca,'ytick',[1 2 3],'yticklabel',{'L','M','S'});
shading interp

title(sprintf('Scene luminance %i',lum))

%% Rough summary across cone
fprintf('Absorptions per candela/m^2  %.1f\n',mean(absorptions)/100)

%% END


