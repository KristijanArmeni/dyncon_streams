function qsub_streams_getfeatures(subject, features)

out_dir = '/home/language/kriarm/matlab/streams_output/data_model';

if ~isdir(out_dir)
    mkdir(out_dir);
    addpath(out_dir);
end



featuredata = streams_getfeatures(subject, ...
                                   'feature', features, ...
                                   'audiofile', subject.audiofile(:), ...
                                   'doart', 0);

filename = [subject.name '_mdat_full'];
fullname = fullfile(out_dir, filename);
save(fullname, 'featuredata')

end

