% TODO: write proper matlab-format comment
% entropy_file - measure the entropy of the specified file.

function hx = entropy_file( filename )

%%%%%%%%%%%%%%%%%%%%%%%%
% Make a histogram of all the bytes in the file
fid = fopen( filename, 'rb' );
hcall = zeros( size(0:255) );

while (~ feof(fid) )
    c = fread(fid, 8192); % read a small section of the file
    hc = hist(c, 0:255 ); % take the histogram of it.
    hcall = hcall + hc; % combine it with the rest of the file
end
fclose(fid);

hcall = double(hcall);

% Compute the probability distribution of each byte
px = hcall ./ sum(hcall(:));

% Compute the entropy
% TODO: figure out how to get rid of the Log of 0 warnings.
log2px = log2(px);
log2px(find((isnan(log2px) + isinf(log2px))) ) = 0;
hx = - sum( px .* log2px );