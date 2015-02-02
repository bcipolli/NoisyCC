net = tdlc2013_args();
cache_dir         = strrep(net.sets.dirname, 'ringo2', 'ringo');%guru_fileparts(net.sets.dirname, 'name');
cache_file        = fullfile(cache_dir, [mfilename '.mat']);
clear('net');

% Determine the data directory, based on the setting of the cache_dir and cache_file

% cache file with no dir data; set dir_data to empty
%   so that looper will know to load data from cache file
if strcmp('.mat', guru_fileparts(cache_dir,'ext')) && isempty(cache_file)
    cache_file = cache_dir;
    if ~exist(cache_file,'file'), error('Could not find cache file: %s', cache_file); end;
    data_dir = [];

% Fix path
elseif ~exist(cache_dir,'dir') && exist(fullfile(guru_getOutPath('cache'), cache_dir), 'dir')
    data_dir = fullfile(guru_getOutPath('cache'), cache_dir);

else
    data_dir = cache_dir
end;
    %if ~exist('cache_file', 'var'),cache_file= fullfile(guru_getOutPath('cache'), 'tdlc2013_cache.mat'); end;

[data, nts, noise, delay] = r_collect_data_looped_tdlc(data_dir, cache_file);
if    isempty(data),               error('No data found at %s', data_dir);
elseif ~exist(cache_file, 'file'), r_save_cache_data(cache_file); end;

r_plot_ringo_figure(data, nts, noise, delay);
guru_saveall_figures('.');