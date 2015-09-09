datadir = '/home/language/jansch/projects/streams/data/mutualinformation';
cd(datadir);
subj = {'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's09' 's10'};
for k = 1:numel(subj)
  d=dir([subj{k}, '*mi_perplexity_all.mat']);
  for m = 1:numel(d)
    load(d(m).name);
    if m==1
      allstat{k}=stat;
    else
      allstat{k}=cat(2,allstat{k}, stat);
    end
  end
end

for k = 1:numel(allstat)
  dat{k} = cat(3,allstat{k}.stat);
  tmp    = cat(4,allstat{k}.statshuf);
  dat2{k} = squeeze(median(tmp,3));
end
for k = 1:numel(dat)
  alldat(:,:,k) = mean(dat{k},3);
  alldat2(:,:,k) = mean(dat2{k},3);
end

tlck.dimord = 'rpt_chan_time';
tlck.time   = stat.time;
tlck.label  = stat.label;
tlck.trial  = permute(alldat, [3 1 2]);
tlck2       = tlck;
tlck2.trial = permute(alldat2, [3 1 2]);

Nsubj = size(tlck.trial,1);

cfg           = [];
cfg.method    = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.design    = [ones(1,Nsubj) ones(1,Nsubj)*2;1:Nsubj 1:Nsubj];
cfg.numrandomization = 1000;
cfg.ivar = 1;
cfg.uvar = 2;
stat     = ft_timelockstatistics(cfg, tlck, tlck2);

tlck.trial  = permute(cat(3,dat{:}), [3 1 2]);
tlck2.trial = permute(cat(3,dat2{:}),[3 1 2]);
Nsubj       = size(tlck.trial,1);

cfg           = [];
cfg.method    = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.design    = [ones(1,Nsubj) ones(1,Nsubj)*2;1:Nsubj 1:Nsubj];
cfg.numrandomization = 1000;
cfg.ivar = 1;
cfg.uvar = 2;
stat2    = ft_timelockstatistics(cfg, tlck, tlck2);


