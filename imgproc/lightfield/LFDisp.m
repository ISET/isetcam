% LFDisp - Convenience function to display a 2D slice of a light field
% 
% Usage: 
%     LFSlice = LFDispMousePan( LF )
%               LFDispMousePan( LF )
%     
% 
% The centermost image is taken in s and t. Also works with 3D arrays of images. If an output argument is included, no
% display is generated, but the extracted slice is returned instead.
% 
% Inputs:
% 
%     LF : a colour or single-channel light field, and can a floating point or integer format. For
%          display, it is scaled as in imagesc.  If LF contains more than three colour
%          channels, as is the case when a weight channel is present, only the first three are used.
% 
% 
% Outputs:
% 
%     LFSlice : if an output argument is used, no display is generated, but the extracted slice is returned.
%
%
% See also:  LFDispVidCirc, LFDispMousePan

% Part of LF Toolbox v0.4 released 12-Feb-2015
% Copyright (c) 2013-2015 Donald G. Dansereau

function ImgOut = LFDisp( LF )

LF = squeeze(LF);
LFSize = size(LF);

HasWeight = (ndims(LF)>2 && LFSize(end)==2 || LFSize(end)==4);
HasColor = (ndims(LF)>2 && (LFSize(end)==3 || LFSize(end)==4) );
HasMonoAndWeight = (ndims(LF)>2 && LFSize(end)==2);

if( HasColor || HasMonoAndWeight )
	GoalDims = 3;
else
	GoalDims = 2;
end
while( ndims(LF) > GoalDims )
	LF = squeeze(LF(round(end/2),:,:,:,:,:,:));
end
if( HasWeight )
    LF = squeeze(LF(:,:,1:end-1));
end

if( nargout > 0 )
	ImgOut = LF;
else
	imagesc(LF);
end


