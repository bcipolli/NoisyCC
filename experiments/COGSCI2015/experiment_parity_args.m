function net = experiment_parity_args(varargin)
%function net = experiment_parity_args(varargin)

    net = COGSCI2015_common_args(varargin{:})

    %training parameters
    net.sets.niters          = 250; %training iterations
    net.sets.nhidden_per     = 10;%
    net.sets.ncc             = 2;
    net.sets.train_criterion = 0.25;
    net.sets.dataset         = 'parity';
