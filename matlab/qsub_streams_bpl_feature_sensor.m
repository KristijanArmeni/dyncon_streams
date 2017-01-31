function qsub_streams_bpl_feature_sensor(subject, data, featuredata)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

out_dir = '~/streams/data/stat/mi/meg_model/source/sub_fn';
feature = 'entropy';
                            
[stat] = streams_bpl_feature(subject, data, featuredata, ...
                            'feature', feature, ...
                            'lag', (-30:6:30), ...
                            'dosource', 1, ...
                            'method', 'mi', ...
                            'nshuffle', 500);

savename = data(53:84);
savename(14:17) = feature(1:4);
savename = [savename(1:end-4) '_src' savename(end-3:end)];
fullname = fullfile(out_dir, savename);
save(fullname, 'stat');

end


