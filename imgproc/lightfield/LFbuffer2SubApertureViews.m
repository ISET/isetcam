function image2dArray = LFbuffer2SubApertureViews(image4d)
    %Given a 4d image indexed M,N,v,u,c
    %where
    %MxN is size of each individual index
    %u,v are x,y index of each individual image
    %outputs a 2d array of smaller images
    [M,N,V,U,C] = size(image4d);
    image2dArray = zeros(M*V,N*U,C);
    for u = 1:U
        for v = 1:V
            image2dArray((v-1)*M+1:v*M,(u-1)*N+1:u*N,:) = squeeze(image4d(:,:,v,u,:));
        end
    end
    
end