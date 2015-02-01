function [nets, pats, datas, figs] = r_train_and_analyze_all(template_net, nexamples, ...
                                                             nccs, delays, Ts, ...
                                                             loop_figs, summary_figs, ...
                                                             results_dir, output_types)
%    ncc
%   delays
%   Ts: decay constants

    %% Initialize environment and directories.
    if ~exist('nexamples', 'var'), nexamples = 10; end;
    if ~exist('nccs', 'var'), nccs = [template_net.sets.ncc]; end;
    if ~exist('delays', 'var'), delays = max(template_net.sets.D_CC_INIT(:)); end;
    if ~exist('Ts', 'var'), Ts = max(template_net.sets.T_INIT(:)); end;
    if ~exist('loop_figs', 'var'), loop_figs = [1:4]; end;
    if ~exist('summary_figs', 'var'), summary_figs = [0 1 2]; end;
    if ~exist('output_types', 'var'), output_types = {'png'}; end;
    if ~exist('results_dir', 'var'),
        abc = dbstack;
        script_name = abc(end).name;
        results_dir = fullfile(guru_getOutPath('plot'), script_name);
    end;

    if ~exist(results_dir, 'dir'), mkdir(results_dir); end;

    % Collect the data
    nets = cell(length(nccs), length(delays), length(Ts));
    datas = cell(size(nets));

    %% Train in parallel, gather data sequentially
    parfor mi=1:nexamples, for ni = 1:length(nccs), for di=1:length(delays), for ti=1:length(Ts)
        % Train the network
        net = set_net_params(template_net, nccs(ni), delays(di), Ts(ti), mi);
        r_train_and_analyze_many(net, 1);
    end; end; end; end;

    for ni = 1:length(nccs), for di=1:length(delays), for ti=1:length(Ts)
        net = set_net_params(template_net, nccs(ni), delays(di), Ts(ti));
        [nets{ni, di, ti}, pats, datas{ni, di, ti}] = r_train_and_analyze_many(net, nexamples);
    end; end; end;


    %% Analyze the networks and massage the results
    sims = cell(size(nets));
    simstats = cell(size(nets));
    lagstats = cell(size(nets));

    for ci=1:numel(nets)
        % Combine the results
        [sims{ci}, simstats{ci}, lagstats{ci}, idx] = r_group_analyze(nets{ci}{1}.sets, datas{ci});

        % Filter the results to only good results
        nets{ci} = nets{ci}(idx.built);
        datas{ci} = datas{ci}(idx.built);

        % Report some results
        r_plot_similarity(nets{ci}, sims{ci}, simstats{ci}, lagstats{ci}, loop_figs);
    end;

    % compute
    vals = r_compute_common_vals(nets, sims, false);
    if isempty(vals), return; end;

    % Plot some summary figures
    figs = [];
    figs = [figs r_plot_training_stats(nets, datas, vals, nexamples, summary_figs)];
    figs = [figs r_plot_interhemispheric_surfaces(nets, datas, vals, summary_figs)];
    figs = [figs r_plot_similarity_surfaces(nets, vals, simstats, lagstats, summary_figs)];

    if ~isempty(output_types)  % passing empty will keep the figures open...
        guru_saveall_figures( ...
            results_dir, ...
            output_types, ...
            false, ...  % don''t overwrite
            true);      % close figures after save
    end;

function [nets, pats, datas] = r_train_and_analyze_many(net, n_nets)
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
    sets = net.sets;

    nets = cell(n_nets, 1);
    datas = cell(n_nets, 1);
    for si=(min_rseed-1+[1:n_nets])
        ii = si - min_rseed + 1;
        [nets{ii}, pats, datas{ii}] = r_train_and_analyze_one(sets, si);
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
    net.sets = guru_rmfield(net.sets, {'D_LIM', 'matfile'});
    %net.sets.debug = false;

    if exist('mi', 'var')
        net.sets.rseed = template_net.sets.rseed + (mi-1);
    end;


function [sims, simstats, lagstats, idx] = r_group_analyze(sets, datas)
% built: was built (?)
% trained: finished training without errors.
% good: built & trained.

    idx.built   = cellfun(@(d) ~isfield(d, 'ex') && isfield(d, 'actcurve'), datas);
    idx.trained = cellfun(@(d) isfield(d, 'good_update') && (length(d.good_update) < sets.niters || nnz(~d.good_update) == 0), datas);
    idx.good    = idx.built & idx.trained;
    idx.good

    sims          = cellfun(@(d) d.sims,     datas(idx.good), 'UniformOutput', false);

    simstats_tmp  = cellfun(@(d) d.simstats, datas(idx.good), 'UniformOutput', false);
    simstats.mean = mean(cat(5, simstats_tmp{:}), 5);
    simstats.std  = std(cat(5, simstats_tmp{:}), [], 5);
    simstats.nsims = sum(idx.good);

    lagstats_tmp  = cellfun(@(d) mean(d.lagstats.a, 1)', datas(idx.good), 'UniformOutput', false);
    lagstats.mean = mean(cat(2, lagstats_tmp{:}), 2);
    lagstats.std = std(cat(2, lagstats_tmp{:}), [], 2);
    lagstats.nsims = sum(idx.good);
