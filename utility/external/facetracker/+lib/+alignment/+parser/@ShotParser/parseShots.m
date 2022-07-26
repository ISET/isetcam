function shots = parseShots(obj,shotsFile)

shots = [];
[startFrame , endFrame] = textread(shotsFile,'%d %d\n');

for i=1:numel(startFrame)
   shots(i).startFrame = startFrame(i);
   shots(i).endFrame = endFrame(i);
   shots(i).description = '';
   shots(i).speakers = {};
   shots(i).isSceneStart = false;
   shots(i).scene = 0;
end
end