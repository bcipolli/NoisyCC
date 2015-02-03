% Script for testing a single task (shift), where the output for each hemisphere
% depends on the input from BOTH hemispheres.  Each hemisphere outputs parity computed over all bits.

net = lewis_elman_common_args();

% Do this with negative-only callosal connections.
net.sets.dataset   = 'parity_dual';  % dual hemisphere task

% Manually-determined training parameters
net.sets.dirname     = fullfile(net.sets.dirname, net.sets.dataset);
net.sets.train_criterion = 0.50;
net.sets.eta_w       = 0.02;
net.sets.phi_w       = 0.50;
net.sets.lambda_w    = 2E-4;
%net.sets.batch_size = 32;
net.sets.niters      = 2500;

% Train over all combinations of ncc and delays
ncc    = linspace(0, net.sets.nhidden_per, 6);
ncc    = ncc(end:-1:1);
delays = [1 5 10 15 20];

r_train_and_analyze_all_by_sequence(net, 10, ncc, delays);
