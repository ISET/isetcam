function imgN = imageDistort(img, dMethod, varargin)
% Gateway method for ways to distort image data
%
%   imgN = imageDistort(img,dMethod)
%
% img:  A row x col x w image matrix
% dMethod:  Specified method

if ieNotDefined('dMethod'), dMethod = 'Gaussian Noise'; end

dMethod = ieParamFormat(dMethod);
switch dMethod
    case 'gaussiannoise'
        % imageDistort(img,'gaussian noise',30);
        if ~isempty(varargin), nScale = varargin{1};
        else
            nScale = 0.05 * max(img(:)); % Noise is five percent of max
        end
        noise = nScale * randn(size(img)); % vcNewGraphWin; histogram(n(:))

        if isinteger(img) && max(img(:)) < 256
            % Case of an 8 bit image
            imgN = double(img) + noise;
            imgN = ieClip(imgN, 0, 255);
            imgN = uint8(imgN);
        else
            % Image is already a double.  Onward.
            imgN = img + noise;
        end

    case 'jpegcompress'
        % imageDistort(img,'jpeg compress',30);
        % Find a proper Matlab function for this
        if ~isempty(varargin), q = varargin{1};
        else q = 75;
        end
        imwrite(img, 'deleteMe.jpg', 'jpeg', 'Quality', q);
        imgN = imread('deleteMe.jpg');
        delete('deleteMe.jpg');
    case 'scalecontrast'
        % imageDistort(img,'scale contrast',0.1);
        % Generally the scalar for the distortion should be -.2 to .2
        if ~isempty(varargin), s = varargin{1};
        else s = 0.1;
        end
        imgN = img * (1 + s);

    otherwise
        error('Unknown method: %s\n', dMethod);
end

return