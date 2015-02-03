net = experiment_unaryadd_args();
net.sets.ncc = 0;

[nets, pats, datas, figs] = r_train_and_analyze_all(net, 10);
