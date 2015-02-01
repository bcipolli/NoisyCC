function fig_handles = r_plot_similarity(nets, sim, simstats, lagstats, figs)


    if ~iscell(nets), nets = { nets }; end;
    if isempty(sim), return; end;
    if iscell(sim),   sim  = sim{1}; end;
    if ~exist('xform', 'var'), xform = ''; end;
    if ~exist('figs', 'var'), figs = [1:4]; end;

    pat_types = sim.pat_types;
    npattypes = length(pat_types);
    nlocs = length(sim.hemi_locs);
    tsteps = sim.tsteps;
    nsims = length(sim.rh_output(1).patsim);

    % Now that output has been suppressed, print info about the network.
    title_addendum = sprintf('D=%d ncc=%d/%d output_ts=[%d %d]', max(nets{1}.sets.D_CC_LIM(:)), nets{1}.sets.ncc, nets{1}.sets.nhidden_per, round(nets{1}.sets.S_LIM/nets{1}.sets.dt));
    labels = cellfun(@(str) (strrep(str(4:end),  '_', '\_')), sim.hemi_locs(1:end/2), 'UniformOutput', false);

    % Variable to store the outputs
    fig_handles = [];

    %% Figure 1: asymmetry in difference from output similarity
    value_types = {'input-diff', 'output-diff', 'hidden'};
    for fi=1:3
        if ~ismember(fi, figs), continue; end;  % not requested

        fig_handles(end+1) = figure('name', sprintf('dissim-%s', value_types{fi}), 'Position', [ 72         327        1227         446]);

        for pti=1:npattypes
            subplot(1, npattypes, pti); set(gca, 'FontSize', 16);
            data_mean = squeeze(simstats(:, :, pti, 7 + (fi-1)));
            plot(repmat(1:tsteps, [nlocs/2 1])', data_mean, 'LineWidth', 2);

            legend(labels, 'Location', 'NorthWest');
            title(strrep([title_addendum ' ' pat_types{pti}], '_', '\_'));
            if pti == 1, ylabel(sprintf('Correlation between LH and RH similarities (%s).', value_types{fi})); end;
            xlabel('Time step')
            set(gca, 'ylim', [-0.25 1]);
        end;
    end;

    %% Figure 4
    if ismember(4, figs)
        fig_handles(end+1) = figure('name', 'xcorr', 'Position', [ 72         -21        1209         794]);
        lag_mean = mean(lagstats, 1);
        lag_stde = std(lagstats, [], 1) / sqrt(size(lagstats, 1));
        ntimes = size(lag_stde, 2);
        lag_times = [1:ntimes] - (ntimes + 1) / 2;
        errorbar(lag_times, lag_mean, lag_stde);
        xlabel('time lag');
        ylabel('cross correlation');
        title('interhemispheric cross correlation');
    end;


    %% [DEPRECATED] Figure 11: mean difference from output similarity
    if ismember(11, figs)
        warning('This figure is deprecated.');

        % Plots simstats indices 1, 2 and 3, 4
        fig_handles(end+1) = figure('name', 'similarity-mean-diffs-from-io', 'Position', [ 72         -21        1209         794]);

        lbls = {};
        for pti=1:npattypes

            subplot(2, npattypes, pti);
            data_mean = squeeze(simstats(:, :, pti, 1));
            data_sde = squeeze(simstats(:, :, pti, 2))/sqrt(nsims);
            errorbar(repmat(1:tsteps, [nlocs/2 1])', data_mean, data_ste, 'LineWidth', 2);

            legend(labels);
            title(strrep([title_addendum ' ' pat_types{pti}], '_', '\_'));
            if pti == 1, ylabel('Mean difference of similarity from input.'); end;

            subplot(2, npattypes, pti+1);
            data_mean = squeeze(simstats(:, :, pti, 3));
            data_sde = squeeze(simstats(:, :, pti, 4))/sqrt(nsims);
            errorbar(repmat(1:tsteps, [nlocs/2 1])', data_mean, data_ste, 'LineWidth', 2);

            legend(labels);
            if pti == 1, ylabel('Mean difference of similarity from output.'); end;
            xlabel('time step');
        end;
    end;


    %% [DEPRECATED] Figure 12: asymmetry in difference from input similarity
    if ismember(12, figs)
        warning('This figure is deprecated.');

        % Plots simstats indices 5, 6
        fig_handles(end+1) = figure('name', 'similarity-mean-diff-from-input', 'Position', [ 72         327        1227         446]);

        prop_cc = nets{1}.sets.ncc / nets{1}.sets.nhidden_per;
        ih_idx = find(cellfun(@(x) ~isempty(x), regexp('ih$', labels)));
        cc_idx = find(cellfun(@(x) ~isempty(x), regexp('cc$', labels)));
        for pti=1:npattypes
            data_mean = squeeze(simstats(:, :, pti, 5));
            data_std = squeeze(simstats(:, :, pti, 6));
            cur_labels = labels;

            if length(ih_idx) == 1 && length(cc_idx) == 1
                data_mean(:, end+1) = data_mean(:, [cc_idx ih_idx]) * [prop_cc; 1-prop_cc];
                data_std(:, end+1)  = data_std(:, [cc_idx ih_idx])  * [prop_cc; 1-prop_cc];
                cur_labels = {cur_labels{:} 'ih\_combined'};
            end;

            subplot(1,npattypes,pti);
            errorbar(repmat(1:tsteps, [size(data_mean, 2) 1])', data_mean, data_std/sqrt(nsims), 'LineWidth', 2);

            set(gca, 'ylim', [0 1.2]);
            legend(cur_labels);
            title(strrep([title_addendum ' ' pat_types{pti}], '_', '\_'));
            if pti == 1, ylabel('Mean difference between LH and RH similarities.'); end;
            xlabel('time step');
        end;
    end;
