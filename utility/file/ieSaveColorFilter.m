function fullFileName = ieSaveColorFilter(inData,fullFileName)
% Write color filter data from a sensor or a color filter structure
%
%   fullFileName = ieSaveColorFilter(inData,[fullFileName])
%
% Sensor case:
%   The inData may be a sensor.  Color filter information is attached to the
% sensor structure in several fields.  This routine extracts the relevant
% information (transmissivity, wavelength, names) and saves them in a
% standard file format.  The color filters can be read by the corresponding
% routine, ieReadColorFilter.
%
% Structure case:
%   Alternatively, the input data (inData) may be a structure with the
% relevant fields.  This is useful if you want to read an existing color
% filter file, edit a field or two, and then save it out again.
% 
% The structure for the color filter contains (minimally)
%  inData.wavelength;  % Vector of W wavelength samples
%  inData.data;        % Matrix of filters (W rows, N filter columns)
%  inData.filterNames; % Cell array of names; first letter is a color hint
%
% Optional
%  inData.comment;     % Optional
%  inData.yourFieldGoesHere - we save extra fields you include, but you
%    have to handle them separately at ieReadColorFilter time.
%
% About filters and sensors:
% Color filter information describes the fraction of light, at each
% wavelength, transmitted through the filter.  This fraction is the same
% whether we measure the light in units of photons or energy.  Filters
% differ from responsivity curves.  When specifying responsivity of a
% detector, we must include whether we measured the incident light with
% respect to photons or energy.
%
% See also: ieReadColorFilter(), sensorColorOrder(), sensorDetermineCFA()
%
% Example:
%     isa = sensorCreate;
%     ieSaveColorFilter(isa);
%
%     filterStruct = load(fullfile(isetRootPath,'data','sensor','colorfilters','NikonD100'));
%     filterStruct.filterNames{1} = 'r_Nikon';
%     filterStruct.filterNames{2} = 'g_Nikon';
%     filterStruct.filterNames{3} = 'b_Nikon';
%     ieSaveColorFilter(filterStruct,'deleteMeColorFilter');
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also: 

%%
if ieNotDefined('fullFileName'), fullFileName = vcSelectDataFile('sensor','w','mat'); end

%% Sensor and structure cases
if isfield(inData,'type') && strcmp(sensorGet(inData,'type'),'ISA')
    
    % Sensor case
    isa = inData;

    wavelength  = sensorGet(isa,'wavelength'); %#ok<*NASGU>
    data        = sensorGet(isa,'colorfilters');
    filterNames = sensorGet(isa,'filterNames');
    comment     = ieReadString('Sensor comment field');
    % if ieNotDefined('Units'), units = 'photons'; end

    save(fullFileName,'wavelength','data','comment','filterNames');

elseif isfield(inData,'data') && isfield(inData,'wavelength') && isfield(inData,'filterNames')
    
    % CFA and color filter case
    wavelength  = inData.wavelength;
    data        = inData.data;
    filterNames = inData.filterNames;
    if isfield(inData,'comment'), comment = inData.comment;
    else    comment = 'No comment';
    end
    save(fullFileName,'wavelength','data','comment','filterNames');

    % We now check for additional fields and save those as well.  The user
    % can insert these fields even though they are not stored as part of
    % the usual ISET format.
    fldNames = fieldnames(inData);
    % If there are field structures not in the default list, append them to
    % the data file.  The user may want them.
    for ii=1:length(fldNames)
        if ~strcmp(fldNames{ii},{'wavelength','data','comment','filterNames','units'})
            eval([fldNames{ii},' = inData.',fldNames{ii},';']);
            % Write the user-defined field to the file: 
            % save(fullFileName,'-append',inData.thisField)
            setStr = [fldNames{ii},'= inData.',fldNames{ii}];
            eval(setStr);
            saveStr = ['save(fullFileName,''-append'',''',fldNames{ii},''')'];
            eval(saveStr);
        end
    end
else
    error('Input data missing fields.  No file written.');
end

end
