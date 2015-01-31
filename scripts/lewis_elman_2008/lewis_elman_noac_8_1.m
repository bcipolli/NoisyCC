if (~exist('net','var') || ~isfield(net.sets,'continue') || ~net.sets.continue)
    clear globals variables;
    addpath(genpath('code'));
    dbstop if error;
    %dbstop if warning;

    net.sets.continue = false;
end;

%%%%%%

if (~exist('tsteps','var')), tsteps = 35; end;
if (~exist('Sdur','var')), Sdur = 1; end;  %measure for 5 time-steps
if (~exist('Sdel','var')), Sdel = 5; end; %start measuring output right when it goes off

Idel = 1;
Idur = 5;%tsteps-Idel;

if (~net.sets.continue)
    net.sets.rseed = 290;

    %training parameters
    net.sets.niters          = 1000;
    net.sets.online          = false;
    net.sets.ncc             = 8;
    net.sets.cc_wt_lim       = 500*[-1 1];
    net.sets.W_LIM           = 500*[-1 1];
    net.sets.train_criterion = 0.5;
    net.sets.dataset         = 'symmetric_symmetric';
    net.sets.init_type       = 'lewis-elman';
    net.sets.train_mode      = 'resilient';

    %timing parameters
    net.sets.dt     = 0.01;
    net.sets.T_INIT = 5*net.sets.dt*[1 1];  %change
    net.sets.T_LIM  = net.sets.T_INIT;
    net.sets.tstart = 0;
    net.sets.tsteps = tsteps  ;%we'll add another hidden layer, so measure output at one step later
    net.sets.tstop  = net.sets.tsteps * net.sets.dt;
    net.sets.I_LIM  = net.sets.tstart+net.sets.dt*(Idel +[0 Idur]); %in terms of time, not steps
    net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(Sdel +[Sdur 0]);  % min & max time to consider error

    net.sets.D_INIT           = 1*[1 1];%*[1 1; 1 1]; %early lh&rh; late lh&rh
    net.sets.D_IH_INIT(1,:,:) = 1*[1 1; 1 1];             %lh;    early->late and late->early
    net.sets.D_IH_INIT(2,:,:) = net.sets.D_IH_INIT(1,:,:); %rh;    early->late and late->early
    net.sets.D_CC_INIT(1,:,:) = 1*[1 1; 1 1];             %early; l->r and r->l
    net.sets.D_CC_INIT(2,:,:) = 1*[1 1; 1 1]; %late;  l->r and r->l

    net.sets.eta_w           = 1.5E-1;    %learning rate (initial)
    net.sets.eta_w_min       = 4E-6;
    net.sets.lambda_w        = 1E-2;    % lambda*E to control kappa.
    net.sets.phi_w           = 0.25;      % multiplicative decrease to eta
    net.sets.alpha_w         = 0.10;       %momentum

    net.sets.w_decay         = 0;%.001;
    net.sets.grad_pow        = 3;

    net.sets.nhidden_per      = 40;% 15;
    net.sets.noise_init       = 0;%1;
    net.sets.noise_input      = 0;%001;
    %net.sets.axon_noise       = 1E-3;

    %net.sets.dirname          = fullfile(guru_getOutPath('cache'), guru_fileparts(which(mfilename), 'dir'));  % output directory
    
    if ~isfield(net.sets,'run'), net.sets.run = true; end;
end;

%
if net.sets.run
    r_train_and_analyze_many(net, 10); % run 25 network instances
    %[net,pats,data]          = r_train_one(net);
    %[data.an]                = r_analyze(net, pats, data);
end;
