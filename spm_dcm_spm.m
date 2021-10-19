function []=spm_dcm_spm(subject, data_dir, roi1_name, roi2_name, condition_idx, condition_name)
%% DCM Model Specification and Estimation
load(fullfile(data_dir,'glm_dcm',subject,'SPM.mat'));

% Load regions of interest
%--------------------------------------------------------------------------
load(fullfile(data_dir,'glm_dcm',subject,['VOI_' condition_name '_' roi1_name '_1.mat']),'xY');
DCM.xY(1) = xY;
load(fullfile(data_dir,'glm_dcm',subject,['VOI_' condition_name '_' roi2_name '_1.mat']),'xY');
DCM.xY(2) = xY;


DCM.n = length(DCM.xY);      % number of regions
DCM.v = length(DCM.xY(1).u); % number of time points

% Time series
%--------------------------------------------------------------------------
DCM.Y.dt  = SPM.xY.RT;
DCM.Y.X0  = DCM.xY(1).X0;
for i = 1:DCM.n
    DCM.Y.y(:,i)  = DCM.xY(i).u;
    DCM.Y.name{i} = DCM.xY(i).name;
end

DCM.Y.Q    = spm_Ce(ones(1,DCM.n)*DCM.v);
% Experimental inputs
%--------------------------------------------------------------------------
DCM.U.dt   =  SPM.Sess.U(condition_idx).dt;
DCM.U.name = [SPM.Sess.U(condition_idx).name];
DCM.U.u    = [SPM.Sess.U(condition_idx).u(33:end,1)];

% DCM parameters and options
%--------------------------------------------------------------------------
DCM.delays = repmat(SPM.xY.RT/2,DCM.n,1);
DCM.TE     = 0.03;

DCM.options.nonlinear  = 0;
DCM.options.two_state  = 0;
DCM.options.stochastic = 0; % converntional deterministic vs. stochastic DCMs
DCM.options.nograph    = 1;

dcm_model_dir = [ data_dir '/DCM/' subject '/' condition_name '/' roi1_name '_' roi2_name ];
if ~exist(dcm_model_dir)
    mkdir(dcm_model_dir);
end
dcmfolderinfo = dir(dcm_model_dir);
if length(dcmfolderinfo) ~= 2
    delete([dcm_model_dir '/*']);
end



% M1
DCM.a = [1 1 ; 1 1]; % intrinsic connections
DCM.b = [0 1; 1 0]; % effect of task modulations
DCM.c = [1 ; 1]; % inputs
DCM.d = zeros(DCM.n,DCM.n,0);
save(fullfile(dcm_model_dir,'M1.mat'),'DCM');

% M2
DCM.a = [1 1 ; 1 1];
DCM.b = [0 1; 0 0];
DCM.c = [1 ; 1];
DCM.d = zeros(DCM.n,DCM.n,0);
save(fullfile(dcm_model_dir,'M2.mat'),'DCM');

% M3
DCM.a = [1 1 ; 1 1];
DCM.b = [0 0; 1 0];
DCM.c = [1 ; 1];
DCM.d = zeros(DCM.n,DCM.n,0);
save(fullfile(dcm_model_dir,'M3.mat'),'DCM');

% M4
DCM.a = [1 1 ; 1 1];
DCM.b = [0 1; 1 0];
DCM.c = [1 ; 0];
DCM.d = zeros(DCM.n,DCM.n,0);
save(fullfile(dcm_model_dir,'M4.mat'),'DCM');

% M5
DCM.a = [1 1 ; 1 1];
DCM.b = [0 0; 1 0];
DCM.c = [1 ; 0];
DCM.d = zeros(DCM.n,DCM.n,0);
save(fullfile(dcm_model_dir,'M5.mat'),'DCM');

% M6
DCM.a = [1 1 ; 1 1];
DCM.b = [0 1; 1 0];
DCM.c = [0 ; 1];
DCM.d = zeros(DCM.n,DCM.n,0);
save(fullfile(dcm_model_dir,'M6.mat'),'DCM');

% M7
DCM.a = [1 1 ; 1 1];
DCM.b = [0 1; 0 0];
DCM.c = [0 ; 1];
DCM.d = zeros(DCM.n,DCM.n,0);
save(fullfile(dcm_model_dir,'M7.mat'),'DCM');

% DCM Estimation
%--------------------------------------------------------------------------
clear matlabbatch

matlabbatch{1}.spm.dcm.fmri.estimate.dcmmat = {...
    fullfile(dcm_model_dir,'M1.mat')};

spm_jobman('run',matlabbatch);
clear
