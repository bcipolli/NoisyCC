function [net, pats, data] = r_train_and_analyze_one(net, save_data)
%

    if ~exist('save_data', 'var'), save_data = true; end;
    something_changed = false;

    %% Make sure not to reuse networks!
    net = r_massage_params(net);
    matfile = fullfile(net.sets.dirname, net.sets.matfile);

    %% Load from cache
    if ~guru_getfield(net.sets, 'force', false)
        file_loaded = false;
        if exist(get_all_filename(matfile), 'file')
            % one file contains all
            fprintf('Loading OLD cached file %s...', get_all_filename(matfile));
            load(get_all_filename(matfile));
            fprintf(' done.\n');
            file_loaded = true;
            fprintf('delete(%s)\n', get_all_filename(matfile));
            something_changed = true;  % re-save it
        end;
        if exist(get_net_filename(matfile), 'file')
            something_changed = false;   % disable any re-saving
            % Two files; one for data, one for analysis
            fprintf('Loading NEW cached file %s...', get_net_filename(matfile));
            load(get_net_filename(matfile));
            if exist(get_data_filename(matfile))
                fprintf('\n\tand %s ...', get_data_filename(matfile));
                load(get_data_filename(matfile));
            end;
            fprintf(' done.\n');
            file_loaded = true;
        end;
        % Validate what we file_loaded
        if file_loaded
            if ~exist('net',  'var'), fprintf('net not found in matfile; retraining.\n'); end;
            if ~exist('pats', 'var'), fprintf('pats not found in matfile; ignoring.\n'); end;
            %if ~exist('data', 'var'), fprintf('data not found in matfile; re-analyzing.\n'); end;
            if exist('data', 'var') && isfield(data, 'ex')
                % Check for inadvertent errors/messages that require reanalysis
                if ~isempty(findstr('time to debug', guru_getfield(data.ex, 'message', [])))
                    clear('data');
                    fprintf('** RERUNNING inadvertently error-cached scenario.\n');
                end;
            end;
            % Fall through, to append any extra analyses
        end;
        clear('file_loaded');
    end;


    %% Train, if needed
    if ~exist('data', 'var')
        something_changed = true;

        try
            [net, pats, data] = r_train_one(net, [], [], false);  % handle exception
        catch ex
            if isempty(strfind(ex.message, 'nan'))
                throw(ex);
            end;
            pats = [];
            data.ex = ex;
            fprintf('Error: %s\nCall stack:\n', ex.message);
            fprintf('\t%s\n', ex.stack.file);
        end;
    end;

    %% Analyze, if possible / needed
    if ~isfield(data, 'ex')
        if ~isfield(data, 'an')  % Always analyze training
            fprintf('Analyzing training data...');
            [data.an] = r_analyze_training(net, pats, data);
            fprintf('done.\n');
            something_changed = true;
        end;

        % custom analysis callback
        if something_changed
            if isfield(net.fn, 'analyze_one')
                fprintf('Analyzing via function callback (%s) ...', func2str(net.fn.analyze_one));
                data = net.fn.analyze_one(net, pats, data);
                fprintf('done.\n');
            end;

            if isfield(net.fn, 'plot_one')
                fprintf('Plotting via function callback (%s) ...', func2str(net.fn.plot_one))
                net.fn.plot_one(net, pats, data);
                fprintf(' done.\n');
            end;
        end;
    end;

    %% Save the result
    if save_data && something_changed
        if ~exist(net.sets.dirname), mkdir(net.sets.dirname); end;
        net_file = get_net_filename(matfile);
        fprintf('Saving net/pats to %s ...', net_file);
        save(net_file, 'net', 'pats');
        fprintf(' done.\n');

        data_file = get_data_filename(matfile);
        fprintf('Saving analysis data to %s ...', data_file);
        save(data_file, 'data');
        fprintf(' done.\n');
    end;

    guru_assert(isfield(data, 'actcurve') || isfield(data, 'ex') , 'actcurve not in data!');


function fn = get_all_filename(fn)
    fn = strrep(fn, '.net.mat', '.mat');

function fn = get_net_filename(fn)
    fn = strrep(fn, '.net.mat', '.mat');
    fn = strrep(fn, '.mat', '.net.mat');

function fn = get_data_filename(fn)
    % Lazy way to deal with old case and new case.
    fn = strrep(fn, '.net.mat', '.mat');
    fn = strrep(fn, '.mat', '.data.mat');
