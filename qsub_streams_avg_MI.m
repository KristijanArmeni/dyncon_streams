function qsub_streams_avg_MI(subjects, fband, featureset)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

stat_avg = [];
stat_avg.stat = zeros(273, 61);
save_dir = '/home/language/kriarm/matlab/streams_output/stats';
savename = ['avg' featureset fband];

for kk = 1:numel(subjects)

    filename = [subjects{kk} featureset fband];
    load(filename)
    
    stat_temp = stat;
    stat_avg.stat = stat_avg.stat + stat_temp.stat;
    
end
    stat_avg.label      = stat.label;
    stat_avg.time       = stat.time;
    stat_avg.stat       = stat_avg.stat./kk;
    stat_avg.statshuf   = stat.statshuf;
    stat_avg.dimord     = stat.dimord;
    
    cd(save_dir)
    save(savename, 'stat_avg');

end

