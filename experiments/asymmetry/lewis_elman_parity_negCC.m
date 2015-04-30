% Script for testing a single task (parity) that the hemispheres do in
% parallel, with negative-only callosal connections.

net = lewis_elman_common_args();
net.sets.dataset = 'parity';
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);
%net.sets.train_criterion = 0.25;
net.sets.eta_w = 0.01;
net.sets.phi_w = 0.5;
net.sets.lambda_w = 1E-3;
net.sets.cc_wt_lim       = [-inf 0];

ncc = round(linspace(0, net.sets.nhidden_per, 6));
delays = [1 5 10 15 20];

% Sample along ncc and delays independently
r_train_and_analyze_all(net, 10, ncc,              delays(ceil(end/2)));
r_train_and_analyze_all(net, 10, ncc(ceil(end/2)), delays);
