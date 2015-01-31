clear globals variables;
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
dbstop if error;

tsteps = 50;
Idel = 1;
Idur = tsteps-Idel;
Sdel = 0; %start measuring output right when it goes off
Sdur = 1;  %measure for 5 time-steps

net.sets.rseed = 289;

%training parameters
net.sets.niters          = 1000; %training iterations
net.sets.online          = false;
net.sets.ncc             = 3;
net.sets.cc_wt_lim       = inf*[-1 1];
net.sets.W_LIM           = inf*[-1 1];
net.sets.train_criterion = 0.5;
net.sets.dataset         = 'prediction';
net.sets.init_type       = 'prediction';
net.sets.train_mode      = 'resilient';

%timing parameters
net.sets.dt     = 0.01;
net.sets.T_INIT = 5*net.sets.dt.*[1 1];  %change
net.sets.T_LIM  = net.sets.T_INIT;
net.sets.tstart = 0;
net.sets.tsteps = tsteps  ;%we'll add another hidden layer, so measure output at one step later
net.sets.tstop  = net.sets.tsteps * net.sets.dt;
net.sets.I_LIM  = net.sets.tstart+net.sets.dt*(Idel +[0 Idur]); %in terms of time, not steps
net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(Sdel +[Sdur 0]);  % min & max time to consider error

net.sets.D_INIT           = 1*[1 1];%*[1 1; 1 1]; %early lh&rh; late lh&rh
net.sets.D_IH_INIT(1,:,:) = 1*[1 1; 1 1];             %lh;    early->late and late->early
net.sets.D_IH_INIT(2,:,:) = net.sets.D_IH_INIT(1,:,:); %rh;    early->late and late->early
net.sets.D_CC_INIT(1,:,:) = 10*[1 1; 1 1];             %early; l->r and r->l
net.sets.D_CC_INIT(2,:,:) = net.sets.D_CC_INIT(1,:,:); %late;  l->r and r->l

net.sets.eta_w           = 1E-3;    %learning rate (initial)
net.sets.eta_w_min       = 0;
net.sets.lambda_w        = 2E-2;    % lambda*E to control kappa.
net.sets.phi_w           = 0.25;      % multiplicative decrease to eta
net.sets.alpha_w         = 0.25;       %momentum

net.sets.grad_pow        = 3;

net.sets.nhidden_per      = 15;%

net.sets.axon_noise       = 2E-3;  % 2E-3 on delay=10 will give 1% average noise
net.sets.activity_dependent = true;  % if there is noise, make it activity-dependent
net.sets.noise_init       = 0;
net.sets.noise_input      = 1E-6;  % Noisy input

net.sets.dirname          = fullfile(guru_getOutPath('cache'), guru_fileparts(which(mfilename), 'dir'))  % output directory

net.sets.niters = 2000;
net.sets.axon_noise = 0;
net.sets.dirname    = fullfile(net.sets.dirname, mfilename);

r_train_and_analyze_many(net, 25); % run 25 network instances


