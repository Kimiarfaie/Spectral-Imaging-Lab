clc
clear all
plateData = load('Plate02.mat');
WhiteData = load("White.mat");
DarkData = load("DarkCorrection.mat");
WhiteRef = load("WhiteRef.mat");

data = plateData.cube.DataCube;
white = WhiteData.cube.DataCube;

dark = DarkData.cube.DataCube;
ref = WhiteRef.Multi_90white;


%%
white_band = white(213:500,:,:);
white_band = mean(white_band, 1);
whiteDataCropped = repmat(white_band, [1295, 1, 1]);
darkDataExpanded = repmat(dark, [ceil(1295/size(dark, 1)), 1, 1]);
darkDataExpanded = darkDataExpanded(1:1295, :, :);  % Trim excess rows after repetition

% Later the correctedCube will have infinite values, so we are replacing
% the zero in whiteDataCropped - darkDataExpanded with the second min in
% that 


% Flat-field correction
dark_corrected = max(0, data - darkDataExpanded);
correctedCube =  dark_corrected./ (whiteDataCropped - darkDataExpanded);

[~, M] = size(ref);

corrected=zeros(1295,900,121);

for i=1:M
    temp = ones(1295,900)*ref(:,i);
    corrected(:,:,i)=correctedCube(:,:,i).*temp;
    RadianceIncident(:,:,i) = whiteDataExtended(:,:,i)./temp;
end

% Handle zeros in Radiance Incident
RadianceIncident = correctingzero(RadianceIncident); % To prevent getting Inf in the reflectance

% Calculate Reflectance
Reflectance = corrected./RadianceIncident;

mean(Reflectance,'all')
max(Reflectance,[],'all')
min(Reflectance,[],'all')

%%
function output = correctingzero(input)

tmp = input;
tmp(tmp==0) = Inf;
minvalue = min(tmp,[],"all");

output = input;     
output(output==0) = minvalue;
end








