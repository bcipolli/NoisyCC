function data = r_record_lesion_performance(iter, net, pats, data)
% Callback function from r_train_resilient_batch
%
% iter is empty => end.

    lesion_iter = floor(abs(iter) / net.sets.test_freq);

    % Setup and cleanup
    if lesion_iter == 1
        max_lesion_iters = floor(net.sets.niters / net.sets.test_freq);
        data.E_lesion   = inf(max_lesion_iters, pats.npat, net.noutput, 'single');           % error
        data.hu_lesion  = inf(max_lesion_iters, pats.npat, net.nhidden, 'single');           % error
    elseif iter < 1  % cleanup
        data.E_lesion    = data.E_lesion(1:lesion_iter, :, :);
        data.hu_lesion   = data.E_lesion(1:lesion_iter, :, :);
        return;
    end;

%        lesion_iter = find(isinf(data.E_lesion(:,1,1)), 1, 'first');

    last_measure_ts = find(sum(sum(pats.s,3),2),1,'last'); % keep an index of the last measurement point

    nl = r_lesion_cc(net);
    td = r_forwardpass(nl,pats,data);

    data.E_lesion(lesion_iter,:,:) = td.E(last_measure_ts,:,:);
    data.hu_lesion(lesion_iter,:,:) = td.y(last_measure_ts,:,net.idx.hidden);
