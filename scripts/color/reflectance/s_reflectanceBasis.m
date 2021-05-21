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
for ii=1:numel(rFilenames)
    fprintf('%d  %s\n',ii,rFilenames{ii});
end

%% Load in.  Try NC's new plotting method

wave = 400:5:700;
rr  = [5,12];

reflectances = [];
for jj = rr
    tmp = ieReadSpectra(rFilenames{jj},wave);
    reflectances = cat(2,tmp,reflectances);
end

ieNewGraphWin;
plot(wave,reflectances); grid on;
xlabel('Wave (nm)'); ylabel('Reflectance');

%% Measure the approximation with reduced dimensionality

dim = 8;

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
% title(thisFile{1});

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
xaxisLine;   % Nice to see where 0 is.

xlabel('Wave (nm)');
ylabel('Reflectance');
legend({'1','2','3'},'Location','best');

%%  Save them out in a data file
fname = fullfile(isetRootPath,'data','surfaces','reflectances','reflectanceBasis.mat');
ieSaveSpectralFile(wave,Basis,'Surface reflectance basis functions from s_reflectanceBasis',fname);

%% END
