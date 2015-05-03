net = experiment_parity_args();
net.sets.ncc = 0;

[nets, pats, datas, figs] = r_train_and_analyze_all_by_sequence(net, 10);
