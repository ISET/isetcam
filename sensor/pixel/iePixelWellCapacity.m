function [electrons, wellCapacity] = iePixelWellCapacity(pixelSize)
% Return estimated well capacity (electrons) for a pixel size (microns)
%
% Syntax:
%     iePixelWellCapacity(pixelSize)
%
% Input
%   pixelSize:  Pixel size in microns
%
% Key-Value parameters
%   N/A
%
% Output
%   electrons:  Well capacity in electrons
%   wellCapacity:  columns of pixel size (microns) and FWC (electrons)
%
% Description:
%
%{
% This is the method we used to interpolate full well capacity (FWC) from
% pixel sizes based on data from our colleague (Boyd).

clear wellCapacity;
wellCapacity(:,1) = [0.7   0.8 1.0   1.1  2     3       4.2]';
wellCapacity(:,2) = [4000 5500 7500 10000 17500 25000   35000]';

psize = wellCapacity(:,1); electrons = wellCapacity(:,2);
ieNewGraphWin;
plot(psize,electrons,'ro-'); slope = psize\electrons;

% Second order polynomial does pretty well.
p = polyfit(psize,electrons,2);

% Interpolate to a fine resolution where further linear will be OK
simulatedSize = 0:.1:7;    % This is an extrapolation ...
    simulatedFWC  = polyval(p,simulatedSize);

ieNewGraphWin;
plot(psize,electrons,'ro',simulatedSize,simulatedFWC,'b-');
xlabel('Pixel size (um)'); ylabel('FWC (electrons)'); grid on

clear wellCapacity;
wellCapacity(:,1) = simulatedSize(:);
wellCapacity(:,2) = simulatedFWC(:);

% This is what we wrote out in the file we are reading in.
fname = fullfile(isetRootPath,'data','sensor','wellCapacity');
save(fname,'wellCapacity');

%}
%
%    NOTES:  From an older online reference.
%    http://www.clarkvision.com/articles/digital.sensor.performance.summary/
%
%    Boyd says those numbers are way off.
%
%    Other values are from the papers cited in
%    https://www.cse.wustl.edu/~jain/cse567-11/ftp/imgsens/index.html
%
%    And this from the web.  But we are waiting for Boyd.
%     (8 130,000)[Suntharalingam2009]
%     (5.6 160,000) [Akahane https://ieeexplore-ieee-org.stanford.idm.oclc.org/document/5263013]
%     (1.4, 4100) [Yong Lim]
%
%    The Clark data are approximately the values in the Canon pixel sizes.
%    Other vendors have different well capacity and pixel size
%    relationships.
%
% Wandell, 2019
%
% See also
%

% Examples:
%{
pSizeUM = 4.2;
fprintf('Well capacity %d\n',round(iePixelWellCapacity(pSizeUM)))
%}
%{
pSizeUM = 2;
[electrons, wellCapacity] = iePixelWellCapacity(pSizeUM);
%}
%{
%  The curve extrapolates to a negative well capacity, so we clip that
[~,wc] = iePixelWellCapacity([]);
l = (wc(:,2) > 0)
ieNewGraphWin; plot(wc(l,1),wc(l,2));
xlabel('Pixel size (um)'); ylabel('FWC (electrons)');
grid on;

%}

%%
p = inputParser;
p.addRequired('pixelSize', @(x)(isscalar(x) || isempty(x)));
p.parse(pixelSize);

electrons = [];

%%  Interpolate this lookup table, which is based on ...

fname = fullfile(isetRootPath, 'data', 'sensor', 'wellCapacity');

% Pixel size in microns vs. well capacity in electrons
% Snagged from the Roger Clark graph at the link above.
% May be updated with newer information from Boyd and others over time.
load(fname, 'wellCapacity');

if ~isempty(pixelSize)
    if (pixelSize < 0.5 || pixelSize > 8)
        warning('Pixel size (%.2f microns) out of typical range', pixelSize);
    end
    electrons = interp1(wellCapacity(:, 1), wellCapacity(:, 2), pixelSize, ...
        'linear', 'extrap');
end

% ieNewGraphWin;
% plot(wellCapacity(:,1),wellCapacity(:,2),'--',pixelSize,electrons,'o');

end