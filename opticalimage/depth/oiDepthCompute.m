function [oiD,D] = oiDepthCompute(oi,scene,imageDist,depthEdges,cAberration,displayFlag)
%Compute cell array of OI for different depth planes from scene
%
%  [oiD,D] = oiDepthCompute(oi,scene,imageDist,depthEdges,cAberration)
%
% Return:
%  oiD:  A cell array of irradiance images.  There is one image for  from a
%        scene. For each of the distances (m) in depthEdges. The defocused
%        image is calculated for each distance.  This cell array of
%        irradiance images is combined (oiDepthCombine) into a single
%        image.  The combination is based on picking out the pixels at the
%        appropriate depth.
% imageDist:   The distance of the image plane behind the lens (default:
%              focal length).
% depthEdges:  A vector of distances from the lens.  The number of
%              depthEdges defines the number of OIs that are computed.
% cAberration: Defocus in diopters (chromatic aberration, longitudinal) for
%              each wavelength (default = 0).
% displayFlag: Display the defocused images is shown in the oiWindow
%              (Default=true)
%
% See also:  oiDepthCombine, oiDepthSegmentMap, s_opticsDepthScene
%
% Copyright ImagEval Consultants, LLC, 2011.

if ieNotDefined('oi'),        error('oi required'); end
if ieNotDefined('scene'),     error('scene required'); end
if ieNotDefined('imageDist')
    imageDist = opticsGet(oiGet(oi,'optics'),'focal length','m');
end
if ieNotDefined('depthEdges'),  error('depthEdges required'); end
if ieNotDefined('cAberration'), cAberration = []; end
if ieNotDefined('displayFlag'), displayFlag = 1; end

% Set the scene map to a single depth.  We  sweep through the depthEdges
% for the whole scene.
oMap  = sceneGet(scene,'depth map');
[r,c] = size(oMap);
dMap  = ones(r,c);

% Cell array of oi images at different depths
oiD = cell(1,length(depthEdges));

% Loop and create the OI structures
for ii=1:length(depthEdges)
    scene = sceneSet(scene,'depth map',dMap*depthEdges(ii));
    [oiD{ii},tmp,D] = s3dRenderDepthDefocus(scene,oi,imageDist,[],cAberration);
    oiD{ii} = oiSet(oiD{ii},'name',sprintf('Defocus %.2f',D));
    if displayFlag
        ieAddObject(oiD{ii});  oiWindow
    end
end

return
