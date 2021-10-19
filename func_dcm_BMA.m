function func_dcm_est(ROI_1,ROI_2)
display(['analyzing ' ROI_1 '_' ROI_2]);
addpath(genpath('/users/zli/Applications/spm12/'));
addpath(genpath('/users/zli/Batch/ID005/'));
data_dir = '/dcl02/lieber/zhili/Processing/ID005'; %change
subjects = importdata( '/users/zli/Batch/ID005/subjects');
condition = {'mce_c','mce_nc', 'me_c', 'me_nc', 'm_c', 'm_nc'};
folder_name = 'DCM'; %% change
BMA_dir = [data_dir '/DCM_BMA']; %%change
for cond_idx = 1:length(condition)
    if ~exist([BMA_dir '/' condition{cond_idx}], 'dir')
    	mkdir([BMA_dir '/' condition{cond_idx}]);
    end
end
GCM_dir = [data_dir '/DCM_GCM']; %%change
for cond_idx = 1:length(condition)
    if ~exist([GCM_dir '/' condition{cond_idx}], 'dir')
    	mkdir([GCM_dir '/' condition{cond_idx}]);
    end
end
%
tic
for cond_idx = 1:length(condition)
    for subj = 1:length(subjects)
        if exist([data_dir '/' folder_name '/' subjects{subj} '/' condition{cond_idx} '/' ROI_1 '_' ROI_2 ]) 
            subjects_remain{subj,1} = subjects{subj};
            GCM(subj,1:7) = {[data_dir '/' folder_name '/' subjects{subj} '/' condition{cond_idx} '/' ROI_1 '_' ROI_2 '/M1.mat'],...
                [data_dir '/' folder_name '/' subjects{subj} '/' condition{cond_idx} '/' ROI_1 '_' ROI_2 '/M2.mat'],...
                [data_dir '/' folder_name '/' subjects{subj} '/' condition{cond_idx} '/' ROI_1 '_' ROI_2 '/M3.mat'],...
                [data_dir '/' folder_name '/' subjects{subj} '/' condition{cond_idx} '/' ROI_1 '_' ROI_2 '/M4.mat'],...
                [data_dir '/' folder_name '/' subjects{subj} '/' condition{cond_idx} '/' ROI_1 '_' ROI_2 '/M5.mat'],...
                [data_dir '/' folder_name '/' subjects{subj} '/' condition{cond_idx} '/' ROI_1 '_' ROI_2 '/M6.mat'],...
                [data_dir '/' folder_name '/' subjects{subj} '/' condition{cond_idx} '/' ROI_1 '_' ROI_2 '/M7.mat']};
        end
    end
    subjects_remain(all(cellfun(@isempty,subjects_remain),2), : ) = [];
    GCM(all(cellfun(@isempty,GCM),2), : ) = [];
    GCM = spm_dcm_load(GCM);
    
    % Fully estimate model 1
    % To fasten the whole processing, we need to change the parpool
    % setting in 'spm_dcm_fit'. It will depends on the number of cores
    % we requisted during submitting this job.
    % GCM(:,1) = spm_dcm_fit(GCM(:,1));
    % Use Bayesian Model Reduction to rapidly estimated DCMs 2-N for
    % each subject if applicable. However, the figure cannot be initiated
    % in cluster. Hence the "Show results: Graphics" and following lines 
    % in spm function 'spm_dcm_bmr' needs to be commented.
    if size(GCM,2) > 1
        [GCM, BMC, BMA]= spm_dcm_bmr(GCM);
    end
    
    BMA_dir_idv = [BMA_dir '/' condition{cond_idx} '/' ROI_1 '_' ROI_2];
    if exist(BMA_dir_idv)
        rmdir(BMA_dir_idv, 's');
        mkdir(BMA_dir_idv);
    else
        mkdir(BMA_dir_idv);
    end
    GCM_dir_idv = [GCM_dir '/' condition{cond_idx} '/' ROI_1 '_' ROI_2];
    if exist(GCM_dir_idv)
        rmdir(GCM_dir_idv, 's');
        mkdir(GCM_dir_idv);
    else
        mkdir(GCM_dir_idv);
    end
    [BMA.subjects] = subjects_remain{:};
    save([BMA_dir_idv '/BMA.mat'], 'BMA');
    % save([GCM_dir_idv '/GCM.mat'], 'GCM', '-v7.3');
    clear BMA BMC GCM BMA_dir_idv GCM_dir_idv subjects_remain
end
display(['completed ' ROI_1 '_' ROI_2]);
toc
