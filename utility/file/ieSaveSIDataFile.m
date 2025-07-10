function fName = ieSaveSIDataFile(psf,wave,umPerSamp,fName)
%Write file with data for shift-invariant optics
%
%  fName = ieSaveSIDataFile(psf,wave,umPerSamp,fName)
%
% The shift-invariant optics uses one point spread for every wavelength. We
% save the data used to create optics in this file.  We then create the
% optics structure from these data using siSynthetic.
%
% psf:       row x col x wavelength array containing the psfs
% wave:      list of wavelengths
% umPerSamp: spacing (in microns) between samples in the psf data
% fName:     output file name
%
% Examples:
%      psf = rand(128,128,31);wave = 400:10:700; umPerSamp = [0.25,0.25];
%      fName = ieSaveSIDataFile(psf,wave,umPerSamp)
%
%      oi = vcGetObject('OI');
%      optics = siSynthetic('custom',oi,fName);
%
% Copyright ImagEval Consultants, LLC, 2010

if ieNotDefined('psf'),  error('psf volume required'); end
if ieNotDefined('wave'), error('wavelength samples required (nm)'); end
if ieNotDefined('umPerSamp'), error('Microns per sample(2-vector) required'); end
if ieNotDefined('fName'), fName = vcSelectDataFile('stayPut','w'); end

notes.timeStamp = datetime('now');

save(fName,'psf','wave','umPerSamp','notes');

end
