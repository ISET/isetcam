function writeShotInfo(obj,outFile)
  
    fp = fopen(outFile,'w+');
    scenePattern  = '#######  Scene %d  #######\n';
    shotPattern = '******  Shot %d  ******\n\n';
    for i=1:numel(obj.shots)
        
       if(obj.shots(i).isSceneStart)
            fprintf(fp,scenePattern,obj.shots(i).scene);
       end
       
       fprintf(fp,shotPattern,i);
       fprintf(fp,'start frame:%08d  start frame:%08d\n\n',obj.shots(i).startFrame,obj.shots(i).endFrame);
       fprintf(fp,'Speakers:\n');
       obj.shots(i).speakers = unique(obj.shots(i).speakers);
       for j=1:numel(obj.shots(i).speakers)
           fprintf(fp,' %s , ',obj.shots(i).speakers{j});
       end
       fprintf(fp,'\n');
       fprintf(fp,'Description:%s\n',obj.shots(i).description);
       fprintf(fp,'\n\n');
       
    end
    fclose(fp);
end