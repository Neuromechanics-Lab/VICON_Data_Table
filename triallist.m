classdef triallist < handle
    properties
        srcdir
        trials
    end
    methods
		function t = triallist(input)
			% constructor; switch on inputs.
			switch class(input)
				case "table"
					t.srcdir = [];
					t.trials = input;	
				case "char"
					t.srcdir = input;
					
					% find files in srcdir matching specification using python's
					% glob
					srcfiles = cellfun(@char,cell(py.glob.glob([input '*.xlsx']))','UniformOutput',false);
					
					% delete entries with the garbage character string ' ~$ '
					srcfiles(contains(srcfiles, '~$')) = [];
					
					% work with the following variables
					varnames = {
						'uniqueid'
						'obs'
						'redcapid'
						'viconid'
						'trialname'
						'trialnum'
						'pertdir_calc_round_deg'
						'sessionnum'
						'filename'
						'stepnum'
						};
					
					% create an empty table
					tbl_s = cell2table(cell(0,length(varnames)),'VariableNames',varnames);
					
					for f = srcfiles'
						tbl = readtable(char(f));
						tbl = tbl(:,varnames);
						tbl_s = [tbl_s; tbl];
					end
					
					tbl_s.uniqueid = categorical(tbl_s.uniqueid);
					tbl_s.redcapid = categorical(tbl_s.redcapid);
					tbl_s.viconid = categorical(tbl_s.viconid);
					
					t.trials = tbl_s;
			end
        end
        function renamedirectories(t,old,new,varargin)
            createSessionFolders = false
            if nargin>5
                if strcmpi(varargin{1},'createSessionFolders')
                    createSessionFolders = varargin{2}
                end
            end
            
            % replace the source directories
            t.trials.filename = strrep(t.trials.filename,old,new);
            
            % if the Session folders are absent in the new directories then
            % delete them.
            if ~createSessionFolders
                t.trials.filename = regexprep(t.trials.filename,['Session \d+' filesep],'');
            end
		end      
        function renamefiles(t,f,r)
            t.trials.filename = regexprep(t.trials.filename,f,r);
		end
        function out = createtrialdata(t,varargin)
			
			7+3
			% parse arguments
			p = inputParser;
			addOptional(p,'timerange',[-0.5 1]);
			parse(p,varargin{:});
			
			% extract parsed arguments
			timerange = p.Results.timerange;
			
			for f = t.trials.filename'
				disp(['Loading ' char(f)])
				td = t.loadtrialdatandmap(char(f))
			end
            
            % interpolate the trials onto a common timebase		
            dirsuff = {'_X' '_Y'};
            comvarnames = [addsuffix('COMPos',dirsuff) addsuffix('COMPosminusLVDT',dirsuff) addsuffix('COMVelo',dirsuff) addsuffix('COMAccel',dirsuff)];
            emgvarnames = replace({'EMG_MGAS-R' 'EMG_SOL-R' 'EMG_TA-R' 'EMG_MGAS-L' 'EMG_SOL-L' 'EMG_TA-L'},'-','_');
            copvarnames = addsuffix('COP',dirsuff);
            platvarnames = [addsuffix('LVDT',dirsuff) addsuffix('Velo',dirsuff) addsuffix('Accels',dirsuff)];
            addvarnames = {'platonset' 'platonset_orig' 'atime' 'mass'};
            
            % summarize variable names
            varnames = [comvarnames emgvarnames copvarnames platvarnames addvarnames]
            
            % create source and destination data scripts to be used in
            % "loadtrialdatandmap"
            destdata = varnames';
            sourcedata = {...
                'resample(COMPos(:,1),AnalogFrameRate,VideoFrameRate)'
                'resample(COMPos(:,2),AnalogFrameRate,VideoFrameRate)'
                'resample(COMPosminusLVDT(:,1),AnalogFrameRate,VideoFrameRate)'
                'resample(COMPosminusLVDT(:,2),AnalogFrameRate,VideoFrameRate)'
                'resample(COMVelo(:,1),AnalogFrameRate,VideoFrameRate)'
                'resample(COMVelo(:,2),AnalogFrameRate,VideoFrameRate)'
                'COMAccel(:,1)'
                'COMAccel(:,2)'
                'rawData.analog.emg(:,contains(EMGID,''EMG_MGAS-R''))'
                'rawData.analog.emg(:,contains(EMGID,''EMG_SOL-R''))'
                'rawData.analog.emg(:,contains(EMGID,''EMG_TA-R''))'
                'rawData.analog.emg(:,contains(EMGID,''EMG_MGAS-L''))'
                'rawData.analog.emg(:,contains(EMGID,''EMG_SOL-L''))'
                'rawData.analog.emg(:,contains(EMGID,''EMG_TA-L''))'
                'COP(:,1)'
                'COP(:,2)'
                'LVDT(:,1)'
                'LVDT(:,2)'
                'Velocity(:,1)'
                'Velocity(:,2)'
                'Accels(:,1)'
                'Accels(:,2)'
                'calculateperturbationonset(load(fname))'
                'platonset'
                'atime'
                'mass'
                };
            
            outputtable = cell2table(cell(0,length(varnames)));
            outputtable.Properties.VariableNames = varnames;
            
            % loop over trials
            for f = matchingtrials.filename'

				% print trial that is being loaded
				disp(['Loading ' char(f)])
				
                % load data from each trial and copy into appropriate
                % variables.
                % td = loadtrialdatandmap(t,f{1},sourcedata,destdata);
                td = loadtrialdatandmap(t,f{1});
                
                % interpolate the data for this trial to a common timebase
                
				% time step "dt"
% 				dt = (td.atime(2)-td.atime(1));
				dt = 1/1080;
% 				if dt ~= 9.2593e-04
% 					disp('enforcing 1080 Hz sample rate')
% 					dt = 9.2593e-04;
% 				end
				
                % common timebase for interpolation
				timebase_com = [min(timerange):dt:(max(timerange)-dt)];
								
				if isnan(td.platonset)||td.platonset>1
					atime = td.atime - 0.528;
					disp('using estimate of 528 ms for platform onset')
				else
					atime = td.atime - td.platonset;									
				end
				
				platonset = td.platonset;
				platonset_orig = td.platonset_orig;
                mass = td.mass;
				
                % interpolate the remaining variables for this trial to a
                % common timebase.
                % Create names:
                interpvarnames = deblank([comvarnames emgvarnames copvarnames platvarnames]);
                
                % Create variables:
                interpvarvals = cellfun(@(in) {interp1(atime,getfield(td,in),timebase_com)},interpvarnames);
                
                % concatenate this row to the output table.
                atime = timebase_com;
% 				try
                outputtable = [outputtable; [cell2table(interpvarvals,'VariableNames',interpvarnames) table(platonset,platonset_orig,atime,mass)]];
% 				catch
% 					7+3
% 				end
            end
            
            out = trialdata(t.srcdir,[matchingtrials outputtable]);
            out.signalnames = interpvarnames;
		end
        function td = loadtrialdatandmap(t,fname)
			
			% load data
            load(fname);
			
			
			
			% create a string casted version of the EMGID matrix
			EMGID = strtrim(string(EMGID));

			% load EMG
			td.EMG_MGAS_R = rawData.analog.emg(:,contains(EMGID,'EMG_MGAS-R'));
			td.EMG_SOL_R = rawData.analog.emg(:,contains(EMGID,'EMG_SOL-R'));
			td.EMG_TA_R = rawData.analog.emg(:,contains(EMGID,'EMG_TA-R'));
			td.EMG_MGAS_L = rawData.analog.emg(:,contains(EMGID,'EMG_MGAS-L'));
			td.EMG_SOL_L = rawData.analog.emg(:,contains(EMGID,'EMG_SOL-L'));
			td.EMG_TA_L = rawData.analog.emg(:,contains(EMGID,'EMG_TA-L'));
			
			% recalculate platform onset
			platonset_orig = nan;
			try
				platonset_orig = platonset;
			catch
			end
			platonset = nan;
			
			A = (Accels(:,1).^2 + Accels(:,2).^2).^0.5;
			bkgdmn = nanmean(A(atime<0.25));
			accelmag = abs(A(:)-bkgdmn);
			bkgdmn = nanmean(accelmag(atime<0.25));
			onsetind = find(accelmag>bkgdmn+0.016,1,'first');
			onsetind = onsetind - 15;
			platonset = atime(onsetind);
			if isempty(platonset) platonset=nan; end;
			
			
			
			% check lengths of signals
			7+3
	
			
            % copy the data out of the source file into the output
            % structure			
			td.COMPos_X = resample(COMPos(:,1),AnalogFrameRate,VideoFrameRate);
			td.COMPos_Y = resample(COMPos(:,2),AnalogFrameRate,VideoFrameRate);
			td.COMPosminusLVDT_X = resample(COMPosminusLVDT(:,1),AnalogFrameRate,VideoFrameRate);
			td.COMPosminusLVDT_Y = resample(COMPosminusLVDT(:,2),AnalogFrameRate,VideoFrameRate);
			td.COMVelo_X = resample(COMVelo(:,1),AnalogFrameRate,VideoFrameRate);
			td.COMVelo_Y = resample(COMVelo(:,2),AnalogFrameRate,VideoFrameRate);
			td.COMAccel_X = COMAccel(:,1);
			td.COMAccel_Y = COMAccel(:,2);
			td.COP_X = COP(:,1);
			td.COP_Y = COP(:,2);
			td.LVDT_X = LVDT(:,1);
			td.LVDT_Y = LVDT(:,2);
			td.Velo_X = Velocity(:,1);
			td.Velo_Y = Velocity(:,2);
			td.Accels_X = Accels(:,1);
			td.Accels_Y = Accels(:,2);						
			td.platonset = platonset;
			td.platonset_orig = platonset_orig;
			td.atime = atime;
			td.mass = mass;
			
        end        
        function out = assembleindex(t,varargin)
            ind = true(height(t.trials),1);
            for v = reshape(varargin,2,length(varargin)/2)
                d = t.trials{:,v{1}}';
                set = v{2};
                ind = ind & ismember(d,set)';
			end
            out = ind;
        end
    end
end
