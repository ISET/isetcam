% Dead Leaves

n = 2^16;      % number of points in signal (large, since we will chop it up into small bits)
x = (1:n)/n;   % locations in, say, degrees visual angle
k = 64;        % number pf segments to split image into

nleaves = 5000;


im0 = zeros(n,1);
for ii = 1:nleaves
    x0 = rand();
    sz = randn*.001;
    inds = abs(x-x0)<sz;
    im0(inds) = rand;
end

% compute spectrum
f0 = 0:n-1;
F0 = fft(im0)/n*2;

% chop into segments and recompute
im1 = reshape(im0, n/k, k);
f1 = (0:n/k-1)*k;
F1 = fft(im1)/n*2;



figure(1), clf

subplot(211)
plot(x, im0)
set(gca, 'XTick', linspace(0,1,k+1), 'XGrid', 'on')
subplot(212)
plot(f0, abs(F0), f1, sum(abs(F1),2), f1, abs(sum(F1,2))); 
xlim([10 n/2]);
set(gca, 'XScale', 'log', 'YScale', 'log')
xlabel('Frequency')
ylabel('amplitude')
legend('Original image', 'Sum of amplitudes per segment', ...
    'Amplitude of average segment')
