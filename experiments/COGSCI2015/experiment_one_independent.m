net = experiment_one_args();
net.sets.niters = 1000;
net.sets.ncc = 0;

r_train_and_analyze_all(net, 10); % run 25 network instances


