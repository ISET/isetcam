%% Illustrate the impact of different displays

% [scene, I] = sceneFromFile(inputData, imageType, [meanLuminance], ...
%                     [display], [wave],[illEnergy],[scaleReflectance])

sceneOLED = sceneFromFile('FruitMCC_6500.png','rgb',100,'OLED-Samsung');

sceneOLED2 = sceneFromFile('FruitMCC_6500.png','rgb',100,'OLED-Sony');

sceneLCD = sceneFromFile('FruitMCC_6500.png','rgb',100,'LCD-Apple');

sceneCRT = sceneFromFile('FruitMCC_6500.png','rgb',100,'CRT-HP');

sceneWindow(sceneOLED);
sceneWindow(sceneOLED2);

sceneWindow(sceneLCD);
sceneWindow(sceneCRT);
