function algList = vcDemosaicAlgorithms
%
%  algList = vcDemosaicAlgorithms
%
%Author: ImagEval
%Purpose:
%   Cell array of the default demosaic algorithms used in the pop-up menu.
%   This list includes the Add, Deletee, and horizontal dashed line.
%

algList = {'Bilinear','Laplacian',...
        'Adaptive Laplacian','Nearest Neighbor',...
        'Add Custom','Delete Custom',...
        '----Custom List----'};

return;