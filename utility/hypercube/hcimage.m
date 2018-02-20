function figH = hcimage(hc,varargin)
% Display a hypercube image.
%
% Options for display are
%   mean gray  -
%   image montage -
%   movie -
%
% Examples:
%
%   fname = fullfile(isetRootPath,'data','images','hyperspectral','surgicalSWIR.mat');
%   load(fname,'hc'); nWave = size(hc,3);
%   hcimage(hc,'image montage');
%   hcimage(hc,'movie');
%
% See also:
%    mplay, imageMontage
%
% (c) Imageval

if ieNotDefined('hc'), error('hypercube image data required'); end

if isempty(varargin), dType = 'mean gray';
else dType = varargin{1};
end

dType = ieParamFormat(dType);

switch dType
    case 'meangray'
        % Most boring default.  Find the mean level across wavelengths and display
        % it as a gray scale image
        vcNewGraphWin;
        img = mean(hc,3);
        imagesc(img); colormap(gray)
        axis image
    case {'imagemontage','montage'}
        nWave = size(hc,3);
        if length(varargin) > 1, slices = varargin{1}; 
        else slices = 1:nWave;
        end

        figH = imageMontage(hc,slices);
        colormap(gray)

    case 'movie'
        % Show the hypercube data as a movie
        hc = 256*double(hc/max(hc(:)));
        mp = mplay(hc); 
        mFig = mp.hfig;
        set(mFig,'name',sprintf('Hypercube wavebands: %d', size(hc,3)));
        
    otherwise
        error('Unknown hc image display type: %s',dType);
end


return