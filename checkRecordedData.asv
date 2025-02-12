function checkRecordedData(varargin)
% This function calls interpolateRecordedData.m and plotRecordedData.m 
% for each subject 
% addpath('X:\ting\shared_ting\Scott\matlabUtilities-master')
set(0,'DefaultAxesNextPlot','add')
set(0,'DefaultFigureColor',[1 1 1])
set(0,'DefaultFigureClipping','off')
set(0,'defaulttextinterpreter','none')

%Parser Arguments - change these (or change the input to the function)
p = inputParser;
addOptional(p,'EMGYLim',[0 3]);
addOptional(p,'LVDTPROBLEM',0);
addOptional(p,'reintegrateCoM',0);
addOptional(p,'StudyCode',"YA");
p.KeepUnmatched = true;
parse(p,varargin{:});

% use src to specify the folder path that contains processed MATLAB data output from VICON  
src_path = uigetdir('X:\ting\ting-data\neuromechanics-lab\ProcessedMatlabData\'); 
src = dir(src_path);
% Keep only folders that contain the study code
src = src([src.isdir]);
src = src(contains({src.name}, p.Results.StudyCode)); 

for i = 1:length(src)    
    srcDir = [src(i).folder '\' src(i).name];
%     srcDir = [src(i).folder '\' src(i).name '\New Session'];
    saveFileName = interpolateRecordedData(srcDir, src(i).folder, varargin{:});
    plotRecordedData('srcFile',saveFileName,'EMGYLim',p.Results.EMGYLim);
    close all
end

% rmpath('D:\Users\SBOEBIN\Documents\MATLAB\matlabUtilities-master')
end