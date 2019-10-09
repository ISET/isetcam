function fluorophoreSave( fName, fl, comment )
% Save fluorophore structure into a Matlab .mat file. 
%
% Syntax
%   fluorophoreSave(fName, flStruct, comment)
%
% Description
%  Saves the terms in the fluorophore structure is defined by the
%  fluorophoreCreate function. The input structure must contain the
%  following fields
%
%    .name
%    .solvent
%    .excitation
%    .emission
%    .comment
%    .wave
%
% The units of the fluorophore  emission and excitation spectra are not
% specified at this time. They should be treated as simply having unit
% amplitude (for comparison convenience).  If we had real units, we would
% use them.  But the value depends so much on the context (e.g.,
% concentration, medium) that we do not have a good solution (pun
% intended).
%
% Inputs:
%   fName   - full path to file where the fluorophore is to be saved.
%   fl      - the fluorophore structure
%   comment - a comment string
%
% Outputs
%
% Copyright, Henryk Blasinski 2016
%
% See also
%   fluorophoreCreate, fluorophoreSet, fluorophoreGet, fluorophorePlot
%

%%
p = inputParser;
p.addRequired('fName',@ischar);
p.addRequired('fl',@isstruct);
p.addRequired('comment',@ischar);

p.parse(fName,fl,comment);
inputs = p.Results;

%% We assume that the fluorophore already contains all the necessary fields.

name       = fluorophoreGet(fl,'name');
solvent    = fluorophoreGet(fl,'solvent');
excitation = fluorophoreGet(fl,'excitation');
emission   = fluorophoreGet(fl,'emission');
wave       = fluorophoreGet(fl,'wave');
comment    = inputs.comment;

% Force normalization
excitation = excitation/max(excitation(:));
emission   = emission/max(emission(:));

% name       = inputs.fl.name;
% solvent    = inputs.fl.solvent;
% excitation = inputs.fl.excitation/max(inputs.fl.excitation);
% emission   = inputs.fl.emission/max(inputs.fl.emission);
% wave       = inputs.fl.spectrum.wave;

save(fName,'name','solvent','excitation','emission','comment','wave');

end

