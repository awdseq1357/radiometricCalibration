%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function loadDatabaseOfResponseFunction
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [brightness, invBrightness] = loadDatabaseOfResponseFunction(basePath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup
dorfFile = fullfile(basePath, 'cameraResponses', 'dorf', 'dorfCurves.txt');

%% Open the file
fileHandle = fopen(dorfFile, 'r');

dataPoints = cell(1, 201);
for i=1:201
    dataPoints{i} = loadCameraResponse(fileHandle);
end

fclose(fileHandle);

%% Get the irradiance axis and corresponding brightness values for each camera
irradiance = dataPoints{1}(:,1); % they're all the same
brightness = cell2mat(cellfun(@(x) x(:,2), dataPoints, 'UniformOutput', 0));

%% Downsample
% 100 data points instead of 1024
brightness = interp1(irradiance, brightness, linspace(0, 1, 100), 'spline');

% computing inverse response function
invBrightness = zeros(size(brightness));
for i=1:size(invBrightness, 2)
    invBrightness(:,i) = getInverseResponse(brightness(:,i), linspace(0, 1, 100));
end


%% Helper function: load single camera
function dataPoints = loadCameraResponse(fileHandle)

cameraName = fgetl(fileHandle); %#ok
graphType = fgetl(fileHandle); %#ok

dataPoints = zeros(1024, 2);

if isempty(strfind(fgetl(fileHandle), 'I')), error('Wrong format! Must be I'); end
tmpPoints = textscan(fileHandle, '%f', 1024);
dataPoints(:,1) = tmpPoints{1};

fgetl(fileHandle); % read the eof character

if isempty(strfind(fgetl(fileHandle), 'B')), error('Wrong format! Must be B'); end
tmpPoints = textscan(fileHandle, '%f', 1024);
dataPoints(:,2) = tmpPoints{1};

fgetl(fileHandle); % read the eof character