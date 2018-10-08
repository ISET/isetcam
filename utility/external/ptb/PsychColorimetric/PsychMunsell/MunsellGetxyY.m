function [xyY,Xx,trix,vx,Xy,triy,vy,XY,triY,vY] = MunsellGetxyY(angle,value,chroma,munsellData,Xx,trix,vx,Xy,triy,vy,XY,triY,vY)
% [xyY,Xx,trix,Xy,triy,XY,triY] = MunsellGetxyY(angle,value,chroma,munsellData[,Xx,trix,Xy,triy,XY,triY])
%
% Get the xyY coordinates of a specified Munsell renotation by
% interpolating the passed table.
%
% The table should have 6 columns: angle, vaue, chroma, x, y, Y.
%
% For chroma below 2.0, we interpolate x,y,Y for chroma of 2, and
% then adjust x,y by linear interpolation between chroma 0 and 2,
% using the chromaticity of a zero chroma sample as (0.3101, 0.3162).
% This is the chromaticity of illuminant C.  We think this is right.
%
% 11/21/08  dhb, ijk  Wrote it.
% 12/01/08  ijk       Added interpolation for low chroma samples.
%           ijk, dhb  Tried to make it go fast by allowing precomputation.
% 12/22/08  ijk, dhb  Change y chromaticity of CIE C to .3162, to match standard (was .3163).

% Thank heavens Matlab provides n-d interpolation, so we don't have to write it.
if (nargin == 4)
    if(chroma >= 2.000)
        [x,Xx,trix,vx] = MunsellGriddata3(munsellData(:,1),munsellData(:,2),munsellData(:,3),munsellData(:,4),angle,value,chroma,'linear');
        [y,Xy,triy,vy] = MunsellGriddata3(munsellData(:,1),munsellData(:,2),munsellData(:,3),munsellData(:,5),angle,value,chroma,'linear');
        [Y,XY,triY,vY] = MunsellGriddata3(munsellData(:,1),munsellData(:,2),munsellData(:,3),munsellData(:,6),angle,value,chroma,'linear');
    else
        [x,Xx,trix,vx] = MunsellGriddata3(munsellData(:,1),munsellData(:,2),munsellData(:,3),munsellData(:,4),angle,value,2,'linear');
        [y,Xy,triy,vy] = MunsellGriddata3(munsellData(:,1),munsellData(:,2),munsellData(:,3),munsellData(:,5),angle,value,2,'linear');
        [Y,XY,triY,vY] = MunsellGriddata3(munsellData(:,1),munsellData(:,2),munsellData(:,3),munsellData(:,6),angle,value,2,'linear');
        x = 0.3101+(chroma*((x-0.3101)/2));
        y = 0.3162+(chroma*((y-0.3162)/2));
    end
else
    if(chroma >= 2.000)
%         x = MunsellGriddata3(munsellData(:,1),munsellData(:,2),munsellData(:,3),munsellData(:,4),angle,value,chroma,'linear',[],Xx,trix);
%         y = MunsellGriddata3(munsellData(:,1),munsellData(:,2),munsellData(:,3),munsellData(:,5),angle,value,chroma,'linear',[],Xy,triy);
%         Y = MunsellGriddata3(munsellData(:,1),munsellData(:,2),munsellData(:,3),munsellData(:,6),angle,value,chroma,'linear',[],XY,triY);
        x = MunsellGriddata3([],[],[],vx,angle,value,chroma,'linear',[],Xx,trix);
        y = MunsellGriddata3([],[],[],vy,angle,value,chroma,'linear',[],Xy,triy);
        Y = MunsellGriddata3([],[],[],vY,angle,value,chroma,'linear',[],XY,triY);
    else
%         x = MunsellGriddata3(munsellData(:,1),munsellData(:,2),munsellData(:,3),munsellData(:,4),angle,value,2,'linear',[],Xx,trix);
%         y = MunsellGriddata3(munsellData(:,1),munsellData(:,2),munsellData(:,3),munsellData(:,5),angle,value,2,'linear',[],Xy,triy);
%         Y = MunsellGriddata3(munsellData(:,1),munsellData(:,2),munsellData(:,3),munsellData(:,6),angle,value,2,'linear',[],XY,triY);
        x = MunsellGriddata3([],[],[],vx,angle,value,2,'linear',[],Xx,trix);
        y = MunsellGriddata3([],[],[],vy,angle,value,2,'linear',[],Xy,triy);
        Y = MunsellGriddata3([],[],[],vY,angle,value,2,'linear',[],XY,triY);
        x = 0.3101+(chroma*((x-0.3101)/2));
        y = 0.3162+(chroma*((y-0.3162)/2));
    end
end
xyY = [x y Y]';
