function write_track(tracksPath,outfile)
 
    %277 0 1 126.26 18.45 0 466.96 466.96 0 0 0 0 0.00 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    load(tracksPath,'facedets');
    
    fp = fopen(outfile,'w+');
    
    for i=1:numel(facedets)
       
        fprintf(fp,'%d 0 %d %0.2f %0.2f 0 %0.2f %0.2f 0 0 0 0 0.00 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n',...
            facedets(i).frame,facedets(i).track,facedets(i).rect(1),facedets(i).rect(2),facedets(i).rect(3)-facedets(i).rect(1),facedets(i).rect(4)-facedets(i).rect(2));
        
    end
    fclose(fp);
end