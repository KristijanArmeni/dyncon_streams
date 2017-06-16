%% Initialization

clear all
close all

savedir = '/project/3011044.02/analysis/freqanalysis/figures';
subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's10'};
ivar = 'mean_entropy';
ivarstr = ivar(6:end);

datatype = 'freqanalysisplanar_8Hztap';

freq = [4 8; 12 18; 40 90];
freq_sel = freq(2,:);
freqstr = [num2str(freq_sel(1)) '_' num2str(freq_sel(2))];
ivarfreq = [ivarstr '_' freqstr];

file_low = ['_all_01-100_' datatype '_' ivar '_low_200Hz.mat'];
file_high = ['_all_01-100_' datatype '_' ivar '_high_200Hz.mat'];
file_ttest = ['_all_01-100_' datatype '_' ivar '_ttest_200Hz.mat'];

savestr = [ivarstr '_all_01-100_' datatype '_200Hz'];

%% Plot loops
    
%%%%%% power spectra 1
figure('Name','Power spectrum', 'NumberTitle','off');
fprintf('Starting power spectra...\n\n')

for k = 1:numel(subjects) - 4

    fprintf('Going throug subject nr. %d \n', k)

    subject = subjects{k};
    low = [subject file_low] ;
    high = [subject file_high];
    load(low)
    load(high)

    subplot(2, 2, k)
    streams_plot_powspctrm(freq_high, freq_low)
    title([subject ' ' ivar(6:end)])

end
saveas(gcf, fullfile(savedir, ['power1_' savestr]), 'png');
%print(fullfile(savedir, ['power1_' savestr]), '-dpdf', '-bestfit');

% power spectra 2
figure('Name','Power spectrum: all trials', 'NumberTitle','off');
fprintf('Starting power spectra...\n\n')

for k = 5:numel(subjects)

    fprintf('Going throug subject nr. %d \n', k)

    subject = subjects{k};
    low = [subject file_low];
    high = [subject file_high];
    load(low)
    load(high)

    subplot(2, 2, k - 4)
    streams_plot_powspctrm(freq_high, freq_low)
    title([subject ' ' ivar(6:end)])

end
saveas(gcf, fullfile(savedir, ['power2_' savestr]), 'png');
%print(fullfile(savedir, ['power2_' savestr]), '-dpdf', '-bestfit')


%%%%%% change 1
figure('Name','T-statistic spectrum', 'NumberTitle','off');
fprintf('Starting t-statistics...\n\n')

for k = 1:numel(subjects) - 4

    fprintf('Going throug subject nr. %d \n', k)

    subject = subjects{k};
    ttest = [subject file_ttest];
    load(ttest)

    subplot(2, 2, k)
    streams_plot_ttest(freq_T)
    title([subject ' ' ivar(6:end)])

end
saveas(gcf, fullfile(savedir, ['ttest1_' savestr]), 'png');
%print(fullfile(savedir, ['ttest1_' savestr]), '-dpdf', '-bestfit');

% change 2
figure('Name','T-statistic spectrum', 'NumberTitle','off');
fprintf('Starting t-statistics...\n\n')

for k = 5:numel(subjects)

    fprintf('Going throug subject nr. %d \n', k)

    subject = subjects{k};
    ttest = [subject file_ttest];
    load(ttest)

    subplot(2, 2, k - 4)
    streams_plot_ttest(freq_T)
    title([subject ' ' ivar(6:end)])

end
saveas(gcf, fullfile(savedir, ['ttest2_' savestr]), 'png');
%print(fullfile(savedir, ['ttest2_' savestr]), '-dpdf', '-bestfit')

%%%%%% topos
figure('Name', 'T-test', 'NumberTitle', 'off');
fprintf('Doing topographies...\n\n')

for k = 1:numel(subjects) - 4

    fprintf('Going throug subject nr. %d \n', k)

    subject = subjects{k};
    ttest = [subject file_ttest];
    load(ttest)


    subplot(2, 2, k)
    streams_plot_powspctrmtopo(freq_T, freq_sel); 
    title([subject ' ' '[' num2str(freq_sel) ']' ' ' ivar(6:end)])
    
end
saveas(gcf, fullfile(savedir, ['ttopo1_' ivarfreq '_' datatype]), 'png')
%print(fullfile(savedir, ['ttopo1_' ivarfreq '_' datatype]), '-dpdf', '-bestfit')


% topos
figure('Name','T-test', 'NumberTitle', 'off');
fprintf('Doing topographies...\n\n')

for k = 5:numel(subjects)

    fprintf('Going throug subject nr. %d \n', k)

    subject = subjects{k};
    ttest = [subject file_ttest];
    load(ttest)


    subplot(2, 2, k - 4)
    streams_plot_powspctrmtopo(freq_T, freq_sel); 
    title([subject ' ' '[' num2str(freq_sel) ']' ' ' ivar(6:end)])

end
saveas(gcf, fullfile(savedir, ['ttopo2_' ivarfreq '_' datatype]), 'png')
%print(fullfile(savedir, ['ttopo2_' ivarfreq '_' datatype]), '-dpdf', '-bestfit')



%% Subfunctions

function streams_plot_powspctrm(freq1, freq2)

cfg = [];
cfg.layout = 'CTF275_helmet.mat';
cfg.style = 'straight';
% cfg.colormap = flipud(colormap(gray));
cfg.colorbar = 'yes';
cfg.parameter = 'powspctrm';

ft_singleplotER(cfg, freq1, freq2);
legend('high', 'low')
xlabel('frequency (Hz)')
ylabel('power')

end


function streams_plot_ttest(stat)

cfg = [];
cfg.layout = 'CTF275_helmet.mat';
cfg.style = 'straight';
% cfg.colormap = flipud(colormap(gray));
cfg.colorbar = 'yes';
cfg.parameter = 'stat';

ft_singleplotER(cfg, stat);
xlabel('frequency (Hz)')
ylabel('t-statistic')

end


function streams_plot_powspctrmtopo(freq, range)

    
cfg = [];
cfg.parameter = 'stat';
cfg.colorbar = 'yes';
cfg.style     = 'straight';
cfg.comment = 'no';
cfg.xlim = range;
cfg.layout = 'CTF275_helmet.mat';
ft_topoplotER(cfg, freq);

c = colorbar;
ylabel(c, 't-statistic')

end


