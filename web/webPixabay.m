classdef webPixabay
    %WEBPIXABAY Access to Pixabay API
    %   Retrieves information about images matching keywords
    %   along with a small size and large size as needed
    %   current default is comma-separated keywords, all of which need to
    %   be matched
    
    properties
        key = '18230017-1d12c1c7c5182cfa172a39807';  
        search_url = 'https://pixabay.com/api/?';
        format;
        tag_mode;
        nojsoncallback;
        defaultPerPage = 20;
        licenses;
        sort;
        defaultWavelist = 400:10:700;
    end
    
    methods
        function obj = webPixabay()
            %WEBPIXABAY Construct an instance of this class
            %   Detailed explanation goes here
            %obj.format = 'json';
            %obj.tag_mode = 'all'; % require all keywords (comma separated) for now
            %obj.nojsoncallback = '1';
            %obj.licenses = '1,2,3,4,5,6,7,8,9,10'; % everything shareable for now
            %obj.sort = 'relevance';
         end
        
        function outputArg = search(obj,ourTags)
            useTags = ourTags(1); % NEED TO TURN INTO X+Y FOR PIXABAY!
            per_page = getpref('ISET','maxSearchResults',obj.defaultPerPage);
            outputArg = webread(obj.search_url, 'key', obj.key, 'tags', useTags, ...
            'image_type', 'photo', 'pretty', 'true', 'order', 'popular', 'per_page', per_page);            
        end
        
        function ourTitle = getImageTitle(obj, fPhoto)
            ourTitle = string(fPhoto.id); % I don't think Pixabay uses titles??
        end
        
        function displayScene(obj, fPhoto, sceneType)
            imageData = obj.getImage(fPhoto, 'large');
            % I, imType, meanLuminance, dispCal, wList
            scene = sceneFromFile(imageData,'rgb',[],[],getpref('ISET','openRGBwavelist', obj.defaultWavelist));
            scene = sceneSet(scene, 'name', string(fPhoto.id)); % I think we can parse the Page URL instead?
            sceneWindow(scene);
            
        end
        
        % pass a Pixabay photo object and desired size to get the URL of the
        % image
        %https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
        function ourURL = getImageURL(obj, fPhoto, wantSize)
            if isequal(wantSize, 'thumbnail')
                % t seems too small, m is a little slow, try q
                ourURL = fPhoto.previewURL;
            else
                ourURL = fPhoto.largeImageURL;
            end 
        end
        
        function ourImage = getImage(obj, fPhoto, wantSize)
            ourURL = getImageURL(obj, fPhoto, wantSize);
            ourImage = webread(ourURL);   
        end
    end
end

