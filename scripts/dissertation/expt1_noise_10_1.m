clear globals variables;
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
dbstop if error;

net = dissertation_args();   % Noise level contained in args
net.sets.axon_noise = 0.5 * net.sets.axon_noise; % 1% axon noise
net.sets.dirname    = fullfile(net.sets.dirname, mfilename);

r_looper(net, 25); % run 25 network instances