Face tracker

Authors: Qiong Cao, Omkar M. Parkhi, Mark Everingham, Josef Sivic, Andrew Zisserman 
Visual Geometry Group, University of Oxford
------------------------------------------------------------------------------------


1. Introduction
---------------
This package contains the MATLAB software for the face tracker. It was develped under Linux. 

The face tracker consists of four steps: frame extraction, shot boundary detection, face detection, face tracking and its postprocessing. 
 
2. Installation
---------------
The software requires libraries for obtaining frames from videos. We use the following library:
* ffmpeg (available from https://ffmpeg.org)

3. Pretrained Models
--------------------
The folder, pretrained_model, includes the following model which are used during face tracking:
* face_model.mat: cascade face detection model
 
4. Quick start
--------------
* Run the demo script, process_demo.m, which performs the following functions:
(1) extract_frames.m: 
extract all the frames using ffmpeg   
(2) detect_shots_frames.m: 
detect shot boundary by color thresholding (skip this step if you have the shot boundaries)
(3) detect_faces_frame.m: 
detect faces using the cascade DPM face detector
(4) track_faces_frame.m: 
track faces by the KLT tracker and postprocess the returned face tracks by interploation techniques 
(5) write_video_smooth.m:
write the video showing all the faces that are tracked
 
* Input and output for each of the above functions
Input
-----
(ai) video clips: we use samples from the IJB-A dataset
(bi) extracted frames by (1) with correct aspect ratio
(ci) extracted frames by (1) and the pretrained face detection model (i.e. face_model.mat)
(di) extracted frames by (1), shot boundary returned by (2) and face detection returned by (3)
(ei) extracted frames by (1) and face tracks returned by (4)
Output
------
(ao) frames in .jpg format
(bo) shots.mat: shot boundaries with startFrame and endFrame numbers 
(co) faces.mat: a struct array with fields including frame number, face bounding box etc. 
(do) tracks.mat: a struct array with fields including track number, shot number, track length, frame number, face bounding box etc.
(eo) video_vis.avi: an avi video showing all the face tracks.  

5. References
-------------
[1] M. Everingham, J. Sivic, A. Zisserman
Taking the bite out of automated naming of characters in TV videos
Image and Vision Computing, Volume 27, Number 5, 2009

[2] A. Klaser, M. Marszalek, C. Schmid, A. Zisserman
Human focused action localization in videos
International Workshop on Sign, Gesture, Activity, 2010

[3] B. F. Klare, B. Klein, E. Taborsky, A. Blanton, J. Cheney, K. Allen, P. Grother, A. Mah, A. K. Jain
Pushing the Frontiers of Unconstrained Face Detection and Recognition: IARPA Janus Benchmark A
IEEE Conference on Computer Vision and Pattern Recognition, 2015
