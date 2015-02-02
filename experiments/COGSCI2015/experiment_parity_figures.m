
expt_names = {'noise', 'nonoise', 'maturing', 'independent'};
all_nets  = cell(size(expt_names));
all_datas = cell(size(expt_names));

%% Collect the data
for expi=1:length(expt_names)
    experiment_fn = str2func(strrep(mfilename, 'figures', expt_names{expi}));
    experiment_fn();

    all_nets{expi} = nets{1};
    all_datas{expi} = datas{1};
    clear('nets', 'pats', 'datas', 'figs');
    close all;
end;

%% New plots
if true
end;
