net = experiment_one_args();

noise_schedule = [linspace(1, 1, 0.1 * net.sets.niters) ...
                  linspace(1, 0.0, 0.1 * net.sets.niters) ...
                  0*linspace(1, 0.0, 0.8 * net.sets.niters) ]  % relative schedule of noise.
guru_assert(net.sets.niters == length(noise_schedule));

net.sets.niters = 5000;
net.sets.axon_noise = net.sets.axon_noise * noise_schedule;

r_train_and_analyze_all_by_sequence(net, 3, [0, 2]); % run 25 network instances






