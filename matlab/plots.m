clear all
close all

datadir = '/project/3011044.02/analysis/mi/';
savedir = '/project/3011044.02/analysis/mi/per_subject';

subjects = {'s02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
freqs = {'04-08', '09-12' '13-18'};
datatype = 'abs_ent';

% plotting parameters for topoplot
cfg                    = [];   
cfg.zlim               = 'maxmin';
cfg.comment            = 'no';
cfg.colorbar           = 'EastOutside';
cfg.style              = 'straight';
cfg.colormap           = 'jet';
cfg.layout             = 'CTF275_helmet.mat';

for h = 1:numel(freqs)
    
    freq = freqs{h};
    
    for k = 1:numel(subjects)
    
        % specify data
        datadir = '/project/3011044.02/analysis/mi/per_subject/';
        subject = subjects{k};

        % plot the sensor-level data
        filename_sens = [subject '_alls_' datatype '_' freq '_sens_30hz.mat'];
        fullfilename_sens = fullfile(savedir,['ga_' filename_sens]);
        load(fullfilename_sens);

        figure('Color', [1 1 1]);
        
        % plot topography
        fprintf('plotting %s \n', filename_sens)
        subplot(3, 2, 1); 
        ft_topoplotER(cfg, ga);
        clear title
        title([subject '  ' datatype(1:3) '  ' datatype(end-2:end) '  ' freq])

        % plot timecourses
        subplot(3, 2, 2)
        plot(ga.time, ga.avg);
        xlim([min(ga.time) max(ga.time)])


        % source level plot
        filename_source = ['ga_' subject '_alls_' datatype '_' freq '_lcmv_30hz'];
        functional = [filename_source '.mat'];
        sourcemodel = ['~/pro/streams/data/MRI/preproc/' subject '_sourcemodel.mat'];

        fprintf('plotting %s \n\n', filename_source)

        % load the data
        load(functional) 
        load(sourcemodel)
        load atlas_subparc374_8k

        % add anatomical information to functional struct
        s = ga;
        s.stat = ga.avg;
        s = rmfield(s, {'avg', 'var', 'dof'});
        s.brainordinate.pos = sourcemodel.pos;
        s.brainordinate.tri = sourcemodel.tri;
        s.brainordinate.parcellation = atlas.parcellation;
        s.brainordinate.parcellationlabel = atlas.parcellationlabel;

        %plot time MI timecourse for all parcels
        subplot(3, 2, 5);
        plot(s.time, s.stat);
        xlim([min(s.time), max(s.time)]);
        axis([min(s.time), max(s.time), min(min(s.stat)), max(max(s.stat))]);

        % Get the time point with maximum MI values
        [maxvalue, I] = max(max(s.stat));
        s.time = s.time(:, I);
        s.stat = s.stat(:, I);
        s.stat = s.stat-min(s.stat);

        % plot on cortical surface
        splot = ft_checkdata(s, 'datatype', 'source'); % new data structure variable for ft_plot_mesh
        titlestring = [subject '   ' datatype(end-2:end) '   ' freq ' Hz' '   ' 'lag: ' num2str(s.time) ' s'];

        h = subplot(3, 2, 3); set(h,'position',[0.10 0.35 0.30 0.30]);
        ft_plot_mesh(splot, 'vertexcolor', splot.stat);

        view(160, 10);
        h = light; set(h, 'position', [0 1 0]);
        lighting gouraud
        
        % plot the left hemisphere
        h = subplot(3, 2, 4); set(h,'position',[0.55 0.35 0.30 0.30]);
        ft_plot_mesh(splot, 'vertexcolor', splot.stat);
        
        hc = colorbar; set(hc, 'YLim', [min(splot.stat) max(splot.stat)]);
        ax = gca; % get colorobar axes
        ax.Position(3) = ax.Position(3) - ax.Position(3)*0.3; % arrange colorbar height
        ax.Position(1) = 0.6; % arrange colorbar y coordinate

        view(20, 10);
        h = light; set(h, 'position', [0 -1 0]);
        lighting gouraud
        
        print(fullfile(savedir, ['ga_' subject '_' datatype '_' freq]), '-dpdf', '-fillpage');
        close all
        
    end
    
    % append separate pdfs into a single firle(requires export_fig toolbox)
    append_names_list = dir([savedir '/ga_*' datatype '*' freq '*.pdf']);
    append_names = {append_names_list.name}';

    for i=1:numel(append_names)

        append_names{i} = fullfile(savedir, append_names{i});

    end

    jointpdf = fullfile(savedir, ['ga_' datatype '_' freq '.pdf']);
    append_pdfs(jointpdf, append_names{:});
    
end