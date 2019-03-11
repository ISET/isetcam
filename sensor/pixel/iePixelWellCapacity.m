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
%    From an online reference.
%    http://www.clarkvision.com/articles/digital.sensor.performance.summary/
%
%    Boyd Fowler says those numbers are way off.  He says for 0.7 to 1.1
%
%      wellCapacity(:,1) = [0.7 0.8 1.0 1.1 1.4 8]';
%      wellCapacity(:,2) = [4000 5500 7500 10000 4100 130000]';
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
  pSizeUM = 1;
  fprintf('Well capacity %d\n',round(iePixelWellCapacity(pSizeUM)))
%}
%{
   [~,wc] = iePixelWellCapacity([]);
   ieNewGraphWin; plot(wc(:,1),wc(:,2));
%}
%{
  pSizeUM = 1;
  [electrons, wellCapacity] = iePixelWellCapacity(pSizeUM);
%}
%{
clear wellCapacity
wellCapacity(:,1) = [0.7 0.8 1.0 1.1]';
wellCapacity(:,2) = [4000 5500 7500 10000]';
ieNewGraphWin; plot(wellCapacity(:,1),wellCapacity(:,2),'ro');
hold on; plot(wc(:,1),wc(:,2),'o');
xlabel('Pixel size (um)'); ylabel ('FWC (electrons)');
grid on
%}

%%
p = inputParser;
p.addRequired('pixelSize',@(x)(isscalar(x) || isempty(x)));
p.parse(pixelSize);

electrons = [];

%%  Interpolate this lookup table, which is based on ...

fname = fullfile(isetRootPath,'data','sensor','wellCapacity');

% Pixel size in microns vs. well capacity in electrons
% Snagged from the Roger Clark graph at the link above.  
% May be updated with newer information from Boyd and others over time.
load(fname,'wellCapacity');

if ~isempty(pixelSize)
    if (pixelSize < 1 || pixelSize > 8)
        warning('Pixel size (%.2f microns) out of typical range',pixelSize);
    end
    electrons = interp1(wellCapacity(:,1),wellCapacity(:,2),pixelSize,...
        'linear','extrap');
end

% ieNewGraphWin;
% plot(wellCapacity(:,1),wellCapacity(:,2),'--',pixelSize,electrons,'o');

end