%function demoRadiometricCalibration
% Main demo function for the radiometric calibration project.
%
% ----------
% Jean-Francois Lalonde

%% Preliminaries

% Paths
imgPath = fullfile('data', 'test.bmp');
dbPath = fullfile('data', 'dorfCurves.txt');
gmmPath = fullfile('data', 'gmmModels_coeff.mat');

% Set edge detection parameters
patchSize = [20 20];
colorDiffThresh = 20/255;
varianceThresh = 10/255;
areaDiffThresh = 0.4;
minVarStraight = 2; % straight-ness of edges

% Optimization parameters
nbPCABases = 5;
lambdaPrior = 0.001;

% Read the image
img = im2double(imread(imgPath));

%% Extract the color triplets (this could take a while, depending on the parameters)
[colorTriplets, edgeCoords, colorDiffs, maxVariances, tripletToEdgeInd, edgeMap] = ...
    findColorTriplets(img, patchSize, colorDiffThresh, varianceThresh, areaDiffThresh, minVarStraight);

%% Prepare prior
% Load the database of response functions
[brightnessDb, invBrightnessDb] = loadDatabaseOfResponseFunction(dbPath);

% Load pre-computed GMM model
load(gmmPath);

% Run PCA
[pcaInvMean, pcaInvBases] = getPCAModelFromDatabaseOfResponseFunctions(invBrightnessDb, nbPCABases);

%% Optimize
invCamResponseEst = optimizeInvCameraResponse(gmmInvMix, pcaInvMean, pcaInvBases, ...
    colorTriplets, lambdaPrior);

%% Display
pHandle = figure(1);
set(pHandle, 'DefaultAxesColorOrder',[1 0 0;0 1 0;0 0 1])
r = invCamResponseEst(:,1);
g = invCamResponseEst(:,2);
b = invCamResponseEst(:,3);
for i = 1:100
    r(i) = r(i) * 255;
    g(i) = g(i) * 255;
    b(i) = b(i) * 255;
end
fir_axis = linspace(0,255,100);
red_fit = fit(r,fir_axis.','pchipinterp');
green_fit = fit(g,fir_axis.','pchipinterp');
blue_fit = fit(b,fir_axis.','pchipinterp');

x = (0:1:255).';
red_fitted_data = red_fit(x);
green_fitted_data = green_fit(x);
blue_fitted_data = blue_fit(x);

plot(linspace(0,1,100), invCamResponseEst, 'LineWidth', 3);
legend('R', 'G', 'B', 'Location', 'NorthWest');
title(sprintf('Estimated inverse response function'));
xlabel('Normalized intensity'), ylabel('Normalized irradiance');
axis([0 1 0 1]); grid on;

