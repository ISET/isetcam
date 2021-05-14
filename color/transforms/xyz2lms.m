function imgLMS = xyz2lms(imgXYZ, cbType, varargin)
% Transform an XYZ image to Stockman cone format, colorblind permitted
%
%   imgLMS = xyz2lms(imgXYZ, cbType, varargin)
%
% This function convert XYZ data to LMS in Stockman space.  When cbType is
% not passed in, or it is set to 0, this is the default calculation.;
%
% A calculation for color blind can also be performed.  This is set by
% using format the cbType variable.  The estimate for color blind is done
% either by
%
%  * interpolating the missing cone using the algorithm in Brettel, Vienot
%  and Mollon JOSA 14/10 1997. The idea in that paper is that the preserved
%  cones are preserved.  The missing cone is assigned a value that is  a
%  linear transform of the preserved cones, or
%
%  * returning a zero for the missing cone type
%
% Inputs:
%   imgXYZ      = XYZ image to transform
%   cbType      = Type of colorblindness,
%                 Brettel form:   1 = protanopia, 2 = deuteranopia, 3 = tritanopia
%                 Zero filled:   -1 = protanopia, -2 = deuteranopia, -3 = tritanopia
%   whiteXYZ    = White point (equal energy), needed for Brettel type calculation.
%
% Outputs:
%   LMS values in Stockman LMS space
%
%
% Example:
%   scene = sceneCreate('reflectance chart');
%   ieAddObject(scene); sceneWindow
%   imgXYZ = sceneGet(scene,'xyz');
%      vcNewGraphWin; tmp = RGB2XWFormat(imgXYZ);
%      plot3(tmp(:,1),tmp(:,2),tmp(:,3),'.'); grid on
%   whiteXYZ = sceneGet(scene,'illuminant xyz');
%   cbType = 1; imgLMS = xyz2lms(imgXYZ, cbType, whiteXYZ);
%   vcNewGraphWin; imagescRGB(lms2srgb(imgLMS));
%
% NOTE:
%   This code is based on the vischeck simulator now incorporated into
%   GIMP. (Michael Bennett)
%
% See also: s_HumanColorBlindm, lms2srgb
%
% (c) Stanford, VISTA Team

%% Parameters

% Just convert to LMS by default.
if ieNotDefined('cbType'), cbType = 0; end
% We read varargin within the conditions.

% Appearance (Brettel) transformation
if cbType > 0
    
    % Brettel assume that equal energy
    if isempty(varargin), error('whiteXYZ required');
    else whiteXYZ = varargin{1};
    end
    
    % Compute the cone responses to a white (anchor_e).  These are the
    % anchor values for the equal energy stimulus.  In our hands, though,
    % we appear to be using the white of the display as whiteXYZ, though
    % this always be the equal energy white.
    anchor_e = reshape(whiteXYZ, [1 3]) * colorTransformMatrix('xyz2lms');
    
    % Convert XYZ data to LMS format used by the authors
    imgLMS = imageLinearTransform(imgXYZ, colorTransformMatrix('xyz2lms'));
    
    % These anchor values are derived in the paper and used to compute the
    % missing cone value.  I suppose we could just use the Stockman data
    % that we have rather than these numbers.  Our data do not match these
    % values exactly, and we are not sure why (BW).
    %
    % Load the LMS anchor-point values for lambda = 475 & 485 nm (for protans &
    % deutans) and the LMS values for lambda = 575 & 660 nm (for tritans).  I
    % think these anchor points are the Stockman fundamentals values. After
    % checking, they are close.  See below.
    %
    % LMS for 475, I guess. Closest to 473. ieReadSpectra('stockman',[475])
    % From the Stockman table 8, columns 5-7, the values are
    % anchors 1:3  0.1192, 0.2122, 0.5288
    %  We don't know where these numbers came from.  We need to ask Alex or
    %  Bob or Michael or someone.  We decided to go with Stockman data as
    %     %  per the paper.
    %         anchor(1) = 0.08008;  anchor(2) = 0.1579;   anchor(3) = 0.5897;
    %         % LMS for 485, I guess. Closest to 482. % ieReadSpectra('stockman',[485])
    %         anchor(4) = 0.1284; anchor(5) = 0.2237; anchor(6) = 0.3636;
    %         % LMS for 575.  Pretty good.   % ieReadSpectra('stockman',[576])
    %         anchor(7) = 0.9856; anchor(8) = 0.7325; anchor(9) = 0.001079;
    %         % LMS for 660, Good.% ieReadSpectra('stockman',[662])
    %         anchor(10) = 0.0914;   anchor(11) = 0.007009;  anchor(12) = 0.0;
    %
    % Changed March 1 2014 to be consistent with the Brettel paper.  The
    % numerical values are quite similar, but this makes the logic
    % transparent.
    anchor(1:3)   = ieReadSpectra('stockman',[475]);
    anchor(4:6)   = ieReadSpectra('stockman',[485]);
    anchor(7:9)   = ieReadSpectra('stockman',[575]);
    anchor(10:12) = ieReadSpectra('stockman',[660]);
    
    % To verify the the calculations and values, do this:
    %  lms = ieReadSpectra('stockman',400:700);
    %  g = 4; g = (g-1)*3 + 1; diff = lms - ones(301,3)*diag([anchor(g:(g+2))]);
    %  err = sqrt(diag(diff*diff'));[v,idx] = min(err); 400 + idx
    
    % Depending on color blindness type
    switch cbType
        case 1          % Protanopia
            % These formula are Equation (8) in the Bretell paper.
            % find a,b,c for lambda = 575nm and lambda = 475.
            % These are the LMS white values and the anchor values.
            
            % We calculate the cross product between the anchor for the
            % white points and this particular type of dichromat.
            % Less than inflection
            a1 = anchor_e(2) * anchor(9) - anchor_e(3) * anchor(8);
            b1 = anchor_e(3) * anchor(7) - anchor_e(1) * anchor(9);
            c1 = anchor_e(1) * anchor(8) - anchor_e(2) * anchor(7);
            
            % Greater than inflection
            a2 = anchor_e(2) * anchor(3) - anchor_e(3) * anchor(2);
            b2 = anchor_e(3) * anchor(1) - anchor_e(1) * anchor(3);
            c2 = anchor_e(1) * anchor(2) - anchor_e(2) * anchor(1);
            
            % Divides the space according to this equal energy anchor
            inflection = (anchor_e(3) / anchor_e(2));
            
            % Interpolate missing L values for protonape
            L = imgLMS(:,:,1); M = imgLMS(:,:,2); S = imgLMS(:,:,3);
            lst = ((S ./ M) < inflection);
            
            % We apply the two different transforms depending on which side
            % of the inflection point
            L(lst)  = -(b1*M(lst)  + c1*S(lst))  / a1;
            L(~lst) = -(b2*M(~lst) + c2*S(~lst)) / a2;
            imgLMS(:,:,1) = L;
            % vcNewGraphWin; imagescRGB(imgLMS);
            
        case 2          % Deuteranopia
            % find a,b,c for lam=575nm and lam=475, again.
            % Less than inflection
            a1 = anchor_e(2) * anchor(9) - anchor_e(3) * anchor(8);
            b1 = anchor_e(3) * anchor(7) - anchor_e(1) * anchor(9);
            c1 = anchor_e(1) * anchor(8) - anchor_e(2) * anchor(7);
            % Greater than inflection
            a2 = anchor_e(2) * anchor(3) - anchor_e(3) * anchor(2);
            b2 = anchor_e(3) * anchor(1) - anchor_e(1) * anchor(3);
            c2 = anchor_e(1) * anchor(2) - anchor_e(2) * anchor(1);
            
            inflection = (anchor_e(3) / anchor_e(1));
            
            % Interpolate missing M values for deuteranope
            L = imgLMS(:,:,1); M = imgLMS(:,:,2); S = imgLMS(:,:,3);
            lst = ((S ./ L) < inflection);
            M(lst)  = -(a1*L(lst)  + c1*S(lst)) / b1;
            M(~lst) = -(a2*L(~lst) + c2*S(~lst))/ b2;
            imgLMS(:,:,2) = M;
            % vcNewGraphWin; imagescRGB(imgLMS);title('New formula');
            
        case 3          % Tritanopia
            
            % find for lam=660 and lam=485 */
            % Less than the inflection
            a1 = anchor_e(2) * anchor(12) - anchor_e(3) * anchor(11);
            b1 = anchor_e(3) * anchor(10)  - anchor_e(1) * anchor(12);
            c1 = anchor_e(1) * anchor(11) - anchor_e(2) * anchor(10);
            
            % Greater than the inflection
            a2 = anchor_e(2) * anchor(6)  - anchor_e(3) * anchor(5);
            b2 = anchor_e(3) * anchor(4)  - anchor_e(1) * anchor(6);
            c2 = anchor_e(1) * anchor(5)  - anchor_e(2) * anchor(4);
            
            % Inflection point
            inflection = (anchor_e(2) / anchor_e(1));
            
            % Interpolate missing M values for tritanope
            L = imgLMS(:,:,1); M = imgLMS(:,:,2); S = imgLMS(:,:,3);
            lst = ((M ./ L) < inflection);
            S(lst)  = -(a1*L(lst)  + b1*M(lst)) / c1;
            S(~lst) = -(a2*L(~lst) + b2*M(~lst))/ c2;
            imgLMS(:,:,3) = S;
            %vcNewGraphWin; imagescRGB(imgLMS);title('New formula');
            
    end
    
    
else  % cbType <= 0
    % Place a constant in the missing cone class. Value is set by
    % varargion.
    if isempty(varargin), extrapVal = 0;
    else extrapVal = varargin{1};
    end
    
    imgLMS = imageLinearTransform(imgXYZ, colorTransformMatrix('xyz2lms'));
    
    switch abs(cbType)
        case 1
            imgLMS(:,:,1) = extrapVal;
        case 2
            imgLMS(:,:,2) = extrapVal;
        case 3
            imgLMS(:,:,3) = extrapVal;
    end
end


return
