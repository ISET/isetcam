function bool = compareFields(a, b)
% Compare the fields in two structures
%
%   bool = compareFields(a,b)
%
%Purpose:
%  Compare the values of the subfields of a structure. We use this to
%  check, say, whether the spectrum data are equal or not in two different
%  objects.
%
% Copyright ImagEval Consultants, LLC, 2003.

names{1} = sort(fieldnames(a));
names{2} = sort(fieldnames(b));

nFields = length(names{1});

if nFields ~= length(names{2})
    bool = 0;
    return;
else
    for ii = 1:nFields

        f1 = eval(sprintf('a.%s', char(names{1}(ii))));
        f2 = eval(sprintf('b.%s', char(names{2}(ii))));
        if f1 ~= f2
            bool = 0;
            return;
        end
    end
end

bool = 1;

return;

%
% Debug
% a.spectrum.nWaves = 1
% a.spectrum.resolution = 1
% a.spectrum.wave = 600
%
% b = []
% b.spectrum.nWaves = 1
% b.spectrum.resolution = 1
% b.spectrum.wave = 600
%
% compareFields(a.spectrum,b.spectrum)
