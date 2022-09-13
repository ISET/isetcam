function cm = ieCmap(cName,num,gam)
%Prepare simple color maps
%
%  cm = ieCmap(cName,[num],[gam])
%
% Explain here!
% Gamma is used for luminance, but not for rg or bw.
% num is number of elements in the color map.
%
% Examples:
%    rg  = ieCmap('rg',256); plot(rg)
%    by  = ieCmap('by',256); plot(by)
%    lum = ieCmap('bw',256,0.3); plot(lum)
%
% Copyright ImagEval Consultants, LLC, 2010


% Check whether we want a gamma on the r/g/b levels
% Could be an option

if ieNotDefined('cName'), cName = 'rg'; end
if ieNotDefined('num'),   num = 256; end
if ieNotDefined('gam'),   gam = 1; end

cName = ieParamFormat(cName);

switch cName
    case {'redgreen','rg'}
        a = linspace(0,1,num);
        cm = [a(:), flipud(a(:)), 0.5*ones(size(a(:)))];
        
    case {'blueyellow','by'}
        a = linspace(0,1,num);
        cm = [a(:), a(:), flipud(a(:))];
        
    case {'luminance','blackwhite','bw'}
        cm = gray(num).^gam;
        
    otherwise
        error('Unknown color map name %s\n',cName);
end

return