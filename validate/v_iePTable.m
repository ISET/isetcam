%% Validate iePTable
%

%%
ieInit;

scene  = sceneCreate;
camera = cameraCreate;
camera = cameraCompute(camera,scene);

%% Try various calls

iePTable(scene);

%%
iePTable(cameraGet(camera,'oi'));


%%
iePTable(cameraGet(camera,'sensor'));

%%
iePTable(camera);

%% Clear out img proc

c = cameraSet(camera,'ip',[]);
iePTable(c);

%% Clear out oi

c = cameraSet(camera,'oi',[]);
iePTable(c);

%% Clear out sensor

c = cameraSet(camera,'sensor',[]);
iePTable(c);

%% Display

iePTable(displayCreate('LCD-Apple'));

%% END