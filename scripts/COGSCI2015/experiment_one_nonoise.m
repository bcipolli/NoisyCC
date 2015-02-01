net = experiment_one_args();
net.sets.niters = 5000;
net.sets.axon_noise = 0;

r_train_and_analyze_many(net, 10); % run 25 network instances


