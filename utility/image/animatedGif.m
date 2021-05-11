function fName = animatedGif(pImg, fName, deltaT, c_map)
% Save an animated gif from a 3D volume of gray scale images
%
% In the future, if we want to save RGB image sequences we need to apply
%
%    [M  c_map]= rgb2ind(RGB,256);  % If we have an rgb, do this
%
% to the RGB image before saving it in the gif, below
%
% Then we want a routine that averages over 50 temporal frames, sliding
% from the beginning to the end, no?
% tAve = 25;
% [r,c,t] = size(pImg);
% tmp = zeros(r,c,t-tAve);
% lst = 1:tAve;
% for ii=0:(nSamples - tAve - 1)
%     tmp(:,:,ii+1) = sum(pImg(:,:,lst + ii),3);
% end
% tmp = ieScale(tmp,0,1);
% tmp = 255*tmp;
% mplay(tmp);
%
% % Show it as a movie.  In this case the mosaic is held in fixed position
% % and the stimulus is shown moving over the mosaic.  So dark parts, say the
% % blue cones, are stable as the white stimulus moves around.
% pImg = ieScale(pImg,0,1);
% pImg = 255*pImg;
% mplay(pImg);
%
%
% See also:  ctToolbox/ctScripts/presentations/p_Microsoft2013XX
%
% BW,HJ PDCSOFT Team 2013

if ieNotDefined('pImg'), error('3D volume of data needed'); end
if ieNotDefined('fName'), fName = fullfile(pwd, 'tmp.gif'); end
if ieNotDefined('deltaT'), delay1 = 1;
    delay2 = 1;
end
if ieNotDefined('cmap'), c_map = gray(256); end

% Look forever
loops = 65535;

% % Default frame delays  - was 0.1
delay1 = deltaT;
delay2 = deltaT;

for ii = 1:size(pImg, 3)
    M = uint8(pImg(:, :, ii));
    if ii == 1
        imwrite(M, c_map, fName, 'gif', 'LoopCount', loops, 'DelayTime', delay1)
    end
    imwrite(M, c_map, fName, 'gif', 'WriteMode', 'append', 'DelayTime', delay2)
end

fprintf('Finished creating animated gif in file %s\n', fName);

%%