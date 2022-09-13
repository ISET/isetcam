%% Analyze minimal focal distance for various lenses
%
% After running this script, the closest represents the closest focal
% length and name{ii} is the name of the lens file.
%
% It appears that dgauss.22deg.3.0mm is the lens with the closest focal
% length, about 4.4 mm.
%
% BW SCIEN Stanford, 2017

%%
chdir(fullfile(piGetDir('lens')));
lensFiles = dir('*.mat');
nFiles = length(lensFiles);
closest = zeros(nFiles,1);
name = cell(nFiles,1);

for ii=1:length(lensFiles)
    name{ii} = lensFiles(ii).name;
    data = load(name{ii});
    idx = find(isnan(data.focalDistance), 1, 'last' ) + 1;
    if idx < length(data.dist)
        closest(ii) = data.dist(idx);
    else
        closest(ii) = NaN;
    end
end

%%
vcNewGraphWin; 
semilogy(closest)
xlabel('Lens'); ylabel('Closest focal distance (mm)');
grid on

%%