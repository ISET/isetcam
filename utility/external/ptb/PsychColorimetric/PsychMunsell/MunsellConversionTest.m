% MunsellConversionToTest
%
% Test our routines that do Munsell conversions.
%
% 11/20/08  dhb, ij,  Wrote it.

% One simple test is to convert a whole bunch of angles to H1, H2 representation
% and then back again, and make sure the inversion works.
angles = linspace(0,359.99,200);
for i = 1:length(angles);
    [H1,H2] = MunsellAngleToHue(angles(i));
    anglesOut(i) = MunsellHueToAngle(H1,H2);
end
figure; clf; hold on
plot(angles,anglesOut,'go','MarkerFaceColor','g','MarkerSize',6);
plot([0 360],[0 360],'r');
axis([0 360 0 360]); axis('square');
xlabel('Input angle')
ylabel('Output angle');
title('Test angle <-> hue conversions');

% Let's test our interpolation routines
munsellData = MunsellPreprocessTable;

% Enter in some test values with known answers from other sources.
% The comparison source is a Munsell conversion program that Inji found on 
% the web.  The program output was used directly to get the xyY values
% for the inputs below, except for the first one in the list.
%
% For the first one in the list, the conversion program gives the wrong luminance,
% because it is only based on data up to Munsell values of 9.  We took the output
% chromaticity it gave and then set the luminance to match what the RIT table
% reports for value 10 samples.
MunsellTestHue = {
'3.444Y'
'0.444GY' 
'8.444PB' 
'4.194PB' 
'3.500YR' 
'0.806P' 
'1.194BG' 
'1.392G' 
'5.528G'
'4.472YR' 
'5.250R' };
MunsellTestValues = {
10
5.7
5.7
5.3
7.3
5.3
4.44
6.45
4.67
4.67
7.41};
MunsellTestChromas = {
8.6
2.4
2.4
7.2
4.2
10.2
12.4
12.99
1.78
1.78
7.23};

MunsellTestxyYs = [
0.4146	0.4263 102.57;
0.3452	0.3711 26.69;
0.2927	0.2901 26.69;
0.2333	0.2372 22.58;
0.3746	0.3485 47.54;
0.2546	0.207  22.58;
0.1619	0.3869 15.2;
0.2766	0.5136 35.56;
0.2979	0.3367 16.93;
0.3514	0.3371 16.93;
0.3951	0.3265 49.25;   
];


% Precompute, and simple test
[xyY0,Xx,trix,vx,Xy,triy,vy,XY,triY,vY] = MunsellGetxyY(MunsellHueToAngle(4.0,'R'),6,3,munsellData);
[xyY1] = MunsellGetxyY(MunsellHueToAngle(4.0,'R'),6,3,[],Xx,trix,vx,Xy,triy,vy,XY,triY,vY);
if (any(xyY0-xyY1) ~= 0)
    fprintf('Uh-oh, precomputed interpolation fails to match raw interpolation\n');
else
    fprintf('Precomputed interpolation working rationally\n');
end


% Test interpolations, using precomputed information
nTestPatches = size(MunsellTestHue);
for i = 1:nTestPatches
    
    H = MunsellTestHue{i};
    H1 = str2num(H(find((double(H) >= double('A')) == 0)));
    H2 = H(find((double(H) >= double('A')) == 1));
    angle = MunsellHueToAngle(H1,H2);
    value = MunsellTestValues{i};
    chroma = MunsellTestChromas{i};
    xyY = MunsellGetxyY(angle,value,chroma,[],Xx,trix,vx,Xy,triy,vy,XY,triY,vY);
    % fprintf('Hue = %s \tHue angle = %f \tValue = %f \tChroma = %f \txyY = %f %f %f \tConversionProgramxyY = %f %f %f\n', H, angle, value, chroma, xyY, MunsellTestxyYs(i,1),MunsellTestxyYs(i,2),MunsellTestxyYs(i,3));
    x = xyY(1,1);
    y = xyY(2,1);
    Y = xyY(3,1);
    xMunsell = MunsellTestxyYs(i,1);
    yMunsell = MunsellTestxyYs(i,2);
    YMunsell = MunsellTestxyYs(i,3);
   
    figure(2);
    subplot(2,2,1);hold on
    plot(x, xMunsell,'go','MarkerFaceColor','g','MarkerSize',6);
    plot([0 1],[0 1],'r');
    axis([0 1 0 1]); axis('square');
    xlabel('Tested x')
    ylabel('Munsell conversed x');
    subplot(2,2,2);hold on
    plot(y, yMunsell,'go','MarkerFaceColor','g','MarkerSize',6);
    plot([0 1],[0 1],'r');
    axis([0 1 0 1]); 
    axis('square');
    xlabel('Tested y')
    ylabel('Munsell conversed y');
    subplot(2,2,3:4);hold on
    plot(Y, YMunsell,'go','MarkerFaceColor','g','MarkerSize',6);
    plot([0 120],[0 120],'r');
    axis([0 120 0 120]); 
    axis('square');
    xlabel('Tested Y')
    ylabel('Munsell conversed Y');
end
hold off







