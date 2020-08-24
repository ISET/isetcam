classdef webLOC
    %WEBLOC Access to Library of Congress (LOC) API
    %   Retrieves information about images matching a text string
    %   along with a small size and large size as needed
    %   current default is comma-separated keywords, all of which need to
    %   be matched
    
    properties
        search_url;
        format;
        tag_mode;
        defaultPerPage = 20;
        sort = 'date_desc';
        defaultWavelist = 400:10:700;
    end
    
    methods
        function obj = webLOC()
            %WEBLOC Construct an instance of this class
            %   Detailed explanation goes here
            obj.search_url = 'https://loc.gov/pictures/search/?fo=json&q='; % follow by text and format  
            % included already I think: obj.format = '&fo=json';
            obj.tag_mode = 'all'; % require all keywords (comma separated) for now
            
        end
        
        function outputArg = search(obj,ourTags)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            % 'safe_search', 3,
            per_page = getpref('ISET','maxSearchResults',obj.defaultPerPage);
            searchResult = webread(strcat(obj.search_url, ourTags, "&c=", ...
                string(per_page))); % fix per page to whatever it really is!            
            outputArg = jsondecode(searchResult).results; % results is the array of image structs
        end
        
        function ourTitle = getImageTitle(obj, fPhoto)
            ourTitle = fPhoto.title;
        end
        
        function displayScene(obj, fPhoto, sceneType)
            imageData = obj.getImage(fPhoto, 'large');
            % I, imType, meanLuminance, dispCal, wList
            scene = sceneFromFile(imageData,'rgb',[],[],getpref('ISET','openRGBwavelist', obj.defaultWavelist));
            scene = sceneSet(scene, 'name', fPhoto.title);
            sceneWindow(scene);
            
        end
        
        % pass an LOC photo object and desired size to get the URL of the
        % image
        function ourURL = getImageURL(obj, fPhoto, wantSize)
            if isequal(wantSize, 'thumbnail')
                ourURL = fPhoto.image.thumb;
            else
                ourURL = fPhoto.image.full;
            end 
            if ourURL(1:2) == "//"
                ourURL = strcat("https:", ourURL); % Matlab doesn't like the raw CDN notation
            end
        end
        
        function ourImage = getImage(obj, fPhoto, wantSize)
            ourURL = getImageURL(obj, fPhoto, wantSize);
            ourImage = webread(ourURL);   
        end
    end
end

