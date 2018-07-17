function [ fl ] = fluorophoreRead( fName, varargin )
% Read fluorophore spectral properties from a Matlab (.mat) file fName.
%
% [ fl ] = fluorophoreRead( fName,...)
%
% Fluorophore file should have been saved using fluorophoreSave.
%
% Inputs:
%   fName - path to the data file
%
% Inputs (optional):
%   'wave' - a vector of waveband samples (default = 400:10:700).
%   'qe' - fluorophore quantum efficiency (default = 1).
%
% Output:
%   fl - the fiToolbox fluorophore structure
%
% Examples
%   fName  = fullfile(fiToolboxRootPath,'data','LifeTechnologies','phRodoRed.mat');
%   fl  = fluorophoreRead(fName);
%
% Copyright, Henryk Blasinski 2016

%%
p = inputParser;
p.addRequired('fName',@ischar);
p.addParameter('wave',(400:10:700)',@isvector);
p.addParameter('qe',1,@isscalar);

p.parse(fName,varargin{:});
inputs = p.Results;

%%
data = load(inputs.fName);

fl = fluorophoreCreate('type','custom',...
                       'wave',data.wave,...
                       'name',data.name,...
                       'solvent',data.solvent,...
                       'excitation',data.excitation,...
                       'emission',data.emission);
                   
fl = fluorophoreSet(fl,'qe',inputs.qe);
if ~isempty(inputs.wave)
    fl = fluorophoreSet(fl,'wave',inputs.wave);
end



end

