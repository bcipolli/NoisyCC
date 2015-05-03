function COGSCI2015_plot_all(nets, pats, datas, idx, all_data, varargin)
    opts = struct(varargin{:});
    if ~isfield(opts, 'summary_figs'), opts.summary_figs = [0 1 2]; end;

    for ci=1:numel(nets)
        % Filter the results to only good results
        nets{ci} = nets{ci}(idx(ci).built);
        datas{ci} = datas{ci}(idx(ci).built);
    end;

    % compute
    vals = r_compute_common_vals(nets, all_data.sims, false);
    if isempty(vals), return; end;

    % Plot some summary figures
    figs = [];
    figs = [figs r_plot_training_stats(nets, datas, vals, all_data.nexamples, opts.summary_figs)];
    figs = [figs r_plot_interhemispheric_surfaces(nets, datas, vals, opts.summary_figs)];
    figs = [figs r_plot_similarity_surfaces(nets, vals, all_data.simstats, all_data.lagstats, opts.summary_figs)];
    %figs = [figs r_plot_training_curves(nets, vals, all_data.simstats, all_data.lagstats, opts.summary_figs)];

