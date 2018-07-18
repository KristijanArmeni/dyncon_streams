function t = script_clustertable(ivar, freq, iteration)

dir      = ['/project/3011044.02/analysis/freqanalysis/source/group' iteration];
datatype = 'source';
savedir  = '/project/3011044.02/results';

%ivar     = 'entropy';
if isempty(freq)
    fois = {'2', '6', '10', '16', '25', '45', '75'};
else
    fois = freq;
end

prefix   = 's02-s28';
sep      = '_';

rownames      = fois';
variablenames = {'freq' 'num_pos', 'num_neg'};
existclusters = cell(numel(fois), numel(variablenames));

error_rate    = 0.05;
%% construct table

for i = 1:numel(fois)
    
    foi = fois{i};
    
    filename = [prefix sep ivar sep foi];
    load(fullfile(dir, filename));
    
    if exist('stat4plot', 'var')
        stat_group = stat4plot;
        clear stat4plot;
    end
    
    % check whether any group statistic is controlled at selected error
    % rate
    if isstruct(stat_group.posclusters)
        signposprob  = [stat_group.posclusters.prob] < error_rate;
        signposlabel = find(signposprob);
    else
        signposprob = 0;
    end
    if isstruct(stat_group.negclusters)
        signnegprob  = [stat_group.negclusters.prob] < error_rate;
        signneglabel = find(signnegprob);
    else
        signnegprob = 0;
    end 
    
    % Build table with frequencies in rows ans stat info in columns
    existclusters{i, 1} = stat_group.freq;
    
    if sum(signposprob) > 0 % check if any prob is trure (below error_rate)
        
        posclusterstat = [stat_group.posclusters.clusterstat];
        posclusterprob = [stat_group.posclusters.prob];
        
        existclusters{i, 2} = numel(signposlabel);
        %existclusters{i, 3} = posclusterstat(signposprob);
        %existclusters{i, 4} = posclusterprob(signposprob);
        
    else % in case of no clusters can be controlled at selected error_rate
        existclusters{i, 2} = 'none';
        %existclusters{i, 3} = 'none';
        %existclusters{i, 4} = 'none';
    end
    
    if sum(signnegprob) > 0
        
        negclusterstat = [stat_group.negclusters.clusterstat];
        negclusterprob = [stat_group.negclusters.prob];
        
        existclusters{i, 3} = numel(signneglabel);
        %existclusters{i, 6} = negclusterstat(signnegprob);
        %existclusters{i, 7} = negclusterprob(signnegprob);
        
    else
        existclusters{i, 3} = 'none';
        %existclusters{i, 6} = 'none';
        %existclusters{i, 7} = 'none';
    end
    
end

t = array2table(existclusters, 'VariableNames', variablenames, 'RowNames', rownames);
t.Properties.Description = ivar;

%% SAVE TABLE

%save(fullfile(savedir, [datatype sep ivar '_stattable.mat']), 'existclusters');
%writetable(t, fullfile(savedir, [datatype sep ivar '_stattable.txt']));

end
