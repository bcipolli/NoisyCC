net = experiment_unaryadd_args();

[nets, pats, datas, figs] = r_train_and_analyze_all_by_sequence(net, 10); % run 25 network instances
