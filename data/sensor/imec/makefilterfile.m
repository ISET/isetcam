% Clear
wl=(460:620)';
FWHM=12

gamma = FWHM/2;
fabry = @(cwl) gamma^2./(gamma.^2 +(wl-cwl).^2);

cwl = linspace(wl(1),wl(end),16); % generate 9 filters


figure

F= fabry(cwl);

plot(wl,fabry(cwl));
xlim([wl(1) wl(end)])



%% Generate file
wavelength = wl;
data = F;
comment = 'multispectral filters'
filterNames= arrayfun(@num2str, 1:numel(cwl), 'UniformOutput', false);

for i=1:numel(cwl)
    filterNames{i}= ['k-' num2str(cwl(i))];
end



save('multispectral.mat','wavelength','data','comment','filterNames')


%%
