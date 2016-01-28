function qsub_streams_getfeatures(subject, features)

out_dir = '/home/language/kriarm/matlab/streams_output/data_model';

if ~isdir(out_dir)
    mkdir(out_dir);
    addpath(out_dir);
end

cd(out_dir);

filename = sprintf('%s_mdat', subject.name);

streams_getfeatures(subject, ...
                   'feature', features, ...
                   'audiofile', subject.audiofile(:), ...
                   'savefile', filename);

cd ~;

end

