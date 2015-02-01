data_path = 'xxx'; % you need to fill this in
cache_file = 'xxx'; %you need to fill this in
error('you need to fill in data_path and cache_file; use the dissertation files to figure this out.');

% Determine the data directory, based on the setting of the data_path and cache_file

% cache file with no dir data; set dir_data to empty
%   so that looper will know to load data from cache file
if strcmp('.mat', guru_fileparts(data_path,'ext')) && isempty(cache_file)
    cache_file = data_path;
    if ~exist(cache_file,'file'), error('Could not find cache file: %s', cache_file); end;
    data_dir = [];
    
% Fix path  
elseif ~exist(data_path,'dir') && exist(fullfile(guru_getOutPath('cache'), data_path), 'dir')
    data_dir = fullfile(guru_getOutPath('cache'), data_path);

else
    data_dir = data_path
end;
    %if ~exist('cache_file', 'var'),cache_file= fullfile(guru_getOutPath('cache'), 'tdlc2013_cache.mat'); end;

[data, nts, noise, delay] = r_collect_data_looped_tdlc(data_dir, cache_file);
if    isempty(data),               error('No data found at %s', data_dir);
elseif ~exist(cache_file, 'file'), r_save_cache_data(cache_file); end;

r_plot_ringo_figure(data, nts, noise, delay);