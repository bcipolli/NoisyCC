function all_data = COGSCI2015_analyze_all(nets, pats, datas, idx)
    sims = cell(size(nets));
    simstats = cell(size(nets));
    lagstats = cell(size(nets));

    for ci=1:numel(nets)
        % Combine the results
        [sims{ci}, simstats{ci}, lagstats{ci}, idx] = r_group_analyze(nets{ci}{1}.sets, datas{ci}, idx(ci));
    end;


function [sims, simstats, lagstats] = r_group_analyze(sets, datas, idx)
% built: was built (?)
% trained: finished training without errors.
% good: built & trained.


    sims          = cellfun(@(d) d.sims,     datas(idx.good), 'UniformOutput', false);

    simstats_tmp  = cellfun(@(d) d.simstats, datas(idx.good), 'UniformOutput', false);
    simstats.mean = mean(cat(5, simstats_tmp{:}), 5);
    simstats.std  = std(cat(5, simstats_tmp{:}), [], 5);
    simstats.nsims = sum(idx.good);

    lagstats_tmp  = cellfun(@(d) mean(d.lagstats.a, 1)', datas(idx.good), 'UniformOutput', false);
    lagstats.mean = mean(cat(2, lagstats_tmp{:}), 2);
    lagstats.std = std(cat(2, lagstats_tmp{:}), [], 2);
    lagstats.nsims = sum(idx.good);
