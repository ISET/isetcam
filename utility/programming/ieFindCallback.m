function cb = ieFindCallback(V)
% Find out what the callback text is to a menu selection
%
%   cb = ieFindCallback([handle or menu label]);
%
% The input argument can be a handle to an ISET figure or menu item.
% The default value is the handle to the current figure.
%
% If a figure handle is passed, the selected figure is briefly turned
% yellow, and the user is prompted to select the menu item for which they
% want to get the callback text.
%
% This function temporarily modifies the callback to all the figure's
% menus, so if it crashes in execution, it will break the figure; it will
% need to be re-created.
%
% If a label text is provided, looks for a menu containing a
% case-insensitive match for that text, and returns the callback to the
% first such menu found.
%
% Returns the text in cb, and prints it out in the command window.
% If not control is found, returns an empty string without crashing.
%
% Examples:
%   V = ieSessionGet('sceneWindow');
%   cb = ieFindCallBack(V);
%
% Not working yet
% Copyright ImagEval Consultants, LLC, 2007.

disp('ieFindCallBack:  Not working')
return;

if ieNotDefined('V'), V = gcf; end

cb = '';

if ishandle(V)
    % handle to figure -- get child uimenus
    h = getChildUimenus(V);
    
    % record callbacks to each item
    cbList = get(h, 'Callback');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up a uiwait / uiresume dialog %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set figure yellow for highlighting
    %     figColor = get(V, 'Color');
    %     set(V, 'Color', 'y');
    %
    % put up a message
    % msg = 'Select the menu item whose callback you''d like.';
    % hmsg = mrMessage(msg);
    
    % temporarily set all callbacks to be uiresume
    for i = 1:length(h)
        if ~isempty(cbList{i}) % ignore submenus
            set(h(i), 'Callback', sprintf('SEL = %i; uiresume;',i));
        end
    end
    
    % Let the user pick the desired item
    uiwait;
    
    % find the selected menu and get that callback
    SEL = evalin('base', 'SEL');
    cb = cbList{SEL};
    
    % restore the menu callbacks / other settings
    for i=1:length(h), set(h(i), 'Callback', cbList{i}); end
    %     set(V, 'Color', figColor);
    close(hmsg);
    
    % report the callback in the command window:
    fprintf('Selected Menu Item: \n ');
    fprintf('Label: %s \n ', get(h(SEL), 'Label'));
    fprintf('Handle: %f \n Callback: %s\n', h(SEL), cb);
    
    % clean up the temp variable
    evalin('base', 'clear SEL');
    
else
    help(mfilename);
    error('Invalid argument format.')
end


return

% ------------------
function h = getChildUimenus(par)
% h = getChildUimenus(par);
% Find all uimenus that belong to a parent figure or uimenu,
% or a submenu of the parent, and return as a vector in h.
% ras, 11/05
h = findobj('Parent', par, 'Type', 'uimenu');
for i = h(:)'
    subh = getChildUimenus(i);
    h = [h; subh];
end

return

