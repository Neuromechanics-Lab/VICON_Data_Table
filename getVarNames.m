function varNames = getVarNames()
% variable names from single trial mat files to be stored in data table
varNames = {...
	'pertdir_calc_deg' 'pertdir_calc_round_deg' 'pertdisp_calc_cm' 'pertvel_calc_cm_s' 'pertacc_calc_g' 'condition'...
	'AnalogFrameRate' 'DigitalFrameRate' 'VideoFrameRate' 'atime' 'mtime' 'mass' 'platonset'...
	'EMG_MGAS_R' 'EMG_SOL_R' 'EMG_TA_R' 'EMG_MGAS_L' 'EMG_SOL_L' 'EMG_TA_L'...
	'EMG_MGAS_R_raw' 'EMG_SOL_R_raw' 'EMG_TA_R_raw' 'EMG_MGAS_L_raw' 'EMG_SOL_L_raw' 'EMG_TA_L_raw'...
    'EMG_BFLH_R' 'EMG_VMED_R' 'EMG_RF_R' 'EMG_BFLH_L' 'EMG_VMED_L' 'EMG_RF_L'...
	'EMG_BFLH_R_raw' 'EMG_VMED_R_raw' 'EMG_RF_R_raw' 'EMG_BFLH_L_raw' 'EMG_VMED_L_raw' 'EMG_RF_L_raw'...
	'Left_Fx' 'Left_Fy' 'Left_Fz' 'Left_Mx' 'Left_My' 'Left_Mz' 'Right_Fx' 'Right_Fy' 'Right_Fz' 'Right_Mx' 'Right_My' 'Right_Mz'...
	'LVDT_X' 'LVDT_Y' 'Velocity_X' 'Velocity_Y' 'Accels_X' 'Accels_Y'...
	'COMPos_X' 'COMPos_Y' 'COMPosminusLVDT_X' 'COMPosminusLVDT_Y' 'COMVelo_X' 'COMVelo_Y' 'COMAccel_X' 'COMAccel_Y' 'COP_X' 'COP_Y'...
    'Hip_a_R' 'Hip_a_L' 'Knee_a_R' 'Knee_a_L' 'Ankle_a_R' 'Ankle_a_L'...
    'Hip_a2_R' 'Hip_a2_L' 'Knee_a2_R' 'Knee_a2_L' 'Ankle_a2_R' 'Ankle_a2_L'...
    'Hip_m_R' 'Hip_m_L' 'Knee_m_R' 'Knee_m_L' 'Ankle_m_R' 'Ankle_m_L' 'FT' ...
    'LHEE_Y' 'RHEE_Y' 'LHEE_Z' 'RHEE_Z'};

end