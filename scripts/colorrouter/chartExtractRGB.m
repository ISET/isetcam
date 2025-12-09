function patchRGB = chartExtractRGB(rgbCFApatches)

nPatches = numel(rgbCFApatches);
patchRGB = cell(nPatches,1);

for ii=1:nPatches
    tmp  = rgbCFApatches{ii};
    col1 = tmp(~isnan(tmp(:,1)), 1);
    col2 = tmp(~isnan(tmp(:,2)), 2);
    col2 = col2(1:2:end);
    col3 = tmp(~isnan(tmp(:,3)), 3);    
    patchRGB{ii} = [col1, col2, col3];
end

end

%{
lst1 = isnan(tmp(:,1));
lst2 = isnan(tmp(:,2)); 
lst3 = isnan(tmp(:,3));
%}