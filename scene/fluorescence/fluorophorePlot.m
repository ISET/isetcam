function fig = fluorophorePlot(fl,pType,varargin)
% Gateway routine for plotting fluorophore data
%
% Input
%   fl - Fluorophore structure
%   pType - plot type.  Options are
%
% Optional key/value pairs
%
% Returns
%
% Wandell, Vistasoft team 2018
%
% See also
%

% Examples:
%{
fl = fluorophoreRead('alamarBlue');
fluorophorePlot(fl,'excitation');
%}
%{
fl = fluorophoreRead('alamarBlue');
fluorophorePlot(fl,'emission');
%}
%{
fl = fluorophoreRead('alamarBlue');
fluorophorePlot(fl,'donaldsonmesh');
%}
%{
fl = fluorophoreRead('alamarBlue');
fluorophorePlot(fl,'donaldsonimage');
%}

%%
p = inputParser;

pType = ieParamFormat(pType);
varargin = ieParamFormat(varargin);

p.addRequired('fl',@isstruct);
p.addRequired('pType',@ischar)
p.parse(fl,pType,varargin{:});

fig = vcNewGraphWin;

%%
switch pType
    case {'donaldsonimage','donaldsonmatrix'}
        % Computed for photons (not energy)
        % Show an image with the Donaldson matrix (photons)
        % fluorophorePlot(fl,'donaldson image');
        
        wave = fluorophoreGet(fl,'wave');
        dMatrix = fluorophoreGet(fl,'donaldson matrix');
        imagesc(wave,wave,dMatrix);
        grid on; set(gca,'GridColor',[1 1 1])
        line([min(wave),max(wave)],[min(wave),max(wave)],'Color','w')
        xlabel('Excitation wave (nm)'); ylabel('Emission wave (nm)');
        colorbar; axis image
        title(sprintf('%s',fluorophoreGet(fl,'name')));
    case 'donaldsonmesh'
        % Computed for photons (not energy)
        % Plot a mesh with the Donaldson matrix (photons)
        % fluorophorePlot(fl,'donaldson mesh');
        
        wave = fluorophoreGet(fl,'wave');
        dMatrix = fluorophoreGet(fl,'donaldson matrix');
        mesh(wave,wave,dMatrix);
        line([min(wave),max(wave)],[min(wave),max(wave)],[0 0],'Color','k');
        grid on; xlabel('Excitation wave (nm)'); ylabel('Emission wave (nm)');
        colorbar; 
        title(sprintf('%s',fluorophoreGet(fl,'name')));
        
    case {'emission','emissionphotons'}
        % fluorophorePlot(fl,'emission photons');
        wave = fluorophoreGet(fl,'wave');
        data = fluorophoreGet(fl,'emission');
        plot(wave,data,'k-','linewidth',1); grid on;
        grid on; xlabel('Wavelength (nm)'); ylabel('Emission (photons, a.u.)');
        title(sprintf('%s',fluorophoreGet(fl,'name')));
    case {'excitation','excitationphotons'}
        % The excitation vector is like a color filter that expects the
        % input in the form of photons.
        % fluorophorePlot(fl,'excitation photons');
        wave = fluorophoreGet(fl,'wave');
        data = fluorophoreGet(fl,'excitation');
        plot(wave,data,'k-','linewidth',1); grid on;
        grid on; xlabel('Wavelength (nm)'); ylabel('Excitation (photons, a.u.)');
        title(sprintf('%s',fluorophoreGet(fl,'name')));
    case {'exemphotons','exem'}
        wave = fluorophoreGet(fl,'wave');
        ex = fluorophoreGet(fl,'excitation photons');
        em = fluorophoreGet(fl,'emission photons');
        plot(wave,ex,'b-','linewidth',1); hold on;
        plot(wave,em,'r-','linewidth',1); 
        grid on; xlabel('Wavelength (nm)'); ylabel('Photons (a.u.)');
        legend({'Excitation','Emission'})
        % We might end up producing an energy form of these plots, as well.
    otherwise
        error('Unknown plot type %s\n',pType);
end