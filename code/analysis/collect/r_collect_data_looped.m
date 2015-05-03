function [data, sets, collection_names] = r_collect_data_looped(dirname, cache_file, filter_fns, force_load)
%
% dirname: directory to search.
% cache_file: cache file to load/save results from/to
% filter_fns: a second way to split results or filter files.
%
% d: data
% s: settings
% folders: 
if ~exist('prefix','var'),     prefix=''; end;
if ~exist('filter_fns', 'var'), filter_fns = @(blob) (true); end;
if ~exist('force_load', 'var'), force_load = true; end;

% Get all subfolders with given prefix
if isempty(dirname)
    guru_assert(exist('cache_file', 'var'), 'Must specify an existing cache file when dirname is empty!')
    paths = r_load_cache_file(cache_file);
    folders = cellfun(@(d) guru_fileparts(d,'name'), paths, 'UniformOutput', false);
else
    fprintf('Collecting data from "%s"\n', search_string);
    folders = dir(dirname);
    folders = folders([folders.isdir]);
    folders = setdiff({folders.name}, {'.','..'});
    folders = cellfun(@(d) fullfile(dirname, d), folders, 'UniformOutput', false);
    % if there are no subdirectories, just use files from the current directory.
    if isempty(folders)
        folders = {dirname};
    end;
end;

% Separate files virtually via filter functions.
if length(folders) == 1 && iscell(filter_fns)
    data = cell(size(filter_fns));
    sets = cell(size(filter_fns));

    for foi=1:numel(filter_fns)
        cur_filter = filter_fns{foi};
        fprintf('Processing [%s]...', dirname);
        [data{foi}, ~, sets{foi}] = r_get_cache_data(dirname, cache_file, filter_fn, force_load); % break the caching
        fprintf('\n');
    end;

% Separate files by directory location
else
    data = cell(size(folders));
    sets = cell(size(folders));

    for foi=1:numel(folders)
        curdir = folders{foi};
        fprintf('Processing [%s]...', curdir);
        [data{foi}, ~, sets{foi}] = r_get_cache_data(curdir, cache_file, filter_fns, force_load); % break the caching
        fprintf('\n');
    end;
