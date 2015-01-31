clear globals variables;
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
dbstop if error;

net = experiment_one_args();
net.sets.niters = 5000;
net.sets.dirname    = fullfile(net.sets.dirname, mfilename);

r_train_and_analyze_many(net, 25); % run 25 network instances


