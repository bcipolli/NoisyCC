function net = experiment_one_args(varargin)
%function net = experiment_one_args(varargin)

    net = COGSCI2015_common_args(varargin{:})

    % Architecture parameters
    net.sets.nhidden_per     = 15;%
    net.sets.ncc             = 3;

    % Training parameters
    net.sets.niters          = 1000; %training iterations
    net.sets.train_criterion = 0.5;
    net.sets.dataset         = 'lewis_elman';
    net.sets.test_freq        = 100;

    net.sets.eta_w           = 1E-3;    %learning rate (initial)
    net.sets.eta_w_min       = 0;
    net.sets.lambda_w        = 2E-2;    % lambda*E to control kappa.
    net.sets.phi_w           = 0.25;    % multiplicative decrease to eta
    net.sets.alpha_w         = 0.25;    %% momentum
