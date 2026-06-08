%% Defocus and distance
%
% Calculate is the displacement of the image plane required to produce a
% given defocus for lenses with different optical power.
%
% Remember the simple lens maker's formula
%
%    1/do + 1/di = 1/f
%
% In the code below
%
%   baseD is 1/f (base lens power)
%   deltaD is the change in power.
%   1/do is zero (do is infinite) and thus the term never appears
%
% We solve for the change in the image distance, di, to achieve a
% change in power.  We call the change in image distance the
% displacement.
%
% No matter the base lens power, to achieve a specific change in power
% we displace the image plane a specific fraction of the focal distance.
%
% Imageval Consulting, LLC, 2018

%% Set up the base focal length

baseD  = 50:100:350;    % Diopters (power) of the base lens
deltaD = 1:15;          % Difference in diopters from the base power

ieNewGraphWin;
set(gca,'yscale','log');
hold on
for ii=1:length(baseD)
    % Lens maker's formula
    displacement = (1/baseD(ii)) - ( 1 ./ (baseD(ii) + deltaD));
    semilogy(deltaD,displacement);
end
xlabel('\Delta Diopters')
ylabel('Displacement (m)');
grid on

C = cell(size(baseD));
for ii=1:numel(baseD)
    C{ii} = sprintf('%d D',baseD(ii));
end
legend(C,'Location','northwest')

%% For any baseD, the \Delta diopter is a fraction of the focal length

% Equal ratios of diopters (deltaD/baseD) correspond to equal
% ratio of displacement/focal length
baseD  = 50:50:300;    % Diopters of focal length
deltaD = baseD/10;     % Choose a fraction.  Doesn't matter.
displacement = (1 ./ baseD) - ( 1 ./ (baseD + deltaD));

% The image plane displacement divided by the focal length is a
% constant for all of the different lens powers.
fprintf('Ratio of displacement to focal length %f\n',displacement.*baseD);

%%
