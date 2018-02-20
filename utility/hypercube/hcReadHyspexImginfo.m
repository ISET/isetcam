function info = hcReadHyspexImginfo(filename)
%Read ENVI image header files
%
%   info = hcReadHyspexImginfo(filename)
% 
%   Reads the ENVI image header information to a struct in info. If
%   filename is not a headerfile with extension .hdr, the extension is
%   changed to .hdr the resulting file is assumed to exist.
%
%   Renamed for use in ISET-4.0.  Taken from read_ENVI_imginfo
%
%   See also:  hcReadHyspex
%
%   Author: trym.haavardsholm@ffi.no

[pathstr, name, ext] = fileparts(filename);

% Look for the version with the hdr information
if ~strcmp(ext,'.hdr')
    filename = fullfile(pathstr,[name '.hdr']);
end

% Read ENVI header file header.
if ~exist(filename,'file')
    error('No file %s found\n',filename);
else
    fid = fopen(filename);
    if ~strcmp(fgetl(fid),'ENVI')
        error([filename ' is not an ENVI header file!']);
    end
end

info = [];
i = 1;
line_num = 1;

% Read each variable.
while ~feof(fid)
    curr_line = fgetl(fid);
    line_num = line_num + 1;
    
    % It's simple if no brackets are used.
    if isempty(findstr(curr_line,'{'))
        match = regexp(curr_line,'(?<var>.+)\s*=\s*(?<val>.+)\>','names');
        
        if ~isempty(match)
            field = strrep(strtrim(match.var),' ','_');
            val = strtrim(match.val);
            
            numval = str2num(match.val);
            if ~isempty(numval)
                val = numval;
            end
    
            info.(field) = val;
        else
            warning(['Ignored line ' num2str(line_num)]);
        end
    % When brackets are used, we need to read each element, possibly on
    % several lines.
    else
        % Match variable name.
        match = regexp(curr_line,'(?<var>.+)\s*=\s*{(?<vals>.[^}]+)?\s*}?\s*','names');
        field = strrep(strtrim(match.var),' ','_');
        
        % Read all values.
        if isempty(match.vals)
            vals = {};
        else
            vals = {match.vals};
        end
        
        while isempty(findstr(curr_line,'}'))
            curr_line = fgetl(fid);
            line_num = line_num + 1;
            
            match = regexp(curr_line,'\s*(?<vals>.[^}]+)\s*}?\s*','names');
            vals = [vals match.vals];
        end

        % Extract each element.
        if ~strcmpi(field,'description')
            vals = [vals{:}];
            match = regexp(vals,'(?<val>[^,]+)','names');
            %match = [match{:}];
            vals = strtrim({match.val});
            
            num_vals = cell(size(vals));
            all_nums = 1;
            for j=1:length(vals)
                num_vals{j} = str2num(vals{j});
                
                if isempty(num_vals{j})
                    num_vals{j} = vals{j};
                    all_nums = 0;
                end
            end
                
            if all_nums
                vals = cell2mat(num_vals);
            end
        end
            
        info.(field) = vals;
    end
end

fclose(fid);

% Convert to Matlab.
fields = fieldnames(info);
    
if any(strcmpi(fields,'data_type'))
    switch info.data_type
        case 1
            info.data_type = 'uint8=>uint8';
        case 2
            info.data_type = 'int16';
        case 3
            info.data_type = 'int32';
        case 4
            info.data_type = 'float32=>float32';
        case 5
            info.data_type = 'float64';
        case 6
            info.data_type = 'float32'; 
            warning('Data type "2*32 bit complex" not supported by Matlab!');
        case 9
            info.data_type = 'float64'; 
            warning('Data type "2*64 bit complex" not supported by Matlab!');
        case 12
            info.data_type = 'uint16=>uint16';
        case 13
            info.data_type = 'uint32';
        case 14
            info.data_type = 'int64';
        case 15
            info.data_type = 'uint64';
        otherwise
            warning('Data type not supported!');
    end
end
        
if any(strcmpi(fields,'byte_order'))
    switch info.byte_order
        case 0
            info.byte_order = 'ieee-le';
        case 1
            info.byte_order = 'ieee-be';
        otherwise
            warning('Unknown byte order!');
    end
end