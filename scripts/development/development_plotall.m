addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));

cogsci_dir = fullfile(guru_getOutPath('cache'), 'development');
cache_file = fullfile(cogsci_dir, 'development_cache.mat');

%% Noise dependence: 10 time-steps
[cdata, ndata, ts] = r_collect_two_datasets(fullfile(cogsci_dir, 'nonoise_test_2000'), fullfile(cogsci_dir, 'noise_test_2000'), cache_file);
for fi=r_plot_ringo_figures(cdata, ndata, ts, [0.4 1.2 2.2 3])
    %figure(fi);
    %title('Learning Trajectory (delay=10 time-steps)');
%    [~,~,oh] = legend();
%    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;
return


% Save off the cache file, for future fast access
if ~exist(cache_file, 'file')
    r_save_cache_data(cache_file);
end;