classdef webData
    %WEBDATA Fetech various kinds of data into ISET
    %   Might wind up being a super-class for various kinds of data, but 
    %   keeping it simple for now.
    %   Handles Hyperspectral and Multispectral as separate cases,
    %   since they are in the database (JSON file) separately,
    %   but they are very similar so possibly code can be combined
    %   HDR images are also handled separately, but they too are .MAT
    %   scenes.
    %
    %   For now they all read from a single JSON file, but it could easily
    %   be split into several 
    
    properties
        dataType; % whether it is Hyperspectral, Multispectral, or HDR
        ourDataStruct;
        waveList = 400:10:700; % default wavelengths for display of hyperspectral
    end
    
    methods
        function obj = webData(forType)
            %WEBDATA Construct an instance of this class
            %   Detailed explanation goes here
            obj.dataType = forType;
            % not sure if we want one big json file or several, one per
            % type, so no we have one file
            ourData = fileread('webISETData.json');
            switch forType
                case 'Hyperspectral'
                    obj.ourDataStruct = jsondecode(ourData).Hyperspectral;
                case 'HDR'
                    obj.ourDataStruct = jsondecode(ourData).HDR;
            end
        end
        
        function outputArg = search(obj,ourTags)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            %outputArg = JSON STRUCT for our scene type   
            ourKeywords = split(ourTags,",");
            ourDataObject = obj.ourDataStruct
            
            for i = 1:length(ourDataObject)
                found = true;
                if isempty(ourDataObject(i).Name) % blank entry
                    found = false;
                else
                    for j = 1: length(ourKeywords)
                        if find(strcmpi(ourDataObject(i).Keywords, strtrim(ourKeywords(j))))
                        elseif isequal(strtrim(ourKeywords(j)), "")
                        else
                            found = false; % currently we want to find all keywords
                        end
                    end
                end
                if found == true
                    if exist('outputArg', 'var')
                        % can we just use ourDataObj(i) since it is typed??
                        %outputArg(end+1) = obj.ourDataStruct.Hyperspectral(i);
                        outputArg(end+1) = ourDataObject(i);
                    else
                        outputArg(1) = ourDataObject(i);
                        %outputArg(1) = obj.ourDataStruct.Hyperspectral(i);
                    end
                end
            end
            if ~exist('outputArg','var') 
                outputArg = [];
            end 
        end
        
        function displayScene(obj, fPhoto, sceneType)
            % common code for all ISET scene types:
            imageDataURL = obj.getImageURL(fPhoto, 'large');
            sceneFile = websave(fPhoto.Name, imageDataURL);
            switch sceneType
                case 'Hyperspectral'
                    % I, imType, meanLuminance, dispCal, wList
                    scene = sceneFromFile(sceneFile,'multispectral',[],[],[]);
                    scene = sceneSet(scene, 'name', fPhoto.Name);
                    delete(sceneFile);
                    sceneWindow(scene);
                case 'HDR'
                    % I, imType, meanLuminance, dispCal, wList
                    scene = sceneFromFile(sceneFile,'multispectral',[],[],obj.waveList);
                    scene = sceneSet(scene, 'name', fPhoto.Name);
                    delete(sceneFile); % I think it is okay to remove now
                    sceneWindow(scene);
                    % try using HDR as default display
                    sceneSet(scene,'renderflag', 'hdr');

                case 'RGB'
                    % I, imType, meanLuminance, dispCal, wList
                    scene = sceneFromFile(sceneFile,'rgb',[],[],obj.waveList);
                    scene = sceneSet(scene, 'name', fPhoto.Name);
                    delete(sceneFile); % I think it is okay to remove now
                    sceneWindow(scene);               
                otherwise
            end
        end
        
        function ourURL = getImageURL(obj, fPhoto, wantSize)
            if isequal(wantSize, 'thumbnail')
                ourURL = fPhoto.Icon;
            else
                ourURL = fPhoto.URL;
            end 
        end
        
        function ourTitle = getImageTitle(obj, fPhoto)
            ourTitle = fPhoto.Name;
        end
        
        function ourImage = getImage(obj, fPhoto, wantSize)
            ourURL = getImageURL(obj, fPhoto, wantSize);
            ourImage = webread(ourURL);   
        end

    end
end
