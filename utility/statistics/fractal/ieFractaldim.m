function fd = ieFractaldim(imgfile, boxwidth_start, boxwidth_end, boxwidth_incr)
% Approximates fractal dimension using box counting method
%
% Synopsis
%  fd = getfractaldim(imageFile,boxwidth_start,boxwidth_end,boxwidth_incr)
%
% Input
%   imageFile
%   boxwidth ...  Start size in pixels, largest size in pixels, step
%                 size in pixels
% Description
%   Converts an image to gray scale.  Runs a box counting method for
%   fractal dimension.
%
%   Ideas and algorithm are nicely explained on this GitHub repository
%   readme. https://github.com/pranurs/fractal-dimensions
% 
%   I changed the name and formatting to conform to isetcam style.
%
% See also
%  ieFractalDrawgrid

% Example:
%{
fd = ieFractaldim("PsychBuilding.png",1,100,4)
%}

%% Read imagefile as grayscale image
img = im2gray(imread(imgfile));

% Convert to 0's and 1's
img = imbinarize(img);
ieFigure([],'wide');
tiledlayout(1,2);
nexttile;
imshow(img);
axis image;

% Black -> 1, White -> 0 (since borders are usually in black)
inpMat = 1 - img;

%% Obtain presum for the input matrix
sumMat = preprocess(inpMat);

%% Number of iterations of box counting
n_iter = floor((boxwidth_end - boxwidth_start) / boxwidth_incr);
y = zeros(1,n_iter);
x = zeros(1,n_iter);
num = 0;

for boxwidth = boxwidth_start : boxwidth_incr : boxwidth_end
    count = boxcount(sumMat,boxwidth);
    num = num + 1;
    y(num) = log(count);
    x(num) = log(1/boxwidth);
    fprintf("Iteration Number %d : boxwidth = %d , boxcount = %d\n", num, boxwidth, count);
end

%%% Calculate slope of best fit line using formula
% xmean = mean(x);
% ymean = mean(y);
% fd = sum((x - xmean).*(y - ymean)) / sum((x - xmean).^2);

%%% Plot the points obtained using boxcounting
nexttile;
plot(x,y,"ko","MarkerFaceColor","k");
xlabel("log (1/boxwidth)");
ylabel("log (number of boxes)");
title("Fractal Dimension by Box Counting : '" + imgfile + "'");
hold;

%%% Best fit line for the observed points
bestfit = polyfit(x,y,1);
%%% Fractal dimension is the slope
fd = bestfit(1);
fprintf("Fractal Dimension = %f\n", fd);

%%% Plot the best fit line
plot(x, polyval(bestfit,x), "Color", "green");
axis square
text(x(end),y(end)+2,"FD = " + num2str(fd));
hold;
end

%% Calculate the presum matrix of the input image using dynamic programming
%
% `sumMat(i,j)` is the sum of pixel values in the submatrix having
% opposite corners as `inpMat(1,1)` and `inpMat(i,j)`, both inclusive
%
function sumMat = preprocess(inpMat)
sumMat = zeros(size(inpMat));
[m,n] = size(inpMat);
for i = 1:m
    for j = 1:n
        sumMat(i,j) = inpMat(i,j);
        if (i-1) > 0
            sumMat(i,j) = sumMat(i,j) + sumMat(i-1,j);
        end
        if (j-1) > 0
            sumMat(i,j) = sumMat(i,j) + sumMat(i,j-1);
        end
        if (i-1) > 0 && (j-1) > 0
            sumMat(i,j) = sumMat(i,j) - sumMat(i-1,j-1);
        end
    end
end
end

%%% Function to count the number of boxes having at least 1 non-zero pixel
%%% value in the input matrix
function count = boxcount(sumMat, boxwidth)
[m,n] = size(sumMat);
count = 0;
for i = 1 : boxwidth : m
    for j = 1 : boxwidth : n
        sum = calcsum(sumMat,i,j,min(i+boxwidth-1,m),min(j+boxwidth-1,n));
        if sum > 0
            count = count + 1;
        end
    end
end
end

%% Function to calculate sum of pixel values in a submatrix of the input image
% Uses dynamic programming approach with a presum matrix
function sum = calcsum(sumMat,i,j,k,l)
sum = sumMat(k,l);
if (i-1) > 0
    sum = sum - sumMat(i-1,l);
end
if (j-1) > 0
    sum = sum - sumMat(k,j-1);
end
if (i-1) > 0 && (j-1) > 0
    sum = sum + sumMat(i-1,j-1);
end
end