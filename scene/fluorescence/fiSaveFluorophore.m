function fiSaveFluorophore( fName, fl, comment )

% fiSaveFluorophore( fName, fl, ...)
%
% Save an fiFluorophore structure into a Matlab .mat file. The fluorophore
% structure has to contain the following fields
%    .name
%    .solvent
%    .excitation
%    .emission
%    .comment
%    .wave
% A fluorophore is saved with its emission and excitation spectra
% normalized to unit amplitude (for comparison convenience) and does not
% include the quantum efficiency parameter, which is a scaling factor
% depending on many physical parameters (for example concentration).
%
% Inputs:
%   fName - path to where the fluorophore is to be saved.
%   fl - the fiToolbox fluorophore structure.
%
% Inputs (optional):
%   'comment' - an optional commnet string.
%
% Copyright, Henryk Blasinski 2016

p = inputParser;
p.addRequired('fName',@ischar);
p.addRequired('fl',@isstruct);
p.addOptional('comment','',@ischar);

p.parse(fName,fl,comment);
inputs = p.Results;

% We assume that the fluorophore already contains all the necessary fields.
name = inputs.fl.name;
solvent = inputs.fl.solvent;
excitation = inputs.fl.excitation/max(inputs.fl.excitation);
emission = inputs.fl.emission/max(inputs.fl.emission);
comment = inputs.comment;
wave = inputs.fl.spectrum.wave;

save(fName,'name','solvent','excitation','emission','comment','wave');

end

