classdef ciBurstIP < ciIP
    %CIBURSTIP Burst-supporting version of ciIP Wrapper for ip to support computational cameras
    %
    % History:
    %   Initial Version: D. Cardinal, 01/2021
    
    properties
        % sub-class properties here
        useRaw = false; %merge in RGB space by default
    end
    
    methods
        function obj = ciBurstIP(userIP)
            %CIBURSTIP Construct an instance of this class
            %   create a programmable ip
            if ~exist('userIP', 'var'); userIP = []; end
            obj = obj@ciIP(userIP);
        end
        
        function aPicture = compute(sensorImages)
            %Compute final image from sensor captures
            aPicture = compute@ciIP(sensorImages);
        end
        
        function ourPhoto = ispCompute(obj, sensorImages, intent)
            switch intent
                case 'HDR'
                    % decide if we want to let the ip combine raw data, or
                    % demosaic it first
                    if obj.useRaw
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
                            currentImage = ipGet(tmpIP,'result');
                            % we can convert to sRGB here, or after
                            % registration
                            %currentImage = lrgb2srgb(currentImage); %make useable
                            if ii > 1
                                imageFrames{ii} = uint8(round(rescale(...
                                    obj.registerRGBImages(currentImage, baseImage), 0, 255)));
                            else
                                imageFrames = {uint8(round(rescale(currentImage, 0, 255)))};
                                % maybe should try to pick the "middle
                                % image"?
                                baseImage = currentImage;
                            end
                        end
                        hdrImage = makehdr(imageFrames, 'RelativeExposure', frameExposures./min(frameExposures));
                        finalImage = tonemap(hdrImage);
                        ourPhoto = ipSet(tmpIP,'result', finalImage);
                        
                    end
                case 'Burst'
                    % baseline is just sum the voltages, without alignment
                    sensorImage = obj.mergeSensors(sensorImages);
                    sensorImage = sensorSet(sensorImage,'exposure method', 'burst');
                    
                    %obj.ip = ipSet(obj.ip, 'render demosaic only', 'true');
                    obj.ip = ipSet(obj.ip, 'combination method', 'sum');
                    
                    % old ipBurstMotion  = ipCompute(ipBurstMotion,sensorBurstMotion);
                    obj.ip = ipCompute(obj.ip, sensorImage);
                    ourPhoto = obj.ip;
                case 'FocusStack'
                    % Doesn't stack yet. Needs to do that during merge!
                    sensorImage = obj.isp.mergeSensors(sensorImages);
                    sensorImage = sensorSet(sensorImage,'exposure method', 'burst');
                    
                    %obj.ip = ipSet(obj.ip, 'render demosaic only', 'true');
                    obj.ip = ipSet(obj.ip, 'combination method', 'sum');
                    
                    % old ipBurstMotion  = ipCompute(ipBurstMotion,sensorBurstMotion);
                    obj.ip = ipCompute(obj.ip, sensorImage);
                    ourPhoto = obj.ip;
                    
                otherwise
                    % This lower-leval routine is called once we have our sensor
                    % image(s), and generates a final image based on the intent
                    % Except this doesn't seem to deal with multiple
                    % images?
                    for ii=1:numel(sensorImages)
                        sensorWindow(sensorImages(ii));
                        ourPhoto = ipCompute(obj.ip, sensorImages(ii));
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
                alignedImage = baseImage;
                warning("Unable to register new image, so just returning the base image.");
            end
            if mean(alignedImage, 'all') == 0 % failed but doesn't give us an error
                alignedImage = baseImage;
                warning("Unable to register new image, so just returning the base image.");
            end
        end
        
    end
end

