function [sim, simstats, lagstats] = r_compute_similarity(net, pats, sim_measure, timelag)
%
%Input:
%   net - network object
%   pats - pattern object
%   sim_measure - parameter to pdist; default 'correlation'
%   timelag - shift of rh_curve relative to lh
%
%Output:
% Sim:
% simstats: [# time steps] x [# locations] x [# pattern types] x 6
%
% 1, 2. mean & std of the mean LH & RH similarity
% 3, 4. mean & std of the asymmetry between LH & RH similarity (no
% normalization)
% 5. correlation between LH & RH similarity matrices
% 6. correlation between LH & RH similarity differences (from output)

    warning('off', 'stats:pdist:constantPoints');

    if ~exist('sim_measure', 'var'), sim_measure = 'correlation'; end;
    if ~exist('timelag', 'var'), timelag = 0; end;

    if iscell(net)
        % Received multiple networks; loop over them and average.
        sims = cell(numel(net), 1);
        simstats_s = cell(numel(net), 1);
        simstats = 0;
        for ni=1:numel(net)
            fprintf('Processing %d of %d...', ni, numel(net));
            [sims{ni}, simstats_s{ni}] = r_compute_similarity(net{ni}, pats, sim_measure);
            %sim = sim + sims{ni}/numel(net);
            simstats = simstats + simstats_s{ni}/numel(net);
            fprintf('done.\n');
        end;
        sim = sims;
        return;
    end;


    % Set some analysis variables to assist, based on
    switch net.sets.init_type
        case 'ringo',       locs = {'input', 'early_cc', 'early_ih', 'early_hu','late_cc', 'late_ih','late_hu','output'};
        case 'lewis_elman', locs = {'input', 'cc', 'ih','hu','output'};
        otherwise, error('Unknown init_type: ''%s''', net.sets.init_type);
    end;

    switch net.sets.dataset
        case {'lewis_elman'}, pat_types = {'inter', 'intra'};
        otherwise, pat_types = {};
    end;


    pat_types = {'all', pat_types{:}};

    % Do the forward pass
    y = getfield(r_forwardpass(net, pats.test), 'y');

    % Compute the similarity matrices
    sim = representational_similarity_matrix(y, net, pats, locs, sim_measure);
    sim.pat_types = pat_types;
    sim.tsteps = size(y, 1);

    % For each timestep and location, compute similarities.
    tsteps = size(y, 1);
    nlocs = length(sim.hemi_locs);
    nsims = length(sim.rh_output(1).patsim);
    npattypes = length(pat_types);
    npats = pats.train.npat;

    % Just collect into matrix
    patsims = zeros(tsteps, nlocs, nsims);
    for ti=1:tsteps
        for li = 1:nlocs
            patsim = sim.(sim.hemi_locs{li})(ti).patsim;
            if isempty(patsim)
                patsims(ti, li, :) = NaN;
            else
                patsims(ti, li, :) = patsim;
            end;
        end;
    end;

    % Now compare across the hemispheres
    simstats = zeros(tsteps, nlocs/2, npattypes, 9); % diff_mean, diff_std, asymm_mean, asymm_std
    for ti=1:tsteps
        for li=2:nlocs / 2  % #1 is input... cheating :)
            for pti=1:npattypes  % all, inter, intra
                loc = sim.hemi_locs{li}(4:end);
                rh_idx = strcmp(sim.hemi_locs, ['rh_' loc]);
                lh_idx = strcmp(sim.hemi_locs, ['lh_' loc]);

                rh_sim = reshape(patsims(ti, rh_idx, :), [1 nsims]);
                lh_sim = reshape(patsims(ti, lh_idx, :), [1 nsims]);
                rh_simdiff_input  = rh_sim - sim.rh_in;   % how close is the similarity to the input?
                lh_simdiff_input  = lh_sim - sim.lh_out;
                rh_simdiff_output = rh_sim - sim.rh_out;  % how close is the similarity to the output?
                lh_simdiff_output = lh_sim - sim.lh_out;

                guru_assert(~any(isnan(rh_sim)) || all(isnan(rh_sim)));
                guru_assert(~any(isnan(lh_sim)) || all(isnan(lh_sim)));

                patsim_hemimean         = ( rh_sim + lh_sim ) / 2;
                patsim_hemimean_input   = ( rh_simdiff_input + lh_simdiff_input ) / 2;
                patsim_hemimean_output  = ( rh_simdiff_output + lh_simdiff_output ) / 2;
                patsim_asymmetry        = (rh_sim - lh_sim);% ./ patsim_hemimean;
                patsim_asymmetry_input  = (rh_simdiff_input - lh_simdiff_input);% ./ patsim_hemimean;
                patsim_asymmetry_output = (rh_simdiff_output - lh_simdiff_output);% ./ patsim_hemimean;

                patsim_asymmetry_corr   = corr(rh_sim', lh_sim'); %
                patsim_asymmetry_input_corr  = corr(rh_simdiff_input', lh_simdiff_input');% ./ patsim_hemimean;
                patsim_asymmetry_output_corr = corr(rh_simdiff_output', lh_simdiff_output');% ./ patsim_hemimean;

                measurements = [1-patsim_asymmetry_corr mean(abs(patsim_asymmetry))];
                diff_sign = diff(sign(measurements)) ~= 0 && abs(diff(measurements)) > 0.1;
                diff_mag = abs(diff(measurements)) > 0.25;

                if ~all(isnan(patsim_asymmetry)) && ~isnan(patsim_asymmetry_corr) && (diff_sign || diff_mag)
                    %fprintf('\n%2d: %s corr & avg differ %.2f vs %.2f\n', ti, loc, (1-patsim_asymmetry_corr), mean(abs(patsim_asymmetry)));
                end;

                % Filter only the patterns we wish to include in the similarity computation
                switch pat_types{pti}
                    case 'all', idx = 1:npats;
                    otherwise,  idx = pats.idx.(pat_types{pti});
                end;
                lower_diag_inpat = ones(npats) - eye(npats);
                lower_diag_inpat(idx, idx) = lower_diag_inpat(idx, idx) + 1;
                lower_diag_inpat = double(lower_diag_inpat > 1);
                pattype_idx = squareform(lower_diag_inpat) > 0;  % logical index

                % Goal here is to evaluate similarity & asymmetry at each
                % time point.
                %
                % patsim_hemimean tells very little.
                % patsim_hemimean_output tells how close to the output the
                %   two networks are; it is useful as an overall measure of
                %   distance from input/output (not asymmetry)
                % patsim_asymmetry tells how different the two hemispheres
                %   are, and is the most basic measure of asymmetry.
                % patsim_asymmetry_output tells whether one network is
                %   following the output more closely than the other.  It
                %   helps characterize what's going on with the network.
                % xxxx patsim_crosshemi tells how similar the representations
                % xxxx  are across the hemispheres, directly.
                simstats(ti, li, pti, 1) = nanmean(abs(patsim_hemimean_input(pattype_idx)));  % mean difference vs input (mean)
                simstats(ti, li, pti, 2) = nanstd (abs(patsim_hemimean_input(pattype_idx)));  % (std)
                simstats(ti, li, pti, 3) = nanmean(abs(patsim_hemimean_output(pattype_idx))); % mean difference vs output (mean)
                simstats(ti, li, pti, 4) = nanstd (abs(patsim_hemimean_output(pattype_idx))); % (std)

                simstats(ti, li, pti, 5) = nanmean(abs(patsim_asymmetry(pattype_idx)));  % absolute asymm (mean)
                simstats(ti, li, pti, 6) = nanstd(abs(patsim_asymmetry(pattype_idx)));   % (std)

                % corr is a measure of similarity; we want dissimilarity.  Keep the sign to indicate anti-correlation
                simstats(ti, li, pti, 7) = sign(patsim_asymmetry_input_corr)  * (1-abs(patsim_asymmetry_input_corr)); %
                simstats(ti, li, pti, 8) = sign(patsim_asymmetry_output_corr) * (1-abs(patsim_asymmetry_output_corr)); %
                simstats(ti, li, pti, 9) = sign(patsim_asymmetry_corr)        * (1-abs(patsim_asymmetry_corr)); %
            end;
        end;
    end;


    % Now do a cross-correlation between rh and lh similarities.
    for li=2:nlocs / 2  % #1 is input... cheating :)
        loc = sim.hemi_locs{li}(4:end);
        rh_idx = strcmp(sim.hemi_locs, ['rh_' loc]);
        lh_idx = strcmp(sim.hemi_locs, ['lh_' loc]);

        rh_sim = squeeze(patsims(:, rh_idx, :));
        lh_sim = squeeze(patsims(:, lh_idx, :));

        rh_sim(isnan(rh_sim)) = 0;
        lh_sim(isnan(lh_sim)) = 0;

        ncompares = size(rh_sim, 2);
        a = zeros(ncompares, tsteps * 2 - 1);
        for ci=1:ncompares
            [a(ci,:), b] = xcorr(rh_sim(:,ci), lh_sim(:,ci));
        end;

        fig_name = sprintf('delay=%d', max(net.sets.D_LIM(:)));
        figure('name', fig_name);
        plot(b, mean(a,1));
        xlabel('lag (timesteps)');
        ylabel('xcorr');
        title(fig_name);
        %print(gcf, sprintf('xcorr-%s.png', fig_name), '-dpng');
    end;
    lagstats = struct('a', a, 'b', b);
