%% Linear models for reflectance functions
%
% Compute linear models (basis functions) for the reflectance data in
% ISETCam/data/surfaces.  We will reorganize the data directory and add
% some more types of reflectances in the next few days.
%
% Wandell, March 24, 2020
%
% See also
%  ieReadSpectra
%

%%  Change into the reflectances directory

% List the reflectance files
chdir(fullfile(isetRootPath,'data','surfaces','reflectances'))
rFiles = dir('*.mat');

rFilenames = cell(numel(rFiles),1);
for ii=1:numel(rFiles)
    rFilenames{ii} = rFiles(ii).name;
end

disp(rFilenames);

%% Load in.  Try NC's new plotting method

wave = 400:10:700;
rr  = 3;

[reflectances,wave] = ieReadSpectra(rFilenames{rr},wave);
ieNewGraphWin;
plot(wave,reflectances); grid on;
xlabel('Wave (nm)'); ylabel('Reflectance');
thisFile = strsplit(rFilenames{rr},'_');
title(thisFile{1});

%% Measure the approximation with reduced dimensionality

dim = 3;

[Basis,S,V] = svd(reflectances);
% Reduce the dimensionality
Basis = Basis(:,1:dim);
for ii=(dim+1):(min(size(S)))
    S(ii,ii) = 0;
end
weights = S*V';
weights = weights(1:dim,:);

approx = Basis*weights;
plot(wave,approx,'--',wave,reflectances,':'); grid on;
xlabel('Wave (nm)'); ylabel('Reflectance');
title(thisFile{1});

%%  

ieNewGraphWin;
plot(approx(:),reflectances(:),'.');
identityLine;
grid on;
xlabel('Approx'); ylabel('Measured');

rmse = sqrt(mean((approx(:) - reflectances(:)).^2));
t = text(0.1,0.8,sprintf('DIM = %d\nRMSE = %.3f',dim, rmse),'FontSize',18);

%%  Show the basis functions

ieNewGraphWin;
plot(wave,Basis,'linewidth',1); grid on;
xlabel('Wave (nm)');
ylabel('Reflectance');
legend({'1','2','3'},'Location','best');

%%

%%