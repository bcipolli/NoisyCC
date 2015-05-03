function [cdata, ndata, ts] = r_collect_two_datasets(clean_dir, noise_dir, cache_file, filter_fn)

% Defaults & scrubbing input
if ~exist('cache_file', 'var'),cache_file= ''; end;
if ~exist('filter_fn', 'var'), filter_fn = @(blob) (true); end;

[cdata,ts] = r_get_cache_data(clean_dir, cache_file, filter_fn);
[ndata]    = r_get_cache_data(noise_dir, cache_file, filter_fn);