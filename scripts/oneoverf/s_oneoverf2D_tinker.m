x0 = imread('cameraman.tif');
sz = size(x0,1);
X0 = fft2(x0);
X0 = X0(1:sz/2, 1:sz/2);

[fx, fy] = meshgrid(0:sz/2-1);
f0 = sqrt(fx.^2+fy.^2);


% fo = fitoptions('Method','NonlinearLeastSquares',...
%                'Lower',[0,-1.8],...
%                'Upper',[Inf,-1.6],...
%                'StartPoint',[1 -1]);
% ft = fittype('a*(x+1).^b','options',fo);
% 
% m = fit(f(:), abs(X(:)), ft)
figure(1), clf
scatter(f0(:), abs(X0(:))); xlim([0 max(f0(:))/2]);
%hold on, plot(f(:), m(f(:)), '.')
set(gca, 'YScale', 'log');


% chop up
ntiles = 2;
n = sz / ntiles;
for row = 1:ntiles
    for col = 1:ntiles
       x1(:,:,row, col) = x0((1:n)+n*(row-1),(1:n)+n*(col-1));
    end
end

X1 = fft2(x1);
X1 = X1(1:n/2, 1:n/2, :, :);

[fx, fy] = meshgrid((0:n/2-1)*ntiles);
f1 = sqrt(fx.^2+fy.^2);

figure
plot(f0(:), abs(X0(:)), '.', f1, sum(abs(X1),[3 4]), 'g.', f1, abs(sum(X1,[3 4])),'r.'); 
set(gca, 'YScale', 'log', 'XScale', 'log');

% figure, tiledlayout(ntiles, ntiles, 'TileSpacing','tight');
% for row = 1:ntiles 
%     for col = 1:ntiles
%         nexttile(); 
%         imshow(y(:,:,row, col)); 
%     end
% end

