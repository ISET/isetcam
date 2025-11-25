% In MATLAB, this function comes from the CV Toolbox. 
% Here, we replicate its functionality using a custom implementation. 

function imgOut = insertShape(img, shapeType, shapeParams, varargin)
    if ndims(img) == 2
        img = repmat(img, [1, 1, 3]);  % promote grayscale to RGB
    end

    p = inputParser;
    addParameter(p, 'Color', 'black');
    addParameter(p, 'Opacity', 1.0);
    addParameter(p, 'LineWidth', 1);
    parse(p, varargin{:});

    color = parseColor(p.Results.Color);
    opacity = p.Results.Opacity;
    lineWidth = p.Results.LineWidth;

    imgOut = im2double(img);  % Work in double precision [0,1]

    % Normalize shape name
    shape = lower(strrep(strrep(shapeType, '-', ''), '_', ''));

    [imgH, imgW, ~] = size(imgOut);

    switch shape
        case 'filledcircle'
            % shapeParams: [x, y, r]
            x = shapeParams(1);
            y = shapeParams(2);
            r = shapeParams(3);
            [xx, yy] = meshgrid(1:imgW, 1:imgH);
            mask = (xx - x).^2 + (yy - y).^2 <= r^2;
            imgOut = blendMask(imgOut, mask, color, opacity);

        case 'filledrectangle'
            % shapeParams: [x, y, w, h]
            x = shapeParams(1);
            y = shapeParams(2);
            w = shapeParams(3);
            h = shapeParams(4);
            mask = false(imgH, imgW);
            x1 = max(1, round(x));
            y1 = max(1, round(y));
            x2 = min(imgW, round(x + w - 1));
            y2 = min(imgH, round(y + h - 1));
            mask(y1:y2, x1:x2) = true;
            imgOut = blendMask(imgOut, mask, color, opacity);

        case 'line'
            % shapeParams: [x1, y1, x2, y2]
            x1 = shapeParams(1);
            y1 = shapeParams(2);
            x2 = shapeParams(3);
            y2 = shapeParams(4);
            imgOut = drawLine(imgOut, x1, y1, x2, y2, lineWidth, color, opacity);

        otherwise
            error('Unsupported shape: %s', shapeType);
    end

    imgOut = im2uint8(imgOut);
end

function color = parseColor(c)
    if ischar(c) || isstring(c)
        switch lower(c)
            case 'black', color = [0, 0, 0];
            case 'white', color = [1, 1, 1];
            case 'red',   color = [1, 0, 0];
            case 'green', color = [0, 1, 0];
            case 'blue',  color = [0, 0, 1];
            otherwise, error('Unsupported color name');
        end
    elseif isnumeric(c) && numel(c) == 3
        color = double(c(:))';
        if max(color) > 1, color = color / 255; end
    else
        error('Invalid color input');
    end
end

function img = blendMask(img, mask, color, opacity)
    for c = 1:3
        imgChannel = img(:,:,c);
        imgChannel(mask) = (1 - opacity) * imgChannel(mask) + opacity * color(c);
        img(:,:,c) = imgChannel;
    end
end

function img = drawLine(img, x1, y1, x2, y2, width, color, opacity)
    imgTmp = insertLinePrimitive(img, [x1, y1, x2, y2], width, color);
    mask = any(imgTmp ~= img, 3);
    img = blendMask(img, mask, color, opacity);
end

function imgOut = insertLinePrimitive(img, lineParams, width, color)
    % Uses built-in line plotting in a blank canvas
    imgOut = img;
    h = figure('Visible','off'); 
    imshow(zeros(size(img)), []);
    hold on;
    line(lineParams([1,3]), lineParams([2,4]), 'Color', color, 'LineWidth', width);
    F = getframe(gca);
    close(h);
    maskRGB = im2double(frame2im(F));
    maskRGB = imresize(maskRGB, [size(img,1), size(img,2)]);
    mask = any(maskRGB > 0.01, 3);  % binary mask
    imgOut = blendMask(imgOut, mask, color, 1);  % solid blend
end
