function qsub_streams_bpl_feature(subject, comps, fband)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


%defne the necessary paths for data, features and components
data_dir = '/home/language/kriarm/matlab/streams_output/data_preproc';
out_dir = '/home/language/kriarm/matlab/streams_output/stats/meg_model_MI_noDss';
comp_dir = '/home/language/kriarm/matlab/streams_output/dss_timelocked';

paths = {data_dir, out_dir, comp_dir};

% construct frequency band tag for saving
freq1 = int2str(fband(1));
freq2 = int2str(fband(2));
fname = [freq1 '_' freq2];

% construct relevant file name, feature name and filename for saving
featuredata = [subject.name '_mdat.mat'];
feature = 'entropy';
savefile = [subject.name '_MI_' feature(1:3) '_' fname '_noDss.mat'];

[~, data, ~] = streams_preproc(subject,...
                                'ramp', 'up',...
                                'bpfreq', fband, ...
                                'audiofile',subject.audiofile(:));

streams_bpl_feature(subject, data, featuredata, ...
                    'paths', paths, ... 
                    'feature', feature, ...
                    'lag', (-300:10:300), ...
                    'method', 'mi', ...
                    'savefile', savefile, ...
                    'lpfreq', fband(1)./4);

end

