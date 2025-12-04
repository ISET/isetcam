%% Peter's color router data


load('routerdata','OE','wavelength');

ieSaveSpectralFile(wavelength',OE','From a Peter file called routerdata.mat','singleLayerColorRouter.mat');
