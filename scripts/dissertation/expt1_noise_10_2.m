clear globals variables;
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
dbstop if error;

net = dissertation_args();   % Noise level contained in args
net.sets.dirname    = fullfile(net.sets.dirname, mfilename);

r_train_and_analyze_many(net, 25); % run 25 network instances
