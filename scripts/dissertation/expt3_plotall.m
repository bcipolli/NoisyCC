clear all global
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));

expt3_dir = fullfile(guru_getOutPath('cache'), 'dissertation');
cache_file = fullfile(expt3_dir, 'expt3_cache.mat');

%% Noise dependence: 10 time-steps
[cdata, ndata, ts] = r_collect_two_datasets(fullfile(cogsci_dir, 'expt3_nonoise_10'), fullfile(cogsci_dir, 'expt3_noise_10_2'), cache_file);
r_plot_ringo_figures(cdata, ndata, ts, [3]);

%[cdata, ndata, ts] = r_collect_two_datasets(fullfile(cogsci_dir, 'expt3_nonoise_10_5000'), fullfile(cogsci_dir, 'expt3_noise_10_2_5000'), cache_file);
%r_plot_ringo_figures(cdata, ndata, ts, [0.4 0.6 0.8 1.4 1.6 1.8 2.2]);

% Save off the cache file, for future fast access
%if ~exist(cache_file, 'file')
%    save_cache_data(cache_file);
%end;