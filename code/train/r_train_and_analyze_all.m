function [nets, pats, datas, figs] = r_train_and_analyze_all(template_net, nexamples, ...
                                                             nccs, delays, Ts, varargin)
%    ncc
%   delays
%   Ts: decay constants

    %% Initialize environment and directories.
    if ~exist('nexamples', 'var'), nexamples = 10; end;
    if ~exist('nccs', 'var'), nccs = [template_net.sets.ncc]; end;
    if ~exist('delays', 'var'), delays = max(template_net.sets.D_CC_INIT(:)); end;
    if ~exist('Ts', 'var'), Ts = max(template_net.sets.T_INIT(:)); end;

    opts = struct(varargin{:});
    if ~isfield(opts, 'output_types'), opts.output_types = {'png'}; end;
    if ~isfield(opts, 'results_dir'),
        abc = dbstack;
        script_name = abc(end).name;
        opts.results_dir = fullfile(guru_getOutPath('plot'), script_name);
    end;

    if ~exist(opts.results_dir, 'dir'), mkdir(opts.results_dir); end;

    % Collect the data
    nets = cell(length(nccs), length(delays), length(Ts));
    datas = cell(size(nets));

    %% Train in parallel, gather data sequentially
    parfor mi=1:nexamples, for ni = 1:length(nccs), for di=1:length(delays), for ti=1:length(Ts)
        % Train the network
        net = set_net_params(template_net, nccs(ni), delays(di), Ts(ti), mi);
        r_train_many_analyze_one(net, 1);
    end; end; end; end;

    for ni = 1:length(nccs), for di=1:length(delays), for ti=1:length(Ts)
        net = set_net_params(template_net, nccs(ni), delays(di), Ts(ti));
        [nets{ni, di, ti}, pats, datas{ni, di, ti}] = r_train_many_analyze_one(net, nexamples);
    end; end; end;

    % Determine which nets are good.
    idx = find_successful_nets(nets, template_net.sets, datas);

    %% Analyze the full networks and massage the results
    if isfield(template_net.fn, 'analyze_all')
        fprintf('Analyzing via function callback (%s) ...', func2str(net.fn.analyze_all));
        all_data = template_net.fn.analyze_all(nets, pats, datas, idx, varargin{:});
        fprintf('done.\n');
    end;

    all_data.nexamples = nexamples;  % this may create the data structure, needed below!
    if isfield(template_net.fn, 'plot_all')
        fprintf('Plotting via function callback (%s) ...', func2str(net.fn.plot_all));
        template_net.fn.plot_all(nets, pats, datas, idx, all_data, varargin{:});
        fprintf('done.\n');
    end;

    if ~isempty(opts.output_types)  % passing empty will keep the figures open...
        guru_saveall_figures( ...
            opts.results_dir, ...
            opts.output_types, ...
            false, ...  % don''t overwrite
            true);      % close figures after save
    end;


function [nets, pats, datas] = r_train_many_analyze_one(net, n_nets)
%function r_train_and_analyze_many(net, n_nets)
%
% Loops over some # of networks to execute them.

    % Select # of networks to run
    if ~exist('n_nets','var')
      if isfield(net.sets,'n_nets'), n_nets = net.sets.n_nets;
      else                           n_nets = 10;
      end;
    end;

    % Get random seed, save default network settings
    min_rseed = net.sets.rseed;

    nets = cell(n_nets, 1);
    datas = cell(n_nets, 1);
    for si=(min_rseed-1+[1:n_nets])
        ii = si - min_rseed + 1;
        net.sets.rseed = si;
        [nets{ii}, pats, datas{ii}] = r_train_and_analyze_one(net);
    end;


function net = set_net_params(template_net, ncc, delay, T, mi)
    % Helper function to set net parameters; this complains if
    %   done in a parfor loop

    % set params
    net = template_net;
    net.sets.ncc = ncc;
    net.sets.D_CC_INIT(:) = delay;
    net.sets.T_INIT(:) = T;
    net.sets.T_LIM(:) = T;
    net.sets = guru_rmfield(net.sets, {'D_LIM', 'matfile'}); % Remove so that they can be recomputed
    %net.sets.debug = false;

    if exist('mi', 'var')
        net.sets.rseed = template_net.sets.rseed + (mi-1);
    end;


function idx = find_successful_nets(nets, sets, datas)
    built = cell(1, numel(nets));
    trained = cell(size(built));
    good = cell(size(built));

    for ci=1:numel(nets)
        built{ci}   = cellfun(@(d) ~isfield(d, 'ex') && isfield(d, 'actcurve'), datas{ci});
        trained{ci} = cellfun(@(d) isfield(d, 'good_update') && (length(d.good_update) < sets.niters || nnz(~d.good_update) == 0), datas{ci});
        good{ci}    = built{ci} & trained{ci};
        good{ci}
    end;

    idx = struct('built', built, 'trained', trained, 'good', good);

