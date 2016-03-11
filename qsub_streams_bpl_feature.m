function qsub_streams_bpl_feature(subject, data, featuredata)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%defne the necessary paths for data, features and components
data_dir = '/home/language/kriarm/streams/streams_output/data_preproc/';
out_dir = '/home/language/kriarm/matlab/streams_output/stats/meg_model_MI_noDss';
comp_dir = '/home/language/kriarm/matlab/streams_output/dss_timelocked';

paths = {data_dir, out_dir, comp_dir};
feature = 'entropy';
                            
[stat] = streams_bpl_feature(subject, data, featuredata, ...
                            'paths', paths, ... 
                            'feature', feature, ...
                            'lag', (-30:3:30), ...
                            'method', 'mi', ...
                            'nshuffle', 50);

savename = data;
savename(14:17) = feature(1:4);
fullname = fullfile(out_dir, savename);
save(fullname, 'stat');

end

