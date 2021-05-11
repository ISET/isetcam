function m = ieMemoryCheck(unit, level)
%Calculate the memory use in the calling routine or base
%
%    m = ieMemoryCheck(unit,level)
%
% The output can be presented in megabytes ('MB') kilobytes ('KB') or bytes
%('B').
%
% Example
%    m = ieMemoryCheck('KB','base')
%    m = ieMemoryCheck('MB','caller')
%
% Copyright ImagEval, LLC, 2005

if ieNotDefined('unit'), unit = 'b'; end
if ieNotDefined('level'), level = 'caller'; end

m = 0;
t = evalin(level, 'whos');
for ss = 1:length(t), m = m + (t(ss).bytes); end

switch lower(unit)
    case 'mb'
        s = 1e6;
    case 'kb'
        s = 1e3;
    otherwise
        s = 1
end

fprintf('Memory %f %s\n', m/s, unit);

return;
