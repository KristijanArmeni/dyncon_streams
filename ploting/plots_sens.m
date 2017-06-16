clear all
close all

datadir = '/project/3011044.02/analysis/mi/';
savedir = '/project/3011044.02/analysis/mi/per_subject';
savedir2 = '/project/3011044.02/analysis/mi/per_subject_story';

subjects = {'s02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
freqs = {'01-03', '04-08' '09-12', '13-18'};
datatype = 'abs_ent';

% plotting parameters for topoplot
cfg                    = [];   
cfg.zlim               = 'maxabs';
cfg.comment            = 'no';
cfg.colorbar           = 'EastOutside';
cfg.style              = 'straight';
cfg.colormap           = 'jet';
cfg.layout             = 'CTF275_helmet.mat';
cfg.comment            = 'xlim';

for h = 1:numel(freqs)
    
    freq = freqs{h};
    
    figure('Color', [1 1 1]);
    for k = 1:4
    
        % specify data
        subject = subjects{k};

        % 1st figure
        filename_sens = [subject '_alls_' datatype '_' freq '_sens_30hz.mat'];
        fullfilename_sens = fullfile(savedir,['ga_' filename_sens]);
        load(fullfilename_sens);
        
        % take the time point with max MI value for topo
%         [~, I] = max(max(ga.avg));
%         ga.time = ga.time(:, I);
%         ga.avg = ga.avg(:, I);
%         ga.avg = ga.avg-min(ga.avg);
        
        % plot topography
        fprintf('plotting %s \n', filename_sens)
        subplot(2, 2, k);
        ft_topoplotER(cfg, ga);

        clear title
        title([subject ' ' datatype(1:3) ' ' datatype(end-2:end) ' ' freq]);  
%         print(fullfile(savedir, ['ga_persub_' datatype '_' freq '_1']), '-dpdf', '-fillpage');
%         clear ga
    end
    
            
    figure('Color', [1 1 1]);
    for k = 1:4
        % 2nd figure
        subject = subjects{k + 4};
        filename_sens = [subject '_alls_' datatype '_' freq '_sens_30hz.mat'];
        fullfilename_sens = fullfile(savedir,['ga_' filename_sens]);
        load(fullfilename_sens);
        
        % take the time point with max MI value for topo
%         [~, I] = max(max(ga.avg));
%         ga.time = ga.time(:, I);
%         ga.avg = ga.avg(:, I);
%         ga.avg = ga.avg-min(ga.avg);
        
        % plot topography
        fprintf('plotting %s \n', filename_sens)
        subplot(2, 2, k);
        ft_topoplotER(cfg, ga);

        clear title
        title([subject ' ' datatype(1:3) ' ' datatype(end-2:end) ' ' freq]);
%         print(fullfile(savedir, ['ga_persub_' datatype '_' freq '_2']), '-dpdf', '-fillpage');
%         clear ga
         
    end
    
    figure('Color', [1 1 1]);
    
    % 3rd figure
    filename_sens = ['ga_' datatype '_' freq '_sens_30hz.mat'];
    fullfilename_sens = fullfile(savedir2, filename_sens);
    load(fullfilename_sens);
    
    % plot timecourses
    sp = subplot(1, 2, 2);
    plot(ga.time, ga.avg);
    xlim([min(ga.time) max(ga.time)]);
    xlabel(sp, 'lag (s)',  'FontWeight', 'bold');
    ylabel(sp, 'MI (bit)', 'FontWeight', 'bold');
    
    % take the time point with max MI value for topo
%     [maxvalue, I] = max(max(ga.avg));
%     ga.time = ga.time(:, I);
%     ga.avg = ga.avg(:, I);
%     ga.avg = ga.avg-min(ga.avg);

    % plot topography
    fprintf('plotting %s \n', filename_sens)
    subplot(1, 2, 1)
    ft_topoplotER(cfg, ga);

    clear title
    title([datatype(1:3) ' ' datatype(end-2:end) ' ' freq]);

%     print(fullfile(savedir, ['ga_allsub' datatype '_' freq]), '-dpdf');
%     close all
    
%     % append separate pdfs into a single firle(requires export_fig toolbox)
%     append_names_list = dir([savedir '/ga_*sub*' datatype '_' freq '*.pdf']);
%     append_names = {append_names_list.name}';
% 
%     for i=1:numel(append_names)
% 
%         append_names{i} = fullfile(savedir, append_names{i});
% 
%     end
% 
%     jointpdf = fullfile(savedir, ['ga_' datatype '_' freq '.pdf']);
%     append_pdfs(jointpdf, append_names{:});
    
end