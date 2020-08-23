classdef webFlickr
    %WEBFLICKR Access to Flickr API
    %   Retrieves information about images matching keywords
    %   along with a small size and large size as needed
    %   current default is comma-separated keywords, all of which need to
    %   be matched
    
    properties
        api_key;
        search_url;
        format;
        tag_mode;
        nojsoncallback;
        per_page = 20;
        licenses;
        sort;
        waveList = 400:10:700;
    end
    
    methods
        function obj = webFlickr()
            %WEBFLICKER Construct an instance of this class
            %   Detailed explanation goes here
            obj.api_key = 'a6365f14201cd3c5f34678e671b9ab8d'; % use mine for now at least
            obj.search_url = 'https://www.flickr.com/services/rest/?method=flickr.photos.search';
            obj.format = 'json';
            obj.tag_mode = 'all'; % require all keywords (comma separated) for now
            obj.nojsoncallback = '1';
            obj.licenses = '1,2,3,4,5,6,7,8,9,10'; % everything shareable for now
            obj.sort = 'relevance';
            %obj.api_key = inputArg1;
        end
        
        function outputArg = search(obj,ourTags)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            % 'safe_search', 3,
            outputArg = webread(obj.search_url, 'api_key', obj.api_key, 'tags', ourTags, ...
            'format', obj.format, 'nojsoncallback', obj.nojsoncallback,  ...
            'content_type', 1, 'sort', obj.sort, 'per_page', obj.per_page, 'tag_mode', obj.tag_mode, 'license', obj.licenses);            
        end
        
        function ourTitle = getImageTitle(obj, fPhoto)
            ourTitle = fPhoto.title;
        end
        
        function displayScene(obj, fPhoto, sceneType)
            imageData = obj.getImage(fPhoto, 'large');
            % I, imType, meanLuminance, dispCal, wList
            scene = sceneFromFile(imageData,'rgb',[],[],obj.waveList);
            scene = sceneSet(scene, 'name', fPhoto.title);
            sceneWindow(scene);
            
        end
        
        % pass a Flickr photo object and desired size to get the URL of the
        % image
        %https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
        function ourURL = getImageURL(obj, fPhoto, wantSize)
            if isequal(wantSize, 'thumbnail')
                % t seems too small, m is a little slow, try q
                sizeSuffix = 'q'; % 150 px is q, 100,240 px longest side is t,m
            else
                sizeSuffix = 'b'; % b is 1024 px for now, k = 2048 requires auth
            end 
            ourURL = strcat("https://farm", string(fPhoto.farm), ".staticflickr.com/", string(fPhoto.server) + "/", ...
                string(fPhoto.id), "_" + string(fPhoto.secret), "_" + string(sizeSuffix), ".jpg");
        end
        
        function ourImage = getImage(obj, fPhoto, wantSize)
            ourURL = getImageURL(obj, fPhoto, wantSize);
            ourImage = webread(ourURL);   
        end
    end
end

