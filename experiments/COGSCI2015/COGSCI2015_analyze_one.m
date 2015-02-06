function [data, something_changed] = analysis_callback(net, pats, data)
    something_changed = false;

    if ~all(isfield(data, {'sims', 'simstats', 'lagstats'})) % Always analyze similarities
        fprintf('Analyzing similarity data...');
        [data.sims, data.simstats, data.lagstats] = r_analyze_similarity(net, pats, data);
        fprintf('done.\n');
        something_changed = true;
    end;

