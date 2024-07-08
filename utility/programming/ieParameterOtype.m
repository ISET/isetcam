function [oType,p] = ieParameterOtype(param)
% Determine object type from parameter name
%
%   [oType,p] = ieParameterOtype(param,varargin)
%
% Parse the parameter string to determine which object (oType) and the
% parameter itself (p).
%
% Some will work without disambiguation because they are unique
%
%   oType = ieParameterOtype('dsnu')
%
% We also can take in the varargin, such as for units
%
%   [oType, p] = ieParameterOtype('pixel/size');
%
% This one won't work because size is available for too many objects
%
%    ieParameterOtype('size')
%
% This routine will require continual maintenace to maintain consistency
% with the specific object gets and sets.
%
% Examples:
%   [o p] = ieParameterOtype('dsnu sigma')
%   [o p] = ieParameterOtype('oi size')
%   [o p] = ieParameterOtype('pixel size')
%   [o p] = ieParameterOtype('scene/hfov')
%   [o p] = ieParameterOtype('scene hfov')
%   [o p] = ieParameterOtype('optics/fnumber')
%   [o p] = ieParameterOtype('l3 sensor patches');
%   oType = ieParameterOtype('sensor dsnu')
%   [oType,p] = ieParameterOtype('optics/fnumber')
%   oType = ieParameterOtype('wvf zcoeffs')
%
% Copyright Imageval LLC, 2013


%%
if ~exist('param','var') || isempty(param), error('Param required.'); end

%% If the param is simply one of the objects, return it as the oType

p = [];
switch ieParamFormat(param)
    case {'scene'}
        oType = 'scene'; return;
    case 'oi'
        oType = 'oi'; return;
    case 'optics'
        oType = 'optics'; return;
    case 'wvf'
        oType = 'wvf'; return;
    case 'sensor'
        oType = 'sensor'; return;
    case 'pixel'
        oType = 'pixel'; return;
    case {'vci','ip'}
        oType = 'ip'; return;
    case {'display'}
        oType = 'display'; return;
    case {'l3'}
        oType = 'l3'; return
end

%% Find the string before the first space, '/', or '_'

% When we call these subtypes, we seem to always need a break
% character after the subtype, like pixel or wvf.  This could be fixed
% up, but it would take a lot of checking.  In some cases
% (sensorCreatePixel) we check and insert a space.
c1 = strfind(param,' ');   % Find the spaces
c2 = strfind(param,'/');   % Find the '/'
c3 = strfind(param,'_');   % Find the '_'
pos = min([c1,c2,c3]);

% Parse and return the string as oType
oType = [];
if ~isempty(pos)
    switch param(1:(pos-1))
        case 'scene'
            oType = 'scene';
        case 'oi'
            oType = 'oi';
        case 'optics'
            oType = 'optics';
        case 'wvf'
            oType = 'wvf';
        case 'sensor'
            oType = 'sensor';
        case 'pixel'
            oType = 'pixel';
        case {'vci','ip'}
            oType = 'ip';
        case {'display'}
            oType = 'display';
        case {'l3'}
            oType = 'l3';
    end
    
    % Check for success. Return the parameter, without the prepended term
    % and lower case and no spaces
    if ~isempty(oType)
        p = ieParamFormat(param((pos+1):end));
        return;
    end
end

%% We didn't find the oType yet.

% Maybe param is one of the unique object parameter strings.  We have a
% list of parameters here that uniquely identify the oType.
%
% I think there is a better way to do this in vistasoft, as per Adrian's
% coding using hashing.  Not sure we can use it in previous versions of
% Matlab, though.
p = ieParamFormat(param);
switch p
    case {'objectdistance','meanluminance','luminance', ...
            'illuminant','illuminantname','illuminantenergy', ...
            'illuminantphotons','illuminantxyz','illuminantwave',...
            'illuminantcomment','illuminantformat'}
        oType = 'scene';
        
    case {'optics','opticsmodel','diffusermethod','diffuserblur'...
            'psfstruct','sampledrtpsf','psfsampleangles','psfanglestep',...
            'psfimageheights','raytraceopticsname',...
            }
        oType = 'oi';
        
    case {'fnumber','effectivefnumber','focallength','power',...
            'imagedistance','imageheight','imagewidth',...
            'numericalaperture','aperturedameter','apertureradius',...
            'magnification','pupilmagnification',...
            'offaxismethod','cos4thmethod','cos4thdata',...
            'otfdata','otfsize','otffx','otffy','otfsupport'...
            'psfdata','psfspacing','psfsupport',...
            'incoherentcutoffspatialfrequency','maxincoherentcutoffspatialfrequency',...
            'rtname','raytrace','rtopticsprogram','rtlensfile','rteffectivefnumber',...
            'rtfnumber','rtmagnification','rtreferencewavelength',...
            'rtobjectdistance','rtfieldofview','rteffectivefocallength',...
            'rtpsf','rtpsfdata','rtpsfsize','rtpsfwavelength',...
            'rtpsffieldheight','rtpsfsamplespacing',...
            'rtpsfsupport','rtpsfsupportrow','rtpsfsupportcol',...
            'rtotfdata','rtrelillum','rtrifunction','rtriwavelength',...
            'rtrifieldheight','rtgeometry','rtgeomfunction','rtgeomwavelength',...
            'rtgeomfieldheight','rtgeommaxfieldheight'}
        oType= 'optics';
    case {'zcoeffs','constantSampleIntervalDomain','refSizeOfFieldMM'}
        oType = 'wvf';
    case {'chiefrayangle','chiefrayangledegrees','sensoretendue',...
            'microlens','volts','digitalvalues','electrons',...
            'dvorvolts''roielectrons','roivoltsmean',...
            'roielectronsmean','hlinevolts','hlineelectrons',...
            'vlinevolts','vlineelectrons','responseratio','responsedr'...
            'analoggain','analogoffset','sensordynamicrange',...
            'quantization','nbits','maxoutput','quantizatonlut', ...
            'quantizationmethod','filtertransmissivities','infraredfilter',...
            'cfaname','filternames','nfilters','filtercolorletters',...
            'filtercolorletterscell','filterplotcolors','spectralqe',...
            'pattern','dsnusigma','prnusigma','fpnparameters',...
            'dsnuimage','prnuimage','columnfpn','columndsnu','columnprnu',...
            'coloffsetfpnvector','colgainfpnvector',...
            'noiseflag','reusenoise','noiseseed',...
            'pixel',...
            'autoexpsoure','exposuretime','uniqueexptime','exposureplane',...
            'cds','vignetting',...
            'nsamplesperpixel'...
            'sensormovement','movementpositions','framesperpositions',...
            'sensorpositionsx','sensorpositionsy',...
            'mccrecthandles','mcccornerpoints'}
        oType = 'sensor';
        
    case {'pdsize','fillfactor','pdarea','pdspectralqe',...
            'conversiongain','voltageswing','wellcapacity',...
            'darkcurrentdensity','darkcurrent','darkvoltage','darkelectrons',...
            'readnoiseelectrons','readnoisevolts','readnoisemillivolts',...
            'pdspectralsr','pixeldr'}
        oType = 'pixel';
        
    case {'render','colorbalance','colorbalancemethod',...
            'demosaic','demosaicmethod','colorconversion','colorconversionmethod',...
            'internalcolorspace','internalcolormatchingfunciton',...
            'display','displayxyz','displayxy','displaywhitepoint',...
            'displaymaxluminance','displayspd','displaygamma','displaymaxrgb',...
            'displaydpi','displayviewingdistance','l3'}
        oType = 'ip';
    case {'trainingilluminant','clusters','filters','sensorpatches'}
        % There could be many more parameters here.
        oType = 'l3';
    case {'assetobject', 'assetbranch', 'assetlight'}
        oType = 'asset';
    otherwise
        % Default was 'camera'.  Did the change break it?
        oType = '';
        
end

end

