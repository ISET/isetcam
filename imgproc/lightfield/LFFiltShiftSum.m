% LFFiltShiftSum - a spatial-domain depth-selective filter, with an effect similar to planar focus
%
% Usage:
%
%     [ImgOut, FiltOptions, LF] = LFFiltShiftSum( LF, Slope, FiltOptions )
%     ImgOut = LFFiltShiftSum( LF, Slope )
%
% 
% This filter works by shifting all u,v slices of the light field to a common depth, then adding the slices together to
% yield a single 2D output.  The effect is very similar to planar focus, and by controlling the amount of shift one may
% focus on different depths.  If a weight channel is present in the light field it gets used during normalization.
% 
% 
% See LFDemoBasicFiltLytro for example usage.
% 
%
% Inputs
%
%        LF : The light field to be filtered
% 
%     Slope : The amount by which light field slices should be shifted, this encodes the depth at which the output will
%             be focused. The relationship between slope and depth depends on light field parameterization, but in
%             general a slope of 0 lies near the center of the captured depth of field.
%
%     [optional] FiltOptions : struct controlling filter operation
%                 Precision : 'single' or 'double', default 'single'
%                  Aspect4D : aspect ratio of the light field, default [1 1 1 1]
%                 Normalize : default true; when enabled the output is normalized so that darkening near image edges is
%                             removed
%             FlattenMethod : 'Sum', 'Max' or 'Median', default 'Sum'; when the shifted light field slices are combined,
%                             they are by default added together, but median and max can also yield useful results.
%              InterpMethod : default 'linear'; this is passed on to interpn to determine how shifted light field slices
%                             are found; other useful settings are 'nearest', 'cubic' and 'spline'
%                 ExtrapVal : default 0; when shifting light field slices, pixels falling outside the input light field
%                             are set to this value
%                 MinWeight : during normalization, pixels for which the output value is not well defined (i.e. for
%                             which the filtered weight is very low) get set to 0. MinWeight sets the threshold at which
%                             this occurs, default is 10 * the numerical precision of the output, as returned by eps
%
% Outputs:
% 
%            ImgOut : A 2D filtered image
%       FiltOptions : The filter options including defaults, with an added FilterInfo field detailing the function and 
%                     time of filtering.
%                LF : The 4D light field resulting from the shifting operation
%
% See also:  LFDemoBasicFiltGantry, LFDemoBasicFiltIllum, LFDemoBasicFiltLytroF01, LFBuild2DFreqFan, LFBuild2DFreqLine,
% LFBuild4DFreqDualFan, LFBuild4DFreqHypercone, LFBuild4DFreqHyperfan, LFBuild4DFreqPlane, LFFilt2DFFT, LFFilt4DFFT,
% LFFiltShiftSum

% Part of LF Toolbox v0.4 released 12-Feb-2015
% Copyright (c) 2013-2015 Donald G. Dansereau

function [ImgOut, FiltOptions, LF] = LFFiltShiftSum( LF, Slope, FiltOptions )

FiltOptions = LFDefaultField('FiltOptions', 'Precision', 'single'); 
FiltOptions = LFDefaultField('FiltOptions', 'Normalize', true);
FiltOptions = LFDefaultField('FiltOptions', 'MinWeight', 10*eps(FiltOptions.Precision));  
FiltOptions = LFDefaultField('FiltOptions', 'Aspect4D', 1); 
FiltOptions = LFDefaultField('FiltOptions', 'FlattenMethod', 'sum'); % 'Sum', 'Max', 'Median'
FiltOptions = LFDefaultField('FiltOptions', 'InterpMethod', 'linear'); 
FiltOptions = LFDefaultField('FiltOptions', 'ExtrapVal', 0); 

if( length(FiltOptions.Aspect4D) == 1 )
	FiltOptions.Aspect4D = FiltOptions.Aspect4D .* [1,1,1,1];
end

LFSize = size(LF);
NColChans = size(LF,5);
HasWeight = ( NColChans == 4 || NColChans == 2 );
if( HasWeight )
	NColChans = NColChans-1;
end

LF = LFConvertToFloat(LF, FiltOptions.Precision);

%---
if( FiltOptions.Normalize )
	if( HasWeight )
		for( iColChan = 1:NColChans )
			LF(:,:,:,:,iColChan) = LF(:,:,:,:,iColChan) .* LF(:,:,:,:,end);
		end
	else % add a weight channel
		LF(:,:,:,:,end+1) = ones(size(LF(:,:,:,:,1)), FiltOptions.Precision);
	end
end

%---
TVSlope = Slope * FiltOptions.Aspect4D(3) / FiltOptions.Aspect4D(1);
SUSlope = Slope * FiltOptions.Aspect4D(4) / FiltOptions.Aspect4D(2);

[vv, uu] = ndgrid(1:LFSize(3), 1:LFSize(4));

VVec = linspace(-0.5,0.5, LFSize(1)) * TVSlope*LFSize(1);
UVec = linspace(-0.5,0.5, LFSize(2)) * SUSlope*LFSize(2);

for( TIdx = 1:LFSize(1) )
	VOffset = VVec(TIdx);
    for( SIdx = 1:LFSize(2) )
		UOffset = UVec(SIdx);
		
        for( iChan=1:size(LF,5) )
            CurSlice = squeeze(LF(TIdx, SIdx, :,:, iChan));
            CurSlice = interpn(CurSlice, vv+VOffset, uu+UOffset, FiltOptions.InterpMethod, FiltOptions.ExtrapVal);
            LF(TIdx,SIdx, :,:, iChan) = CurSlice;
        end
    end
    fprintf('.');
end

switch( lower(FiltOptions.FlattenMethod) )
	case 'sum'
		ImgOut = squeeze(sum(sum(LF,1),2));
	case 'max'
		ImgOut = squeeze(max(max(LF,[],1),[],2));
	case 'median'
		t = reshape(LF, [prod(LFSize(1:2)), LFSize(3:end)]);
		ImgOut = squeeze(median(t));
	otherwise
		error('Unrecognized method');
end

%---
if( FiltOptions.Normalize )
	WeightChan = ImgOut(:,:,end);
	InvalidIdx = find(WeightChan < FiltOptions.MinWeight);
	ChanSize = numel(ImgOut(:,:,1));
	for( iColChan = 1:NColChans )
		ImgOut(:,:,iColChan) = ImgOut(:,:,iColChan) ./ WeightChan;
		ImgOut( InvalidIdx + ChanSize.*(iColChan-1) ) = 0;
	end
end

TimeStamp = datestr(now,'ddmmmyyyy_HHMMSS');
FiltOptions.FilterInfo = struct('mfilename', mfilename, 'time', TimeStamp, 'VersionStr', LFToolboxVersion);