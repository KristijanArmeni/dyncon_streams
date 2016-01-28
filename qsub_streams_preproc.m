function qsub_streams_preproc(subject)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

out_dir = '/home/language/kriarm/matlab/streams_output/data_preproc';
cd(out_dir);

[subject, data, audio] = streams_preproc(subject,...
                                        'ramp', 'up',...
                                        'bpfreq', [0.5 40], ...
                                        'audiofile',subject.audiofile(:), ...
                                        'savefile', sprintf('%s_data',subject.name), ...
                                        'append', 1);

cd ~;

end

