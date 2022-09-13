% tracking by detection process
% 27/06/2016

clear;

videoInPath = 'video_clip/1'; 
modelPath = 'pretrained_model/face_model.mat';
outputPath = ['output/' videoInPath]; mkdir(outputPath);
framesPath = [outputPath '/frames']; mkdir(framesPath);
shotsPath = [outputPath '/shots.mat'];
facedetPath = [outputPath '/faces.mat']; 
tracksPath = [outputPath '/tracks.mat']; % output1: a mat structure with the track no., face bounding box, frame no. etc. 
videoOutPath = [outputPath '/video_vis.avi']; % output2: a video showing all the face tracks 

framesPattern = '%08d.jpg';

ext = '.avi';    
video = [videoInPath ext];
tic
try 
    % extract frames
    manager.detection.extract_frames(video,framesPath,framesPattern);

    % detect shots 
    manager.detection.detect_shots_frames(framesPath,framesPattern,shotsPath);

    % detect faces
    manager.detection.detect_faces_frame(framesPath,framesPattern,modelPath,facedetPath);

    % track faces and smooth the returned face tracks
    manager.detection.track_faces_frame(framesPath,framesPattern,facedetPath,shotsPath,tracksPath);
    
    % visualise the face trackes by writing into a video 
    manager.detection.write_video_smooth(framesPath,framesPattern,tracksPath,videoOutPath);
    
catch
    [status,cmdout] = system('hostname');
    fp = fopen('errror.txt','a+');
    fprintf(fp,'%s %s\n',videoInPath,cmdout);
    fclose(fp);
end
toc;


