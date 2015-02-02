net = experiment_unaryadd_args();
net.sets.axon_noise = 0;

[nets, pats, datas, figs] = r_train_and_analyze_all(net, 10); % run 25 network instances
