function outputImage = LFAutofocus(lightfield, rect, slopeRange, slopeStep, fastMode)
% Focus a region of the light field
%
% Syntax:
%  outputImage = LFAutofocus(lightfield, rect, slopeRange, slopeStep)
%
% focuses the image corresponding to the lightfield (same format as
% lightfield toolbox... n1, n2, x, y, channels, where n1, n2 are
% dimensions of pixel cells, and x, y are resolution of pinhole images.
%
% slopeRange is a 2 vector with min and max range for slope.  default
% is [-7 .5]
%
% slopeStep is the slope stem that we are sampling
%
% todo: use a binary search for faster autofocus.

if (ieNotDefined('rect'))
    % if rect is not defined, make a slope = 0 render and have user
    % select a rectangle.
    
    fig = vcNewGraphWin;
    Slope = 0;
    
    ShiftImg = LFFiltShiftSum(lightfield, Slope );
    imagescRGB(lrgb2srgb(ShiftImg(:,:,1:3)));
    rect = getrect(fig);
    disp('Select the rect where you want to focus.')
end

if(ieNotDefined('slopeRange'))
    %default slope range
    slopeRange = [-.7 .5];
end

if(ieNotDefined('slopeStep'))
    slopeStep = .05;
end

if(ieNotDefined('fastMode'))
    fastMode = false;
end
index = 1;
SlopeVec = slopeRange(1):slopeStep:slopeRange(2);
varianceVec = zeros(size(SlopeVec));
roundRect = round(rect);


if(fastMode) %binary search mode - does not work yet
    leftIndex = 1;
    rightIndex = length(varianceVec);
    midIndex= round((leftIndex + rightIndex)/2);
    continu = true;
    while(continu)
        leftSlope  = SlopeVec(leftIndex);
        rightSlope = SlopeVec(rightIndex);
        midSlope   = SlopeVec(midIndex);
        
        Slope = leftSlope;
        ShiftImg = LFFiltShiftSum(lightfield(:,:, roundRect(2):roundRect(2) + roundRect(4),roundRect(1): roundRect(1) + roundRect(3), :), Slope );
        imagescRGB(lrgb2srgb(ShiftImg(:,:,1:3)));
        tmpImg = ShiftImg(:,:,1:3);
        leftVar= sum(sum(var(tmpImg)));
        
        Slope = rightSlope;
        ShiftImg = LFFiltShiftSum(lightfield(:,:, roundRect(2):roundRect(2) + roundRect(4),roundRect(1): roundRect(1) + roundRect(3), :), Slope );
        imagescRGB(lrgb2srgb(ShiftImg(:,:,1:3)));
        tmpImg = ShiftImg(:,:,1:3);
        rightVar= sum(sum(var(tmpImg)));
        
        Slope = midSlope;
        ShiftImg = LFFiltShiftSum(lightfield(:,:, roundRect(2):roundRect(2) + roundRect(4),roundRect(1): roundRect(1) + roundRect(3), :), Slope );
        imagescRGB(lrgb2srgb(ShiftImg(:,:,1:3)));
        tmpImg = ShiftImg(:,:,1:3);
        midVar = sum(sum(var(tmpImg)));
        
        if (leftVar < rightVar && leftVar < midVar)
            
        elseif (rightVar < midVar && rightVar < leftVar)
            
        else
            
        end
    end
else
    % go through a bunch of slopes, and select the one with the largest
    % variance(contrast) in the region of  interest
    for Slope = SlopeVec  %1.5
        ShiftImg = LFFiltShiftSum(lightfield(:,:, roundRect(2):roundRect(2) + roundRect(4),...
            roundRect(1): roundRect(1) + roundRect(3), :), ...
            Slope );
        imagescRGB(lrgb2srgb(ShiftImg(:,:,1:3)));
        tmpImg = ShiftImg(:,:,1:3);
        
        varianceVec(index) = sum(sum(var(tmpImg)));
        index = index + 1;
    end
end

[~, maxInd] = max(varianceVec);

Slope = SlopeVec(maxInd);

% Show the image
ieNewGraphWin;
ShiftImg = LFFiltShiftSum(lightfield, Slope);
imagescRGB(lrgb2srgb(ShiftImg(:,:,1:3)));
axis image; truesize
title(sprintf('Parameter %0.2f',Slope))
outputImage = ShiftImg(:,:,1:3);

end