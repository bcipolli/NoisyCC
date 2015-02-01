function [an,sets] = r_collect_data(dirname, resave)
%

  if ~exist('resave','var'), resave = false; end;
  if ~exist(dirname,'file'), error('Could not find directory: %s', dirname); end;

  [an.n, blobs, sets] = load_data_blobs(dirname, resave);

  %% Useful constants
  an.ts.niters = blobs{1}.net.sets.niters;
  an.ts.lesion = [100:100:an.ts.niters];
  an.ts.intact = [1 an.ts.lesion];

  %% Allocate space
  idx = blobs{1}.net.idx;
  pats = blobs{1}.pats;
  an.intra.weights.lh = zeros(length(blobs), length(idx.lh_ih), length(idx.lh_ih));
  an.intra.weights.rh = zeros(length(blobs), length(idx.rh_ih), length(idx.rh_ih));
  an.inter.weights.lh = zeros(length(blobs), length(idx.lh_cc), length(idx.lh_cc));
  an.inter.weights.rh = zeros(length(blobs), length(idx.rh_cc), length(idx.rh_cc));

  an.intra.intact.err = nan(length(blobs), an.ts.niters);
  an.inter.intact.err = nan(length(blobs), an.ts.niters);
  an.all.intact.err   = nan(length(blobs), an.ts.niters);
  an.intra.lesion.err = nan(length(blobs), length(an.ts.lesion));
  an.inter.lesion.err = nan(length(blobs), length(an.ts.lesion));
  an.all.lesion.err   = nan(length(blobs), length(an.ts.lesion));

  an.intra.intact.clserr = nan(size(an.intra.intact.err));
  an.inter.intact.clserr = nan(size(an.inter.intact.err));
  an.all.intact.clserr   = nan(size(an.all.intact.err));
  an.intra.lesion.clserr = nan(size(an.intra.lesion.err));
  an.inter.lesion.clserr = nan(size(an.inter.lesion.err));
  an.all.lesion.clserr   = nan(size(an.all.lesion.err));


  m = @(npat) npat*(npat-1)/2;  % similarity matrix is symmetric, so only diagonal & upper triangle need to be computed
  an.all.lesion.rh_sim = nan(length(blobs), m(pats.test.npat));
  an.all.lesion.lh_sim = nan(length(blobs), m(pats.test.npat));
  an.intra.lesion.rh_sim = nan(length(blobs), m(length(pats.idx.intra)));
  an.intra.lesion.lh_sim = nan(length(blobs), m(length(pats.idx.intra)));
  an.inter.lesion.rh_sim = nan(length(blobs), m(length(pats.idx.inter)));
  an.inter.lesion.lh_sim = nan(length(blobs), m(length(pats.idx.inter)));

  an.all.intact.rh_sim = nan(length(blobs), m(pats.test.npat));
  an.all.intact.lh_sim = nan(length(blobs), m(pats.test.npat));
  an.intra.intact.rh_sim = nan(length(blobs), m(length(pats.idx.intra)));
  an.intra.intact.lh_sim = nan(length(blobs), m(length(pats.idx.intra)));
  an.inter.intact.rh_sim = nan(length(blobs), m(length(pats.idx.inter)));
  an.inter.intact.lh_sim = nan(length(blobs), m(length(pats.idx.inter)));

  
  %% Loop and fill in data
  for bi=1:length(blobs)
    b = blobs{bi};
    data = b.data; pats = b.pats; net = b.net;
    sets{end+1} = net.sets;
    has_intra = false;
    
    %% Weights
    an.all.weights.lh(bi,:,:) = net.w(b.net.idx.lh_ih, net.idx.lh_ih);
    an.all.weights.rh(bi,:,:) = net.w(b.net.idx.rh_ih, net.idx.rh_ih);
    if has_intra
        an.intra.weights.lh(bi,:,:) = net.w(b.net.idx.lh_ih, net.idx.lh_ih);
        an.intra.weights.rh(bi,:,:) = net.w(b.net.idx.rh_ih, net.idx.rh_ih);
        an.inter.weights.lh(bi,:,:) = net.w(b.net.idx.lh_cc, net.idx.lh_cc);
        an.inter.weights.rh(bi,:,:) = net.w(b.net.idx.rh_cc, net.idx.rh_cc);
    end;
    
    %% Sum-squared error
    if has_intra
        an.intra.intact.err(bi,1:size(data.E_pat,1)) = squeeze(mean(mean(data.E_pat(:,pats.idx.intra,:),3),2))';
        an.inter.intact.err(bi,1:size(data.E_pat,1)) = squeeze(mean(mean(data.E_pat(:,pats.idx.inter,:),3),2))';
    end;
    an.all.intact.err(bi,1:size(data.E_pat,1))   = squeeze(mean(mean(data.E_pat(:,:,:),3),2))';
    if has_intra
        an.intra.lesion.err(bi,1:size(data.E_lesion,1)) = mean(mean(data.E_lesion(:,pats.idx.intra,:),3),2)';
        an.inter.lesion.err(bi,1:size(data.E_lesion,1)) = mean(mean(data.E_lesion(:,pats.idx.inter,:),3),2)';
    end;
    an.all.lesion.err(bi,1:size(data.E_lesion,1))   = mean(mean(data.E_lesion(:,:,:),3),2)';

    % Fake (propagate) values for early stopping
    if has_intra
        an.intra.intact.err(bi,size(data.E_pat,1)+1:end)    = an.intra.intact.err(bi,size(data.E_pat,1));
        an.inter.intact.err(bi,size(data.E_pat,1)+1:end)    = an.inter.intact.err(bi,size(data.E_pat,1));
    end;
    an.all.intact.err(bi,size(data.E_pat,1)+1:end)      = an.all.intact.err(bi,size(data.E_pat,1));
    if has_intra
        an.intra.lesion.err(bi,size(data.E_lesion,1)+1:end) = an.intra.lesion.err(bi, max(1,size(data.E_lesion,1)));
        an.inter.lesion.err(bi,size(data.E_lesion,1)+1:end) = an.inter.lesion.err(bi, max(1,size(data.E_lesion,1)));
    end;
    an.all.lesion.err(bi,size(data.E_lesion,1)+1:end)   = an.all.lesion.err(bi, max(1,size(data.E_lesion,1)));

    % Some aggregates and differences
    if has_intra
        an.intra.lei.err  = -(an.intra.intact.err(:,100:100:end) - an.intra.lesion.err);
        an.inter.lei.err  = -(an.inter.intact.err(:,100:100:end) - an.inter.lesion.err);
    end;
    an.all.lei.errmean = mean(an.all.lesion.err,1) - mean(an.all.intact.err(:,an.ts.lesion),1);
    an.all.lei.errstd = std(an.all.lesion.err,[],1) + std(an.all.intact.err(:,an.ts.lesion),[],1);
    an.all.lei.errsem = guru_sem(an.all.lesion.err, 1) + guru_sem(an.all.intact.err(:,an.ts.lesion), 1);

    %% Classification errors
    %gb_intra = find(pats.train.s(:,pats.idx.intra,:));
    %gb_inter = find(pats.train.s(:,pats.idx.inter,:));

    diff_intact = sqrt(2*data.E_pat); %reverse SSE to get activation
    diff_lesion = sqrt(2*data.E_lesion);

    if has_intra
        an.intra.intact.clserr(bi,1:size(diff_intact,1)) = mean(mean( diff_intact(:,pats.idx.intra,:)>=net.sets.train_criterion, 3),2);
        an.inter.intact.clserr(bi,1:size(diff_intact,1)) = mean(mean( diff_intact(:,pats.idx.inter,:)>=net.sets.train_criterion, 3),2);
    end;
    an.all.intact.clserr(bi,1:size(diff_intact,1))   = mean(mean( diff_intact(:,:,:)>=net.sets.train_criterion, 3),2);
    if has_intra
        an.intra.lesion.clserr(bi,1:size(diff_lesion,1)) = mean(mean( diff_lesion(:,pats.idx.intra,:)>=net.sets.train_criterion, 3),2);
        an.inter.lesion.clserr(bi,1:size(diff_lesion,1)) = mean(mean( diff_lesion(:,pats.idx.inter,:)>=net.sets.train_criterion, 3),2);
    end;
    an.all.lesion.clserr(bi,1:size(diff_lesion,1))   = mean(mean( diff_lesion(:,:,:)>=net.sets.train_criterion, 3),2);

    % ????
    if has_intra
        an.intra.lesion.err(bi,1:size(data.E_lesion,1)) = mean(mean(data.E_lesion(:,pats.idx.intra,:),3),2)';
        an.intra.lesion.clserr(bi,1:size(diff_lesion,1)) = mean(mean( diff_lesion(:,pats.idx.intra,:)>=net.sets.train_criterion, 3),2);
    end;
    
    % Fake (propagate) values for early stopping
    if has_intra
        an.intra.intact.clserr(bi,size(diff_intact,1)+1:end) = an.intra.intact.clserr(bi,size(diff_intact,1));
        an.inter.intact.clserr(bi,size(diff_intact,1)+1:end) = an.inter.intact.clserr(bi,size(diff_intact,1));
    end;
    an.all.intact.clserr(bi,size(diff_intact,1)+1:end)   = an.all.intact.clserr(bi,size(diff_intact,1));
    if has_intra
        an.intra.lesion.clserr(bi,size(diff_lesion,1)+1:end) = an.intra.lesion.clserr(bi, max(1,size(diff_lesion,1)));
        an.inter.lesion.clserr(bi,size(diff_lesion,1)+1:end) = an.inter.lesion.clserr(bi, max(1,size(diff_lesion,1)));
    end;
    an.all.lesion.clserr(bi,size(diff_lesion,1)+1:end)   = an.all.lesion.clserr(bi, max(1,size(diff_lesion,1)));

    % Some aggregates and differences
    %an.all.intact.clserr = (an.intra.intact.clserr + an.inter.intact.clserr)/2;
    %an.all.lesion.clserr = (an.intra.lesion.clserr + an.inter.lesion.clserr)/2;
    if has_intra
        an.intra.lei.cls = -(an.intra.intact.clserr(:,100:100:end) - an.intra.lesion.clserr);
        an.inter.lei.cls = -(an.inter.intact.clserr(:,100:100:end) - an.inter.lesion.clserr);
    end;
    
    an.all.lei.clsmean = mean(an.all.lesion.clserr,1) - mean(an.all.intact.clserr(:,an.ts.lesion),1);
    an.all.lei.clsstd  = std(an.all.lesion.clserr,[],1) + std(an.all.intact.clserr(:,an.ts.lesion),[],1);
    an.all.lei.clssem  = guru_sem(an.all.lesion.clserr, 1) + guru_sem(an.all.intact.clserr(:,an.ts.lesion), 1);


    %% Now separate inter and intra
    npats = size(b.data.hu_lesion,2);
    nhidden =  size(b.data.hu_lesion,3);
    rh_idx = 1:(nhidden/2);
    lh_idx = (nhidden/2)+[1:(nhidden/2)];


    an.all.lesion.hu_sim = zeros(length(an.ts.lesion), npats);


    sum_act_lesion = sum(sum(b.data.hu_lesion, 3), 2);  % Find the last iteration with data
    last_iter_idx = find(sum_act_lesion, 1, 'last');  % Select that iteration
    act_lesion = squeeze(b.data.hu_lesion(last_iter_idx, :, :));  % patterns x hidden units

    sum_act_intact = sum(sum(b.data.hu_pat, 3), 2);  % sum over everything but time
    last_iter_idx = find(sum_act_intact, 1, 'last');
    act_intact = squeeze(b.data.hu_pat(last_iter_idx, :, :));  % patterns x hidden units

    if ~isempty(act_lesion)
        an.all.lesion.rh_sim(bi,:) = pdist(act_lesion(:, rh_idx), 'correlation');
        an.all.lesion.lh_sim(bi,:) = pdist(act_lesion(:, lh_idx), 'correlation');
        if has_intra
            an.intra.lesion.rh_sim(bi,:) = pdist(act_lesion(pats.idx.intra, rh_idx), 'correlation');
            an.intra.lesion.lh_sim(bi,:) = pdist(act_lesion(pats.idx.intra, lh_idx), 'correlation');
            an.inter.lesion.rh_sim(bi,:) = pdist(act_lesion(pats.idx.inter, rh_idx), 'correlation');
            an.inter.lesion.lh_sim(bi,:) = pdist(act_lesion(pats.idx.inter, lh_idx), 'correlation');
        end;
    end;
    
    if ~isempty(act_intact)
        an.all.intact.rh_sim(bi,:) = pdist(act_intact(:, rh_idx), 'correlation');
        an.all.intact.lh_sim(bi,:) = pdist(act_intact(:, lh_idx), 'correlation');
        if has_intra
            an.intra.intact.rh_sim(bi,:) = pdist(act_intact(pats.idx.intra, rh_idx), 'correlation');
            an.intra.intact.lh_sim(bi,:) = pdist(act_intact(pats.idx.intra, lh_idx), 'correlation');
            an.inter.intact.rh_sim(bi,:) = pdist(act_intact(pats.idx.inter, rh_idx), 'correlation');
            an.inter.intact.lh_sim(bi,:) = pdist(act_intact(pats.idx.inter, lh_idx), 'correlation');
        end;
    end;
    
    rh_in =  squeeze(b.pats.train.P(2,:,b.pats.idx.rh.in)); % avoid the bias term
    lh_in =  squeeze(b.pats.train.P(2,:,b.pats.idx.lh.in));
    rh_out =  squeeze(b.pats.train.d(1,:,b.pats.idx.rh.out));
    lh_out =  squeeze(b.pats.train.d(1,:,b.pats.idx.lh.out));

    an.all.rh_in_sim = pdist(rh_in, 'correlation');
    an.all.lh_in_sim = pdist(lh_in, 'correlation');
    an.all.rh_out_sim = pdist(rh_out, 'correlation');
    an.all.lh_out_sim = pdist(lh_out, 'correlation');


%
%
%
%
%     for ti=1:length(an.ts.lesion)
%
%
%
%         b.data.hu_lesion
%         b.data.hu_pat(an.ts.lesion(ti))
%
%         sum_act = sum(sum(b.data.hu_lesion, 3), 2);  % sum over everything but time
%         act = squeeze(b.data.lesion.y(end,:,:));
%
%       fprintf('%d %d\n', bi, ti);
%       rh_act = squeeze(b.data.lesion.y(end,:,rh_idx));
%       rh_act(isnan(rh_act)) = 0;
%       %rh_act_norm = rh_act-repmat(mean(rh_act,1),[size(rh_act,1) 1]);
%       rh_sim = pdist(rh_act); % pat x output unit
%
%
%       lh_act = squeeze(b.data.hu_lesion(end,:,lh_idx));
%       if all(~lh_act(:))
%           % Bug: early stopping and these didn't get copied over.
%           guru_assert(b.data.niters < b.net.sets.niters);
%           sum_act = sum(sum(b.data.hu_lesion, 3), 2);  % sum over everything but time
%           idx = find(sum_act, 1, 'last');
%           lh_act = squeeze(b.data.hu_lesion(idx,:,lh_idx));
%       end;
%
%       an.all.lesion.rh_sim = pdist(squeeze(b.data.hu_lesion(end,:,rh_idx)));
%       an.all.lesion.lh_sim = pdist(squeeze(b.data.hu_lesion(end,:,lh_idx)));
%       an.intra.lesion.rh_sim = pdist(squeeze(b.data.hu_lesion(end,pats.idx.intra,rh_idx)));
%       an.intra.lesion.lh_sim = pdist(squeeze(b.data.hu_lesion(end,pats.idx.intra,lh_idx)));
%       an.inter.lesion.rh_sim = pdist(squeeze(b.data.hu_lesion(end,pats.idx.inter,rh_idx)));
%       an.inter.lesion.lh_sim = pdist(squeeze(b.data.hu_lesion(end,pats.idx.inter,lh_idx)));
%
%       %vicente = @(x,y) ( trace( (x'*x)'*(y'*y') ) );
%       %sim = @(x,y) ( vicente(x,y)/(vicente(y,y)*vicente(x,x)) );
%       %/ trace( (y'*y)'*(y'*y) ) * trace((x'*x)'*(x'*x))
%
%       rh_act = squeeze(b.data.nolesion.y(end,:,rh_idx));
%       rh_act(isnan(rh_act)) = 0;
%       %rh_act_norm = rh_act-repmat(mean(rh_act,1),[size(rh_act,1) 1]);
%       rh_sim = pdist(rh_act);%rh_act_norm * rh_act_norm';
%
%       lh_act = squeeze(b.data.nolesion.y(end,:,lh_idx));
%       lh_act(isnan(lh_act)) = 0;
%       %lh_act_norm = lh_act-repmat(mean(lh_act,1),[size(lh_act,1) 1]);
%       lh_sim = pdist(lh_act);%rh_act_norm * rh_act_norm';
%
%       an.all.intact.rh_sim = rh_sim;
%       an.all.intact.lh_sim = lh_sim;
%       an.intra.intact.rh_sim = rh_sim(pats.idx.intra,pats.idx.intra);
%       an.intra.intact.lh_sim = lh_sim(pats.idx.intra,pats.idx.intra);
%       an.inter.intact.rh_sim = rh_sim(pats.idx.inter,pats.idx.inter);
%       an.inter.intact.lh_sim = lh_sim(pats.idx.inter,pats.idx.inter);
%
      %rh_sim =  * squeeze(b.data.hu_lesion(1,:,rh_idx))';
      %lh_sim = squeeze(b.data.hu_lesion(1,:,lh_idx)) * squeeze(b.data.hu_lesion(1,:,lh_idx))';
      %an.all.lesion.hu_sim(ti,:) =  .* squeeze(b.data.hu_lesion(1,:,lh_idx))'; % left-right similarity
      lr_D = net.D(net.idx.lh_cc,net.idx.rh_cc); rl_D = net.D(net.idx.rh_cc,net.idx.lh_cc);
      all_d = [ lr_D(:); rl_D(:) ];
      an.D.cc_bins = [min(net.sets.D_CC_INIT(:)):max(net.sets.D_CC_INIT(:))];
      an.D.cc_dist = hist( all_d, an.D.cc_bins );
    %end;
  end;

 % convert cell array to struct array
 sets = [sets{:}];







  function [n, blobs, sets] = load_data_blobs(dirname, resave)
      files = dir(fullfile(dirname,'*.mat'))
      n = length(files);

      % Load all data
      warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
      blobs = {};%cell(n,1);
      sets  = {};
      for fi=1:n
          try
             b = load(fullfile(dirname, files(fi).name));
          catch
            lasterr,
            fprintf('Skipping %s\n', fullfile(dirname, files(fi).name));
            continue;
          end;
          b.data.E_pat = b.data.E_pat/b.net.sets.dt;

          % reconstruct indices, for symmetric/asymmetric experiments
          if ~isfield(b.pats.idx, 'intra')
              b.pats.idx.intra = 1:b.pats.train.npat;
              b.pats.idx.inter = [];
              if resave,
                  net=b.net; pats=b.pats; data=b.data;
                  fprintf('%d ', fi);
                  save(fullfile(dirname, files(fi).name), 'net','pats','data');
              end;
              clear('net', 'pats', 'data');
          end;

          % reconstruct functions
          if false
              try
                  b.net.fn.sse(1,1);
              catch
                  fprintf('reconstituting...\n');
                  b.net.fn.sse  = @(y,d)   (0.5.*(y-d).^2);
                  b.net.fn.Err  = @(y,d)   (b.net.fn.sse(y,d));
                  b.net.fn.Errp = @(y,d,p) ((y-d).^p);
                  b.net.fn.f      = @(x)    ((exp(x)-exp(-x)) ./ (exp(x)+exp(-x)));
                  b.net.fn.fp     = @(x,fx) (1-fx.^2);
                  b.net.fn.fo     = @(x)    (1.7159*(2 ./ (1 + exp(-2 * 2*x/3)) - 1));
                  b.net.fn.fpo    = @(x,fx) (1.7159*2/3*(1 - (fx/1.7159).^2));
              end;

              % Paste on extra info, if not already there
              if true || ~isfield(b.data, 'noise')
                  net=b.net; pats=b.pats; data=b.data;
                  data.an = r_analyze(net, pats, data);
                  net.continue=true;
                  net.sets.axon_noise=0;

                  [net,pats_new,data_new] = r_train_one(net);
                  data    = r_test(net, pats, data);
                  data.an = r_analyze(net, pats, data);
                  if resave,
                      fprintf('%d ', fi);
                      save(fullfile(dirname, files(fi).name), 'net','pats','data');
                  end;
                  clear('net', 'pats', 'data');
              end;
          end;
    %fprintf('%d ', fi);
          blobs{end+1} = b;
      end;
