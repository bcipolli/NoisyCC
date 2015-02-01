clear globals variables;
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
dbstop if error;

net = experiment_one_args();
net.sets.dataset = 'parity';
net.sets.dirname    = fullfile(net.sets.dirname, mfilename);

r_train_and_analyze_many(net, 10); % run 25 network instances


