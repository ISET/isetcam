%% Rotate a scene
%
% Illustrate the *sceneRotate* function.  We rotate a scene of a
% star pattern, extract the luminance image, and show it as a
% sequence of frames.
%
% Copyright Imageval, LLC, 2014

%%
ieInit

%% Simple star pattern scene

scene  = sceneCreate('star pattern');
fps = 30; % Frames per second
rate = 1; % Degrees per frame
nFrames = 50; % Enough frames to feel good

%% Make a movie of the pattern rotating

vcNewGraphWin;
for ii = 1:nFrames
    % waitbar(ii/nFrames,w,sprintf('Scene %i',ii));

    % Rotation is shrinking the image.  Figure out why.
    deg = ii * rate;
    s = sceneRotate(scene, deg);

    % You could just look at the scene
    % ieAddObject(s); sceneWindow;

    % But instead I made a movie of the scene luminance
    imagesc(sceneGet(s, 'luminance'));
    colormap(gray);
    pause(1/fps);

end

%%