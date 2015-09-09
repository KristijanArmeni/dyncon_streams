function [coh,voxindx] = streams_corticoaudiocoherence_lcmv(subject, voxindx)

load(fullfile('/home/language/jansch/projects/streams/data/corticoaudiocoherence',[subject.name,'_corticoaudiocoherence']), 'data');

% split into meg and audio, keep only the 'audio' channels
audio = ft_selectdata(data, 'channel', data.label(strncmp(data.label,'audio',5)));
data  = ft_selectdata(data, 'channel', data.label(strncmp(data.label,'M',1)));

% apply a highpass + bandstop to the data
cfg            = [];
cfg.bpfilter   = 'yes';
cfg.bpfreq     = [35 45];
cfg.bpfilttype = 'firws';
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

% project the leadfields onto the 2-dimensional tangential basis
for k = 1:numel(sourcemodel.inside)
  ik = sourcemodel.inside(k);
  [u,s,v] = svd(sourcemodel.leadfield{ik},'econ');
  sourcemodel.leadfield{ik} = sourcemodel.leadfield{ik}*v(:,1:2);
end

cfg      = [];
cfg.vol  = headmodel;
cfg.grid = sourcemodel;
cfg.grid.inside = voxindx;
cfg.grid.outside = setdiff(1:prod(sourcemodel.dim),voxindx);
cfg.method = 'lcmv';
cfg.lcmv.lambda = '5%';
cfg.lcmv.keepfilter = 'yes';
cfg.lcmv.keepcov = 'yes';
cfg.lcmv.keepmom = 'no';
source = ft_sourceanalysis(cfg, tlck);

% project the filters onto the 2-dimensional tangential basis
%for k = 1:numel(source.inside)
%  ik = source.inside(k);
%  [u,s,v] = svd(source.avg.cov{ik});
%  source.avg.filter{ik} = u(:,1)'*source.avg.filter{ik};
%end

F = cat(1,source.avg.filter{source.inside});
%label = cell(numel(source.inside)*2,1);
label = cell(numel(source.inside),1);
for k = 1:numel(source.inside)
  ik = source.inside(k);
  label{(k-1)*2+1} = ['vox',num2str(ik),'_01'];
  label{(k-1)*2+2} = ['vox',num2str(ik),'_02'];
%  label{k} = ['vox',num2str(ik)];

end
hfdata       = rmfield(data, {'trial' 'label' 'time' 'sampleinfo' 'trialinfo'});
hfdata.label = cat(1,label,audio.label);
hfdata.time  = audio.time(1);

labelcmb = cell(0,2);
for k = 1:numel(audio.label)
  labelcmb = cat(1, labelcmb, [label repmat(audio.label(k),[numel(label) 1])]);
end

cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'powandcsd';
cfg.tapsmofrq = 2;
cfg.foilim = [0 30];
cfg.channelcmb = labelcmb;  

% loop over trials for the spectral analysis
for k = 1:numel(data.trial)
  tmp = F*data.trial{k};
  tmp = abs(tmp);
  tmp = tmp - mean(tmp,2)*ones(1,size(tmp,2));
  tmp = cat(1,tmp,audio.trial{k});
  
  hfdata.trial{1} = tmp;
  tmpfreq = ft_freqanalysis(cfg, hfdata);
  
  if k==1
    crsspctrm = tmpfreq.crsspctrm;
    powspctrm = tmpfreq.powspctrm;
  else
    crsspctrm = tmpfreq.crsspctrm+crsspctrm;
    powspctrm = tmpfreq.powspctrm+powspctrm;
  end
  
end

%% the following is when the filter is 1-d
% coh = crsspctrm;
% for k = 1:numel(audio.label)
%   tmppow = powspctrm(1:numel(label),:);
%   tmppow2 = powspctrm(numel(label)+k,:);
%   indx   = (k-1)*size(tmppow,1)+(1:size(tmppow,1));
%   coh(indx,:) = crsspctrm(indx,:)./sqrt(tmppow.*tmppow2(ones(1,numel(indx)),:));
% end

% the following is when the filter is 2-d
ncmb = size(crsspctrm,1)/2;
nfrq = size(crsspctrm,2);
coh  = zeros(ncmb,nfrq);

tmppow = powspctrm(1:numel(label),:);
tmppow = tmppow(1:2:end,:)+tmppow(2:2:end,:); % this amounts to the trace of the voxel csd.  
for k = 1:numel(audio.label)
  tmppow2 = powspctrm(numel(label)+k,:);
  indx1   = (k-1)*size(tmppow,1)+(1:size(tmppow,1)); % indices after combination of the dipole orientations
  indx2   = (k-1)*2*size(tmppow,1)+(1:2*size(tmppow,1)); % indices before combination of the dipole orientations
  
  tmpcrs  = crsspctrm(indx2,:);
  tmpcrs  = sqrt(abs(tmpcrs(1:2:end,:)).^2+abs(tmpcrs(2:2:end,:)).^2); % this is equivalent to the lambda1 (i.e. svd)
  
  coh(indx1,:) = tmpcrs./sqrt(tmppow.*tmppow2(ones(1,numel(indx1)),:));
end
