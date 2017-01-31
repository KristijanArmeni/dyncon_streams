function qsub_streams_bpl_feature(subject, data, featuredata)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

out_dir = '~/streams/data/stat/mi/meg_model/sensor/sub_fn';
feature = 'word_';
                            
[stat] = streams_bpl_feature(subject, data, featuredata, ...
                            'feature', feature, ...
                            'lag', (-30:3:30), ...
                            'method', 'mi', ...
                            'nshuffle', 500);

savename = data(53:84);
savename(14:17) = feature(1:4);
%savename = [savename(1:end-4) '_200msec_sens' savename(end-3:end)];
fullname = fullfile(out_dir, savename);
save(fullname, 'stat');

end