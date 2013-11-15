function frames = streams_makemovie_erf(data, filename)

% % baseline normalise
% ix(1) = nearest(data.time,-inf);
% ix(2) = nearest(data.time,0);
% m     = nanmean(data.avg(:,ix(1):ix(2)),2);
% data.avg = data.avg./(m*ones(1,numel(data.time)))-1;

data = ft_selectdata(data, 'channel', ft_channelselection('MEG', data.label));

cfg.layout = 'CTF275.lay';
cfg.layout = ft_prepare_layout(cfg);
cfg.parameter = 'avg';
cfg.contournum = 0;
cfg.zlim   = [-1 1]*max(abs(data.avg(:))).*0.9;

% Prepare the new file.
vidObj = VideoWriter(filename);
vidObj.FrameRate = 15;

open(vidObj);
 
figure; set(gcf,'color','w');
abc = get(gcf,'position');
xlim = data.time;
for k = 1:numel(xlim)
  cfg.xlim = xlim(k)+[-1 1]*0.5*(data.time(2)-data.time(1));
  ft_topoplotER(cfg, data);
  currFrame   = getframe(gcf,[0 0 abc(3:4)]);
  frames(k,1) = currFrame;
  writeVideo(vidObj, currFrame);
end

% Close the file.
close(vidObj);

close all;