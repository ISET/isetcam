classdef cpBurstIP < cpIP
    %cpBurstIP Burst-supporting version of ciIP Wrapper for ip to support computational cameras
    %
    % History:
    %   Initial Version: D. Cardinal, 01/2021
    %
    % Unlike a classic "ip" the BurstIP is capable of a variety of ways of
    % combining frames, including some that produce an RGB image instead of
    % an ip. 
    %
    % 
    
    properties
        % sub-class properties here
        returnIP = false; %merge in RGB space by default
    end
    
    methods
        function obj = cpBurstIP(userIP)
            %cpBurstIP Construct an instance of this class
            %   create a programmable ip
            if ~exist('userIP', 'var'); userIP = []; end
            obj = obj@cpIP(userIP);
        end
        
        function aPicture = compute(sensorImages)
            %Compute final image from sensor captures
            aPicture = compute@ciIP(sensorImages);
        end

        % This computes an output photograph. 
        function ourPhoto = ispCompute(obj, sensorImages, intent, options)
            
            arguments
                obj;
                sensorImages;
                intent;
                % Use our default for whether to just return an IP if the
                % user doesn't specify what to do
                options.returnIP = obj.returnIP;
            end
            
            switch intent
                case 'HDR'
                    % decide if we want to let the ip combine raw data, or
                    % demosaic it first
                    if options.returnIP
                        % ipCompute for HDR assumes we have an array of voltages
                        % in a single sensor, NOT an array of sensors
                        % so first we merge our sensor array into one sensor
                        sensorImage = obj.mergeSensors(sensorImages);
                        sensorImage = sensorSet(sensorImage,'exposure method', 'bracketing');
                        obj.ip = ipSet(obj.ip, 'combination method', 'longest');
                        obj.ip = ipCompute(obj.ip, sensorImage);
                        ourPhoto = obj.ip;
                    else
                        % Might want the option to combine before or after
                        %obj.ip = ipSet(obj.ip, 'render demosaic only', true);
                        
                        % now we want to register all the image data
                        frameExposures = [];
                        for ii = 1:numel(sensorImages)
                            tmpIP = ipCompute(obj.ip, sensorImages(ii));
                            frameExposures = [frameExposures sensorImages(ii).integrationTime];
                            currentImage = ipGet(tmpIP,'data srgb');
                            % we can convert to sRGB here, or after
                            % registration
                            %currentImage = lrgb2srgb(currentImage); %make useable
                            if ii > 1
                                tmpImage = obj.registerRGBImages(currentImage, baseImage);
                                imageFrames{ii} = uint8(round(rescale(tmpImage, 0, 255)));
                            else
                                imageFrames = {obj.ipToImage(tmpIP)};
                                % maybe should try to pick the "middle
                                % image"?
                                baseImage = currentImage;
                            end
                        end
                        hdrImage = makehdr(imageFrames, 'RelativeExposure', frameExposures./min(frameExposures));
                        ourPhoto = tonemap(hdrImage);
                        
                        
                    end
                case 'Burst'
                    % baseline is just sum the voltages, without alignment
                    sensorImage = obj.mergeSensors(sensorImages);
                    sensorImage = sensorSet(sensorImage,'exposure method', 'burst');
                    
                    %obj.ip = ipSet(obj.ip, 'render demosaic only', 'true');
                    obj.ip = ipSet(obj.ip, 'combination method', 'sum');
                    
                    % old ipBurstMotion  = ipCompute(ipBurstMotion,sensorBurstMotion);
                    obj.ip = ipCompute(obj.ip, sensorImage);
                    if obj.returnIP
                        ourPhoto = obj.ip;
                    else
                        ourPhoto = obj.ipToImage(obj.ip);
                    end
                case 'FocusStack'
                    % Doesn't stack yet. Needs to do that during merge!
                    sensorImage = obj.isp.mergeSensors(sensorImages);
                    sensorImage = sensorSet(sensorImage,'exposure method', 'burst');
                    
                    %obj.ip = ipSet(obj.ip, 'render demosaic only', 'true');
                    obj.ip = ipSet(obj.ip, 'combination method', 'sum');
                    
                    % old ipBurstMotion  = ipCompute(ipBurstMotion,sensorBurstMotion);
                    obj.ip = ipCompute(obj.ip, sensorImage);
                    if obj.returnIP
                        ourPhoto = obj.ip;
                    else
                        ourPhoto = obj.ipToImage(obj.ip);
                    end
                    
                otherwise
                    % This lower-leval routine is called once we have our sensor
                    % image(s), and generates a final image based on the intent
                    % Except this doesn't seem to deal with multiple
                    % images?
                    for ii=1:numel(sensorImages)
                        sensorWindow(sensorImages(ii));
                        ourPhoto = ipCompute(obj.ip, sensorImages(ii));
                        if obj.returnIP == false
                            ourPhoto = obj.ipToImage(ourPhoto);
                        end
                    end
            end
            
            
        end
        % take a sequence of frames that are in separate sensor objects
        % and combine them into a single struct for processing by ip.
        % Right now this is simple processing of voltages. Should also
        % look at demosaic first and other options
        function singleSensor = mergeSensors(obj, sensorArray)
            singleSensor = sensorArray(1);
            for ii = 2:numel(sensorArray)
                singleSensor = sensorSet(singleSensor, 'exposure time', ...
                    [sensorGet(singleSensor,'exposure time') sensorGet(sensorArray(ii), 'exposure time')]);
                singleSensor.data.volts(:,:,ii) = sensorArray(ii).data.volts;
            end
        end
       
        % Seems like there is probably a way to do this in the existing ip
        % code, but I couldn't find it.
        function anImage = ipToImage(obj, anIP)
            anImage = uint8(round(rescale(ipGet(anIP,'data srgb'), 0, 255)));
        end
        
        function [alignedImage] = registerRGBImages(obj, movingImage,baseImage)

            %  MOVING and FIXED using auto-generated code from the Registration
            %  Estimator app. The values for all registration parameters were set
            %  interactively in the app and result in the registered image stored in the
            %  structure array MOVINGREG.
            
            %merge = registerImages(rgb2gray(img2), rgb2gray(img1));
            %imshowpair(img2,(imwarp(img1, merge.Transformation)), 'diff');
            
            MOVING = rgb2gray(movingImage);
            FIXED = rgb2gray(baseImage);
            
            % Default spatial referencing objects
            fixedRefObj = imref2d(size(FIXED));
            movingRefObj = imref2d(size(MOVING));
            
            % Detect SURF features
            fixedPoints = detectSURFFeatures(FIXED,'MetricThreshold',750.000000,'NumOctaves',3,'NumScaleLevels',5);
            movingPoints = detectSURFFeatures(MOVING,'MetricThreshold',750.000000,'NumOctaves',3,'NumScaleLevels',5);
            
            % Extract features
            [fixedFeatures,fixedValidPoints] = extractFeatures(FIXED,fixedPoints,'Upright',false);
            [movingFeatures,movingValidPoints] = extractFeatures(MOVING,movingPoints,'Upright',false);
            
            % Match features
            indexPairs = matchFeatures(fixedFeatures,movingFeatures,'MatchThreshold',50.000000,'MaxRatio',0.500000);
            fixedMatchedPoints = fixedValidPoints(indexPairs(:,1));
            movingMatchedPoints = movingValidPoints(indexPairs(:,2));
            MOVINGREG.FixedMatchedFeatures = fixedMatchedPoints;
            MOVINGREG.MovingMatchedFeatures = movingMatchedPoints;
            
            % Apply transformation - Results may not be identical between runs because of the randomized nature of the algorithm
            try
                tform = estimateGeometricTransform(movingMatchedPoints,fixedMatchedPoints,'projective');
                MOVINGREG.Transformation = tform;
                MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform, 'OutputView', fixedRefObj, 'SmoothEdges', true);
                
                % Store spatial referencing object
                MOVINGREG.SpatialRefObj = fixedRefObj;
                
                alignedImage = imwarp(movingImage, movingRefObj, tform, 'OutputView', fixedRefObj, 'SmoothEdges', true);
            catch
                alignedImage = movingImage;
                warning("Unable to register new image, so just returning the un-registered image.");
            end
            if mean(alignedImage, 'all') == 0 % failed but doesn't give us an error
                alignedImage = movingImage;
                warning("Unable to register new image, so just returning the un-registered image.");
            end
        end
        
    end
end

