function [] = visualizeTrials(varargin)
% visualizeTrials.m
% JLM 2018 01 16

p = inputParser;
addOptional(p,'srcDir','');
addOptional(p,'staticTrialName','Stat01');
addOptional(p,'retroTrialName','Retro01');
addOptional(p,'trialNameFormat','Trial\d*.mat');
addOptional(p,'participantCodeFormat','PDF\d\d\d');
addOptional(p,'stepForceThresholdN',10);
addOptional(p,'timerange',[-0.5 1]);
parse(p,varargin{:});

if isempty(p.Results.srcDir)
	srcDir = uigetdir(pwd, 'Select Trial Directory');
else
	srcDir = p.Results.srcDir;
end

% consider only filenames matching the trial name
srcDirContents = struct2table(dir(srcDir));
srcDirContents(cellfun(@isempty,regexpi(srcDirContents.name,p.Results.trialNameFormat)),:)=[];

% isolate trial information
filename = join([string(srcDirContents.folder) string(srcDirContents.name)],string(filesep));
viconid = string(regexp(filename,p.Results.participantCodeFormat,'match'));
trialname = string(regexp(filename,p.Results.trialNameFormat,'match'));

% create a triallist object to hold the information
t = triallist(table(viconid,trialname,filename));
t.srcdir = srcDir;

% have the triallist object create a trialdata object
td = t.createtrialdata;

7+3

% calculate kinematic variables in perturbation frames; signals subscripted
% as "_1" are in perturbation direction, otherwise perpendicular
td.changeframes;

% calculate rectified EMG as in previous studies (omitting low-pass filter in the second step)
td.calculateprocessedemg({'EMG_MGAS_R' 'EMG_SOL_R' 'EMG_TA_R' 'EMG_MGAS_L' 'EMG_SOL_L' 'EMG_TA_L'});
td.calculateprocessedemg({'EMG_MGAS_R' 'EMG_SOL_R' 'EMG_TA_R' 'EMG_MGAS_L' 'EMG_SOL_L' 'EMG_TA_L'},'low_pass_Hz',false,'signamesuffix','_proc_unsmoothed');


7+3

% calculate perturbation direction
pertdir_calc_round_deg = []

% loop through and interpolate trial information

% flag trials for steps based on vertical force
p.Results.stepForceThresholdN


end
