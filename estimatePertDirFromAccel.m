function estimatedPertDir = estimatePertDirFromAccel(varargin)
% function estimatedPertDir = estimatePertDirFromAccel(varargin)
% estimates platform direction from initial platform acceleration

p = inputParser;
addOptional(p,'srcFile',[]);
addOptional(p,'dataTable',[]);
parse(p,varargin{:});

if ~isempty(p.Results.srcFile)
	srcFile = p.Results.srcFile;
	load(srcFile);
end

if ~isempty(p.Results.dataTable)
	dataTable = p.Results.dataTable;
end

atime = dataTable.atime(1,:);

Accels_X = dataTable.Accels_X;
Accels_Y = dataTable.Accels_Y;

Accels_X = Accels_X - nanmean(Accels_X(:,atime<0),2);
Accels_Y = Accels_Y - nanmean(Accels_Y(:,atime<0),2);

[Accels_Rad,Accels_R] = cart2pol(Accels_X,Accels_Y);
Accels_Deg = Accels_Rad * 180/pi;

% get rid of deceleration phase
Accels_Deg(:,atime>0.300) = [];
Accels_R(:,atime>0.300) = [];

figure
plot(Accels_R')

[~,NDX] = max(Accels_R,[],2);
Accels_Dir = nan(size(NDX));
for i = 1:size(Accels_Deg,1)
	Accels_Dir(i) = Accels_Deg(i,NDX(i));
end
Accels_Dir = findnearestpertdir(Accels_Dir);

estimatedPertDir = Accels_Dir;

dataTable.pertdir_calc_round_deg-estimatedPertDir;

end