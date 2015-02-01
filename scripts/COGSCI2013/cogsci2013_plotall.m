addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));

cogsci_dir = fullfile(guru_getOutPath('cache'), 'cogsci2013');
cache_file = fullfile(cogsci_dir, 'cogsci2013_cache.mat');

%% Noise dependence: 10 time-steps
[cdata, ndata, ts] = r_collect_two_datasets(fullfile(cogsci_dir, 'nonoise_10'), fullfile(cogsci_dir, 'noise_10_1'), cache_file);
for fi=r_plot_ringo_figures(cdata, ndata, ts, [0.3 0.4 0.5 0.6 0.7 0.8])
    figure(fi);
    title('Learning Trajectory (delay=10 time-steps)');
%    [~,~,oh] = legend();
%    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;
return


%% Noise dependence: 2 time-steps
[cdata, ndata, ts] = r_collect_two_datasets(fullfile(cogsci_dir, 'nonoise_2'), fullfile(cogsci_dir, 'noise_2_1'), cache_file);
for fi=r_plot_ringo_figures(cdata, ndata, ts, [0.4 0.8])
    figure(fi);
    title('Learning Trajectory (delay=2 time-steps)');
%    [~,~,oh] = legend();
%    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;

%% Time dependence: control

% % wrongly classified
[cdata, ndata, ts] = r_collect_two_datasets(fullfile(cogsci_dir, 'nonoise_2'), fullfile(cogsci_dir, 'nonoise_10'), cache_file);
for fi=r_plot_ringo_figures(cdata, ndata, ts, [0.4 0.8])
    figure(fi);
    [~,~,oh] = legend();
    title('Learning Trajectory (control)');
    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;

%% Time dependence: noise

% % wrongly classified
[cdata, ndata, ts] = r_collect_two_datasets(fullfile(cogsci_dir, 'nonoise_10'), fullfile(cogsci_dir, 'noise_10_1'), cache_file);
for fi=r_plot_ringo_figures(cdata, ndata, ts, [0.4 0.8])
    figure(fi);
    title('Learning Trajectory (noise)');
    [~,~,oh] = legend();
    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;


% Save off the cache file, for future fast access
if ~exist(cache_file, 'file')
    save_cache_data(cache_file);
end;