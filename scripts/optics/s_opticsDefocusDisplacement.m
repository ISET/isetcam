%% Defocus and distance
%
% What is the displacement of the image plane required to produce a
% given defocus?
%
% Imageval Consulting, LLC, 2018

%% Set up the base focal length

baseD  = 50:100:350;    % Diopters of focal length
deltaD = 1:15;          % Difference from base

vcNewGraphWin;
set(gca,'yscale','log'); 
hold on
for ii=1:length(baseD)
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

% The displacement divided by the focal length is a constant
fprintf('Ratio of displacement to focal length %f\n',displacement.*baseD);

