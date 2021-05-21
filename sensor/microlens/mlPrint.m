function mlPrint(ml)
% Print microlens information neatly
%
%   mlPrint([ml])
%
%
% Examples:
%   mlPrint
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('ml')
    ISA = vcGetObject('ISA');
    ml  = sensorGet(ISA,'ml');
end

fprintf('\nMicrolens properties:\n--------------------\n');
fprintf('Focal length (um): %.2f\n',mlensGet(ml,'mlFocalLength','um'));
fprintf('F-number:          %.2f\n',mlensGet(ml,'mlFnumber'));
fprintf('Diameter (um):     %.2f\n',mlensGet(ml,'mlDiameter','um'));
fprintf('Refractive index:  %.2f\n',mlensGet(ml,'mlRefractiveIndex'));
fprintf('\n');
return;