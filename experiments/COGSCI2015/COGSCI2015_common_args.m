function net = COGSCI2015_common_args(varargin)
%function net = COGSCI2015_common_args(varargin)
%
% tsteps: # of time steps for simulation to run
% Idel: delay (from start) to turn on input
% Idur: duration (# time steps, after onset @ Idel) to keep input on
% Sdel: delay (reverse, from end) to measure error
% Sdur: duration (# time steps, reverse from Sdel) to measure the error.
    close all;  % Hack place to put it, but tired of saving all sorts of crazy figures!
    addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
    dbstop if error;

    net.sets = struct(varargin{:});
    if ~isfield(net.sets, 'tsteps') || isempty(net.sets.tsteps), net.sets.tsteps = 30; end;
    if ~isfield(net.sets, 'Idel')   || isempty(net.sets.Idel),   net.sets.Idel   = 1; end;
    if ~isfield(net.sets, 'Idur')   || isempty(net.sets.Idur),   net.sets.Idur   = 6; end;
    if ~isfield(net.sets, 'Sdel')   || isempty(net.sets.Sdel),   net.sets.Sdel   = 0; end;
    if ~isfield(net.sets, 'Sdur')   || isempty(net.sets.Sdur),   net.sets.Sdur   = 5; end;

    net.sets.rseed = 289;

    net.fn.analyze_one = @COGSCI2015_analyze_one;
    net.fn.analyze_all = @COGSCI2015_analyze_all;
    net.fn.plot_one = @COGSCI2015_plot_one;
    net.fn.ploe_all = @COGSCI2015_plot_all;

    %training parameters
    net.sets.niters          = 1000; %training iterations
    net.sets.online          = false;
    net.sets.nhidden_per      = 10;%
    net.sets.ncc             = 3;
    net.sets.cc_wt_lim       = inf*[-1 1];  %% 2?
    net.sets.W_LIM           = inf*[-1 1];  %% 2?
    net.sets.train_criterion = 0.5;
    net.sets.init_type       = 'lewis_elman';
    net.sets.train_mode      = 'resilient_batch';

    %timing parameters
    net.sets.dt     = 0.01;
    net.sets.T_INIT = 5*net.sets.dt.*[1 1];  %change
    net.sets.T_LIM  = net.sets.T_INIT;
    net.sets.tstart = 0;
    net.sets.tstop  = net.sets.tsteps * net.sets.dt;
    net.sets.I_LIM  = net.sets.tstart+net.sets.dt*(net.sets.Idel +[0 net.sets.Idur]); %in terms of time, not steps
    net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(net.sets.Sdel +[net.sets.Sdur 0]);  % min & max time to consider error

    net.sets.D_INIT           = 1*[1 1];%*[1 1; 1 1]; %early lh&rh; late lh&rh
    net.sets.D_IH_INIT(1,:,:) = 1*[1 1; 1 1];             %lh;    early->late and late->early
    net.sets.D_IH_INIT(2,:,:) = net.sets.D_IH_INIT(1,:,:); %rh;    early->late and late->early
    net.sets.D_CC_INIT(1,:,:) = 10*[1 1; 1 1];             %early; l->r and r->l
    net.sets.D_CC_INIT(2,:,:) = net.sets.D_CC_INIT(1,:,:); %late;  l->r and r->l

    net.sets.eta_w           = 1E-2;    %learning rate (initial)
    net.sets.eta_w_min       = 4E-6;
    net.sets.lambda_w        = 1E-3;    % lambda*E to control kappa.
    net.sets.phi_w           = 0.5;     % multiplicative decrease to eta
    net.sets.alpha_w         = 0.1;    %% momentum
    net.sets.grad_pow        = 3;

    % Noise
    net.sets.axon_noise       = 0.02;  % 2% average noise
    net.sets.activity_dependent = true;  % if there is noise, make it activity-dependent
    net.sets.noise_init       = 0;
    net.sets.noise_input      = 0; %%1E-6;  % Noisy input

    net.sets.test_freq        = 100;
