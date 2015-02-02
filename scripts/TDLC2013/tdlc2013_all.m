template_net = tdlc_args()

if ~exist('matlabpool', 'file')
   chunk_size = 1;
else
    if matlabpool('size') == 0
        matlabpool open 4;
    end;
    chunk_size = matlabpool('size');
end;

for rseed=(289-1+[1:chunk_size:25])
  for tsteps=[15:5:50 75]
    for delay=[2 10]
      for noise=[2E-2/delay 0] % 1% activation
          net.sets = template_net.sets;

          net.sets.tstart = 0;
          net.sets.tsteps = tsteps  ;%we''ll add another hidden layer, so measure output at one step later
          net.sets.tstop  = net.sets.tsteps * net.sets.dt;
          net.sets.I_LIM  = net.sets.tstart+net.sets.dt*(Idel +[0 Idur]); %in terms of time, not steps
          net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(Sdel +[Sdur 0]);  % min & max time to consider error

          net.sets.D_CC_INIT(1,:,:) = delay*[1 1; 1 1];             %early; l->r and r->l
          net.sets.D_CC_INIT(2,:,:) = net.sets.D_CC_INIT(1,:,:); %late;  l->r and r->l

          net.sets.axon_noise       = noise;%1E-5;%0.0005; % constant level of noise

          net.sets.rseed = rseed;

          dirname = fullfile(template_sets, sprintf('%s-%dts-%dd%s', mfilename(), tsteps, delay,guru_iff(noise>0,'n','')));
          if ~exist(dirname,'dir'), mkdir(dirname); end;
          net.sets.dirname = dirname;

          r_train_and_analyze_all(net, chunk_size);
      end;
    end;
  end;
end;

% Make into one giant cache
cache_dir         = guru_fileparts(fileparts(net.sets.dirname), 'name');
cache_file        = fullfile(cache_dir, [mfilename '.mat']);
[~,~,folders] = r_collect_data_looped( cache_dir );

r_make_cache_file(folders, cache_file);
