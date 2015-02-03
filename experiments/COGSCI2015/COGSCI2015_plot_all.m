function COGSCI2015_plot_all(nets, pats, datas, idx, varargin)
    opts = struct(varargin{:});
    if ~isfield(opts, 'summary_figs'), opts.summary_figs = [0 1 2]; end;

    for ci=1:numel(nets)
        % Filter the results to only good results
        nets{ci} = nets{ci}(idx(ci).built);
        datas{ci} = datas{ci}(idx(ci).built);
    end;

    % compute
    vals = r_compute_common_vals(nets, sims, false);
    if isempty(vals), return; end;

    % Plot some summary figures
    figs = [];
    figs = [figs r_plot_training_stats(nets, datas, vals, nexamples, opts.summary_figs)];
    figs = [figs r_plot_interhemispheric_surfaces(nets, datas, vals, opts.summary_figs)];
    figs = [figs r_plot_similarity_surfaces(nets, vals, simstats, lagstats, opts.summary_figs)];

