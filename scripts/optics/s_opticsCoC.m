%% The circle of confusion
%
% A large reason for image blur arises from simple geometry - the image
% point is not at the focal distance. Geometric blur is measured by the
% size of the *circle of confusion*, which is simply the diameter of a
% point image. The function *opticsCoC* calculates the circle of confusion.
%
% For a description of the
% <http://en.wikipedia.org/wiki/Circle_of_confusion#Determining_a_circle_of_confusion_diameter_from_the_object_field
% circle of confusion see this Wikipedia page>. That page links to
% the original wonderful article describing the geometry.
%
% See also:  opticsCoC, opticsSet, opticsget
%
% Copyright Imageval Consulting, LLC 2015

%%
ieInit

%% Calculate the circle of confusion diameter for different points

% Points distances
oDist = logspace(-1.5,0.3,20);

optics = opticsCreate;
optics = opticsSet(optics,'fnumber',2);
c = zeros(size(oDist));
for ii=1:length(oDist)
    c(ii) = opticsCoC(optics,oDist(ii),'um');
end

%% Plot the circle diameter as a function of distance
vcNewGraphWin([],'big'); 
semilogy(oDist,c,'b-'); grid on
% xlabel('Object distance (m)');
% ylabel('Diameter of circle of confusion (um)')

l = xlabel('Object distance (m)');                  %set(l,'Position',[0.5 0.6,-1]);
l = ylabel('Diameter of circle of confusion (um)'); % set(l,'Position',[-0.07 31.6,-1])

%% Change f-number, but not focal length, and recalculate
optics = opticsSet(optics,'fnumber',4);
c = zeros(size(oDist));
for ii=1:length(oDist)
    c(ii) = opticsCoC(optics,oDist(ii),'um');
end
hold on
semilogy(oDist,c,'g-'); grid on
% xlabel('Object distance (m)');
% ylabel('Diameter of circle of confusion (um)')

l = xlabel('Object distance (m)');                  % set(l,'Position',[0.5 0.7,-1]);
l = ylabel('Diameter of circle of confusion (um)'); % set(l,'Position',[-0.06 31.6,-1])


%% Change the f-number once more, keeping focal length fixed

optics = opticsSet(optics,'fnumber',8);
c = zeros(size(oDist));
for ii=1:length(oDist)
    c(ii) = opticsCoC(optics,oDist(ii),'um');
end

% Why aren't the axes default positions OK?
hold on
semilogy(oDist,c,'r-'); grid on
l = xlabel('Object distance (m)');                  % set(l,'Position',[0.5 0.7,-1]);
l = ylabel('Diameter of circle of confusion (um)'); % set(l,'Position',[-0.06 31.6,-1])

% In all cases
% flength = opticsGet(optics,'focal length','mm');
% title(sprintf('Focal length %.2f mm',flength));

legend({'f=2','f=4','f=8'})

%% 
