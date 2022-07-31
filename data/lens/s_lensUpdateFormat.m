
chdir(piGetDir('lens');
lensFiles = dir('*.json');
nFile = numel(lensFiles);

for ii=1:nFile
    thisR = recipe;
    thisR.camera = piCameraCreate('omni','lensFile',lensFiles(ii).name);
    [focalLength, fNumber, metadata] = piRecipeFindOpticsParams(thisR);
    if metadata
        fprintf('Found metadata for %s\n',lensFiles(ii).name);
    elseif ~isempty(focalLength) && ~isempty(fNumber)
        fprintf('Updating %s\n',lensFiles(ii).name);
        thisLens = jsonread(lensFiles(ii).name);
        thisLens.metadata.focalLength = focalLength;
        thisLens.metadata.fNumber = fNumber;
        d = thisLens.description;
        if strncmp(d,' Description: ',14)
            thisLens.description = d(15:end);
        end
        n = thisLens.name;
        if strncmp(n,' Name: ',7)
            thisLens.name = n(8:end);
        end
        jsonwrite(lensFiles(ii).name,thisLens);
    else
        fprintf('Tried but failed to update %s\n',lensFiles(ii).name);
    end
end

