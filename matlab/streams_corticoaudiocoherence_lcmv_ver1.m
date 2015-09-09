function [coh,info] = streams_corticoaudiocoherence_lcmv(subject, voxindx)

load(fullfile('/home/language/jansch/projects/streams/data/corticoaudiocoherence',[subject.name,'_corticoaudiocoherence']), 'data');

% split into meg and audio, keep only the 'audio' channels
audio = ft_selectdata(data, 'channel', data.label(strncmp(data.label,'audio',5)));
data  = ft_selectdata(data, 'channel', data.label(strncmp(data.label,'M',1)));

% apply a highpass + bandstop to the data
cfg            = [];
cfg.hpfilter   = 'yes';
cfg.hpfreq     = 35;
cfg.hpfilttype = 'firws';
cfg.bsfilter   = 'yes';
cfg.bsfreq     = [49 51];
data           = ft_preprocessing(cfg, data);
data.time(1:end) = data.time(1); %equate time axis to the first trial's time axis for ft_timelockanalysis
audio.time(1:end) = audio.time(1);

% compute the covariance
cfg  = []; 
cfg.covariance = 'yes';
cfg.covariancewindow = 'all';
tlck = ft_timelockanalysis(cfg, data);

% compute the lcmv filters
load(fullfile('/home/language/jansch/projects/streams/data/anatomy',[subject.name,'_anatomy_headmodel']));
load(fullfile('/home/language/jansch/projects/streams/data/anatomy',[subject.name,'_anatomy_sourcemodel5mm']));

% % make a roi of a few voxels around each indexed voxel
% [ix,iy,iz] = ind2sub(sourcemodel.dim, voxindx);
% indx{1} = voxindx;
% sel{1}  = (1:numel(voxindx))';
% [indx{2},sel{2}] = intersect(sub2ind(sourcemodel.dim, ix+1, iy, iz),sourcemodel.inside);
% [indx{3},sel{3}] = intersect(sub2ind(sourcemodel.dim, ix-1, iy, iz),sourcemodel.inside);
% [indx{4},sel{4}] = intersect(sub2ind(sourcemodel.dim, ix, iy+1, iz),sourcemodel.inside);
% [indx{5},sel{5}] = intersect(sub2ind(sourcemodel.dim, ix, iy-1, iz),sourcemodel.inside);
% [indx{6},sel{6}] = intersect(sub2ind(sourcemodel.dim, ix, iy, iz+1),sourcemodel.inside);
% [indx{7},sel{7}] = intersect(sub2ind(sourcemodel.dim, ix, iy, iz-1),sourcemodel.inside);

if numel(voxindx)>50
  chunk = [0:50:numel(voxindx) numel(voxindx)];
  for k = 1:numel(chunk)-1
    indx{k} = voxindx((chunk(k)+1):chunk(k+1));
  end
else
  indx{1} = voxindx;
end

for kk = 1:numel(indx)
  cfg      = [];
  cfg.vol  = headmodel;
  cfg.grid = sourcemodel;
  cfg.grid.inside = indx{kk};
  cfg.grid.outside = setdiff(1:prod(sourcemodel.dim),indx{kk});
  cfg.method = 'lcmv';
  cfg.lcmv.lambda = '5%';
  cfg.lcmv.keepfilter = 'yes';
  source = ft_sourceanalysis(cfg, tlck);
  
  % compute the high frequency envelope for the virtual channels
  for k = 1:numel(source.inside)
    tmptrial = source.avg.filter{source.inside(k)}*data.trial;
    [u,s,v]  = svd(cat(2,tmptrial{:}),'econ');
    tmptrial = u(:,1:2)'*tmptrial;
    for m = 1:numel(tmptrial)
      tmp = tmptrial{m};
      tmp = sqrt(sum(tmp.^2));
      tmptrial{m} = tmp-mean(tmp);
    end
    
    if k==1,
      trial = tmptrial;
      label = {['vox',num2str(source.inside(k))]};
    else
      trial = cellcat(1, trial, tmptrial);
      label{k} = ['vox',num2str(source.inside(k))];
    end
  end
  
  hfdata = rmfield(data, {'trial' 'label'});
  hfdata.trial = trial;
  hfdata.label = label;
  
  hfdata = ft_appenddata([], hfdata, audio);
  
  % do spectral analysis
  cfg = [];
  cfg.method = 'mtmfft';
  cfg.output = 'fourier';
  cfg.tapsmofrq = 2;
  cfg.foilim = [0 40];
  freq = ft_freqanalysis(cfg, hfdata);
  
  tmp = ft_checkdata(freq, 'cmbrepresentation', 'fullfast');
  
  cfg = [];
  cfg.method = 'coh';
  coh(kk) = ft_connectivityanalysis(cfg, tmp);
  coh(kk).cohspctrm = coh(kk).cohspctrm(1:numel(indx{kk}),(numel(indx{kk})+1):end,:);
  info(kk).voxindx = indx{kk};
  %info(kk).match   = sel{kk};
end
