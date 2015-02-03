net = experiment_unaryadd_args();
net.sets.niters          = 500; %training iterations

% Compute noise schedule
niters_by_tenths = round(diff(linspace(1, net.sets.niters, 11)));
noise_schedule = [ones(1, niters_by_tenths(1)) ...
                  linspace(1, 0, niters_by_tenths(2)) ...
                  zeros(1, sum(niters_by_tenths(3:end)))];  % relative schedule of noise.
net.sets.axon_noise = net.sets.axon_noise * noise_schedule;


[nets, pats, datas, figs] = r_train_and_analyze_all(net, 10); % run 25 network instances


