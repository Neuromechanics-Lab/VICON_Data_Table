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
addOptional(p,'StudyCode',"YA");
p.KeepUnmatched = true;
parse(p,varargin{:});


% Initialize empty cell array to store selected folders
folderPaths = {};

% Allow user to select multiple participant folders manually
while true
    folderPath = uigetdir('X:\ting\ting-data\neuromechanics-lab\ProcessedMatlabData\', ...
                          'Select a participant folder (Cancel when done)');
    
    % If user cancels, exit the loop
    if folderPath == 0
        break;
    end
    
    % Store the selected folder path
    folderPaths{end+1} = folderPath;
end

% Convert cell array to directory structure
src = cellfun(@dir, folderPaths, 'UniformOutput', false);
src = vertcat(src{:}); % Combine into a single structure array
src = src([src.isdir]); % remove nonfolders
% Remove '.' and '..' as well as folders containing 'old', 'tmp', or 'temp' (case insensitive)
excludePattern = '(?i)(old|tmp|temp|delete|bad)'; % Case-insensitive regex pattern
src = src(~ismember({src.name}, {'.', '..'}) & cellfun(@isempty, regexpi({src.name}, excludePattern)));

for i = 1:length(src)    
    srcDir = [src(i).folder '\' src(i).name];
%     srcDir = [src(i).folder '\' src(i).name '\New Session'];
    saveFileName = interpolateRecordedData(srcDir, src(i).folder, varargin{:});
%     plotRecordedData('srcFile',saveFileName,'EMGYLim',p.Results.EMGYLim);
    close all
end

% rmpath('D:\Users\SBOEBIN\Documents\MATLAB\matlabUtilities-master')
end