function ax = iePlotSet(ax,varargin)
% After a plot is created, adjust parameters
%

varargin = ieParamFormat(varargin);

for ii=1:2:numel(varargin)
    switch(varargin{ii})
        case 'linewidth'
            lines = findall(ax, 'Type', 'Line');      % get all line objects in the axis
            set(lines, 'LineWidth', varargin{ii+1});  % set all to linewidth of 2 (change as needed)
        otherwise
            error('Unknown parameter %s',varargin{ii});
    end    
end

end
