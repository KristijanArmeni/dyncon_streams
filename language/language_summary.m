

load language_data.mat;

[G, stories]  = findgroups(data_table.story_ID);

count = @(x, y) [sum(~isnan(x)), max(y)];
stats_mean = @(x) [nanmean(x), nanstd(x)];

counts = splitapply(count, data_table.nchar, data_table.sentence_nr, G);
nchar = splitapply(stats_mean, data_table.nchar, G);
freq = splitapply(stats_mean, data_table.lg10wf, G);
perp = splitapply(stats_mean, data_table.lg10perp, G);
entr = splitapply(stats_mean, data_table.entropy, G);

summary = table(stories, counts, nchar, freq, perp, entr);


%% 
clear all
datadir = '/project/3011044.02/analysis/freqanalysis/ivars';

filenames = dir(fullfile(datadir, '*ivars2*'));
filenames = {filenames.name};

% load in subject-specific ivars and put into a single matrix with sID
data.trial = cell(1, numel(filenames));
for i = 1:numel(filenames)
   
    file = filenames{i};
    load(fullfile(datadir, file))
    
    ivars.trial(:,6) = i;
    data.trial{i} = ivars.trial;
    
end


d = cell2mat(data.trial');
dc = num2cell(d); 

l = ivars.label;
l(6) = {'subject'};
dt = cell2table(dc, 'VariableNames', l');

% reorder columns
dt = [dt(:, 6) dt(:,1:5)];

% save table
tablename = 'ivars_table';
savetable = fullfile(datadir, tablename);
save(savetable, 'dt');

%% SUMMARY STATS
sum_sub = grpstats(dt, 'subject');
sum_str = grpstats(dt, 'story');

% entropy conditions
qe = quantile(dt.entropy, [0 0.25 0.50 0.75 1]); % extract the three quantile values
[entropy_binned, ~] = discretize(dt.entropy, qe, 'categorical', {'qr1', 'qr2', 'qr3', 'qr4'});

qp = quantile(dt.log10perp, [0 0.25 0.50 0.75 1]); % extract the three quantile values
[perplexity_binned, ~] = discretize(dt.log10perp, qp, 'categorical', {'qr1', 'qr2', 'qr3', 'qr4'});

entropy_binned_table = table(entropy_binned, 'VariableNames', {'entropy_bin'});
perplexity_binned_table = table(perplexity_binned, 'VariableNames', {'log10perp_bin'});

dt = [dt, perplexity_binned_table, entropy_binned_table];



%% HISTOGRAMS

m = 'log10perp';
col_indx = strcmp(l, m);
d_sel = d(:, col_indx);

q = quantile(d_sel, [0.25 0.50 0.75]); % extract the three quantile values

% index trials that fall into each of the quartile ranges
qr1 = d_sel <= q(1);
qr2 = d_sel > q(1) & d_sel <= q(2);
qr3 = d_sel > q(2) & d_sel <= q(3);
qr4 = d_sel > q(3);

figure;
histogram(d_sel(qr2)', 'facealpha',.5,'edgecolor','none')
hold on;
histogram(d_sel(qr3)', 'facealpha',.5,'edgecolor','none')
title([m ' (8 subjects)']);
xlabel(['mean ' m]);
ylabel('number of trials');
legend(sprintf('low (N = %d)', sum(qr1)), sprintf('high (N = %d)', sum(qr4)));

ctrl = 'log10wf';
ctrl_idx = strcmp(l, ctrl);
d_ctrl = d(:, ctrl_idx);

figure;
histogram(d_ctrl(qr2)', 'facealpha',.5,'edgecolor','none')
hold on;
histogram(d_ctrl(qr3)', 'facealpha',.5,'edgecolor','none')
hold on;
title([m ' (8 subjects)']);
xlabel(['mean ' ctrl]);
ylabel('number of trials');
legend(sprintf('low (N = %d)', sum(qr1)), sprintf('high (N = %d)', sum(qr4)));

%% PER SUBJECT
figure;
for k = 1:numel(data.trial)
    
    d = data.trial{k};
    l = ivars.label;

    m = 'log10perp';
    col_indx = strcmp(l, m);
    d_sel = d(:, col_indx);

    q = quantile(d_sel, [0.25 0.50 0.75]); % extract the three quantile values

    % index trials that fall into each of the quartile ranges
    qr1 = d_sel <= q(1);
    qr2 = d_sel > q(1) & d_sel <= q(2);
    qr3 = d_sel > q(2) & d_sel <= q(3);
    qr4 = d_sel > q(3);

%     figure;
%     histogram(d_sel(qr1)', 'facealpha',.5,'edgecolor','none')
%     hold on;
%     histogram(d_sel(qr4)', 'facealpha',.5,'edgecolor','none')

    ctrl = 'log10perp';
    ctrl_idx = strcmp(l, ctrl);
    d_ctrl = d(:, ctrl_idx);

    subplot(4, 4, k);
    histogram(d_ctrl(qr1)', 'facealpha',.5,'edgecolor','none')
    hold on;
    histogram(d_ctrl(qr4)', 'facealpha',.5,'edgecolor','none')
    hold on;
    title([num2str(k) ' ' m]);
    xlabel(ctrl);
    ylabel('count');
    legend(sprintf('low (N = %d)', sum(qr1)), sprintf('high (N = %d)', sum(qr4)));
end


figure;
for k = 1:numel(data.trial)
    
    d = data.trial{k};
    l = ivars.label;

    m = 'log10perp';
    col_indx = strcmp(l, m);
    d_sel = d(:, col_indx);

    q = quantile(d_sel, [0.25 0.50 0.75]); % extract the three quantile values

    % index trials that fall into each of the quartile ranges
    qr1 = d_sel <= q(1);
    qr2 = d_sel > q(1) & d_sel <= q(2);
    qr3 = d_sel > q(2) & d_sel <= q(3);
    qr4 = d_sel > q(3);

%     figure;
%     histogram(d_sel(qr1)', 'Normalization', 'pdf', 'facealpha',.5,'edgecolor','none')
%     hold on;
%     histogram(d_sel(qr4)', 'Normalization', 'pdf', 'facealpha',.5,'edgecolor','none')

    ctrl = 'log10perp';
    ctrl_idx = strcmp(l, ctrl);
    d_ctrl = d(:, ctrl_idx);

    subplot(4, 4, k);
    histogram(d_ctrl(qr1)', 'Normalization', 'probability',  'facealpha',.5,'edgecolor','none')
    hold on;
    histogram(d_ctrl(qr4)', 'Normalization', 'probability',  'facealpha',.5,'edgecolor','none')
    hold on;
    title([num2str(k) ' ' m]);
    xlabel(ctrl);
    ylabel('count');
    legend(sprintf('low (N = %d)', sum(qr1)), sprintf('high (N = %d)', sum(qr4)));
end