
dir      = '/project/3011044.02/analysis/freqanalysis/group5';
datatype = 'dics';
savedir  = '/project/3011044.02/results';

ivar     = 'perplexity';
fois     = {'2' '6' '10' '17' '25' '45' '75'};
prefix   = 's02-s28';
sep      = '_';

rownames      = {'delta', 'theta', 'alpha', 'low-beta', 'high-beta', 'low-gamma', 'high-gamma'}';
variablenames = {'freq' 'pos', 'pos_sumstat' 'pos_prob' 'neg', 'neg_sumstat', 'neg_prob'};
existclusters = cell(numel(fois), numel(variablenames));

%% construct table

for i = 1:numel(fois)
    
    foi = fois{i};
    
    filename = [prefix sep ivar sep foi];
    load(fullfile(dir, filename));
    
    if exist('stat4plot', 'var')
        stat_group = stat4plot;
        clear stat4plot;
    end
    
    if isstruct(stat_group.posclusters)
        signposprob  = [stat_group.posclusters.prob] < 0.05;
        signposlabel = find(signposprob);
    else
        signposprob = 0;
    end
    if isstruct(stat_group.negclusters)
        signnegprob  = [stat_group.negclusters.prob] < 0.05;
        signneglabel = find(signnegprob);
    else
        signnegprob = 0;
    end 
    
    % frequency
    existclusters{i, 1} = stat_group.freq;
    
    if sum(signposprob) > 0 
        
        posclusterstat = [stat_group.posclusters.clusterstat];
        posclusterprob = [stat_group.posclusters.prob];
        
        existclusters{i, 2} = signposlabel;
        existclusters{i, 3} = posclusterstat(signposprob);
        existclusters{i, 4} = posclusterprob(signposprob);
        
    else
        existclusters{i, 2} = 'none';
        existclusters{i, 3} = 'none';
        existclusters{i, 4} = 'none';
    end
    
    if sum(signnegprob) > 0
        
        negclusterstat = [stat_group.negclusters.clusterstat];
        negclusterprob = [stat_group.negclusters.prob];
        
        existclusters{i, 5} = signneglabel;
        existclusters{i, 6} = negclusterstat(signnegprob);
        existclusters{i, 7} = negclusterprob(signnegprob);
        
    else
        existclusters{i, 5} = 'none';
        existclusters{i, 6} = 'none';
        existclusters{i, 7} = 'none';
    end
    
end

t = array2table(existclusters, 'VariableNames', variablenames, 'RowNames', rownames);
t.Properties.Description = ivar;

%% SAVE TABLE

save(fullfile(savedir, [datatype sep ivar '_stattable.mat']), 'existclusters');
writetable(t, fullfile(savedir, [datatype sep ivar '_stattable.txt']));

