function munsellData = MunsellPreprocessTable
% munsellData = MunsellPreprocessTable
% 
% Load in Munsell renotation table from RIT site and convert it to the form where we will
% actually use it.
%
% See http://www.cis.rit.edu/mcsl/online/munsell.php to download the data file.  Our version
% downloaded 11/20/08 and renamed to RITAllMunsellData.txt.  This is the version that
% extraoplates outside of the physical gamut.
%
% The table provides values under CIE illuminant C.
%
% 11/21/08  dhb, ijk  Finished from ijk initial version.
% 11/25/08  dhb, ijk  Wrap table.

% Open file and throw away first line (column headers).  
fid = fopen('RITAllMunsellData.txt','r');
firstLine = fgetl(fid);

% Preallocate space.  We happen to know the number of records
% because we checked in advance.
nRecords = 4995;
munsellData = zeros(nRecords,6);

% Read lines one at a time and extract 
nRecordsCheck = 0;
for i = 1:nRecords
    theLine = fgetl(fid);
    theLineCell = textscan(theLine,'%s %f %f %f %f %f');
    H = theLineCell{1}{1};
    H1 = str2num(H(find((double(H) >= double('A')) == 0)));
    H2 = H(find((double(H) >= double('A')) == 1));
    angle = MunsellHueToAngle(H1,H2);
    value = theLineCell{2};
    chroma = theLineCell{3};
    x = theLineCell{4};
    y = theLineCell{5};
    Y = theLineCell{6};  
    munsellData(i,:) = [angle value chroma x y Y];
    nRecordsCheck = nRecordsCheck+1;
end

fclose(fid);

% Check that we weren't wrong about the number of records
if (nRecordsCheck ~= nRecords)
    error('Mismatch between specified and actual number of records in file.')
end

% Need to wrap table to include slightly negative angles, and angles just above
% 360 degrees, so that we don't have gamut problems in the interpolation.
tableNegativeAngles = munsellData;
tableNegativeAngles(:,1) = tableNegativeAngles(:,1)-360;
index1 = find(tableNegativeAngles(:,1) >= 5);

tableBigAngles = munsellData;
tableBigAngles(:,1) = tableBigAngles(:,1)+360;
index2 = find(tableNegativeAngles(:,1) <= 365);
munsellData = [munsellData ; tableNegativeAngles(index1,:) ; tableBigAngles(index2,:)];


