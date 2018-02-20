function pic=getpfmraw(filename)

% getpfmraw.m 
% -----------
%
% function  pic=getpfmraw(filename)
%
% PURPOSE:
%         Reads gray scale PFM (raw) images.
%
% ARGUMENTS: 
%         filename: A string containing the name of the image file to be read.
%
% RETURNS:
%         pic: The gray scale image in an array.

% http://www.cs.unc.edu/~adyilie/comp256/PA2/Source/MatLab/getpfmraw.m
% modified to load color .pfm's  -yzli@mit.edu, Dec 2004
  

%% Open file.
%
 filename(findstr(filename,' '))=[];
 fid=fopen(filename);


%% If not PGM then exit with an error message
%.
 code=fscanf(fid,'%s',1);
 if (code ~= 'P7')
	error('Not a PFM (raw) image');
 end


%% Get width.
%
 width=[];
 while (isempty(width))
   [width,cnt]=fscanf(fid,'%d',1);
   if (cnt==0)
     fgetl(fid);
   end
 end

%% Get height.
%
 height=fscanf(fid,'%d',1);

%% Get max gray value.
%
 maxgray=fscanf(fid,'%f',1);


%% Read actual data.
%
 cnt = fread(fid,1);		% newline
 pic = fread(fid,'float')';
 pic = reshape(pic,3,width*height);
 pic_r = reshape(pic(1,:),width,height)';
 pic_g = reshape(pic(2,:),width,height)';
 pic_b = reshape(pic(3,:),width,height)';
 clear pic
 pic(:,:,1) = pic_r;
 pic(:,:,2) = pic_g;
 pic(:,:,3) = pic_b;
 
%% Close file.
%
 fclose(fid);

 
pic = pic(height:-1:1,:,:);

%%%%

