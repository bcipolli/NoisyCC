noise_schedule = [linspace(1, 1, 500) linspace(1,0.0,500) 0*linspace(0.1,0.0,4000) ];  % relative schedule of noise.

net = experiment_one_args();
net.sets.niters = 5000;  guru_assert(net.sets.niters == length(noise_schedule));
net.sets.axon_noise = net.sets.axon_noise * noise_schedule;

r_train_and_analyze_all(net, 10); % run 25 network instances


