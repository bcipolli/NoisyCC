function [cdata, ndata, ts] = r_collect_two_datasets(clean_dir, noise_dir, cache_file)

% Defaults & scrubbing input
%if ~exist('clean_dir', 'var'), clean_dir = 'nonoise.10'; end;
%if ~exist('noise_dir', 'var'), noise_dir = 'noise.10.1'; end;
if ~exist('cache_file', 'var'),cache_file= fullfile(guru_getOutPath('cache'),'cs2013_cache.mat'); end;

[cdata,ts] = get_cache_data(clean_dir, cache_file);
[ndata]    = get_cache_data(noise_dir, cache_file);