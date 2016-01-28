%% STREAMS ANALYSIS PIPELINE

clear all

if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

%% RAW DATA PREPROCESSING

out_dir = '/home/language/kriarm/matlab/streams_output/data_preproc';
cd(out_dir);

subjects = {'s01', 's02'};

% begin subject loop

for k = 1:numel(subjects)
    
    subject = streams_subjinfo(subjects{k});
    
    qsubfeval('qsub_streams_preproc', subject, ...
                                'memreq', 1024^3 * 12, ...
                                'timreq', 60*60, ...
                                'batchid', 'streams_preproc');
end

%% AUDITORY COMPONENT ANALYSIS
clear all

subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};

inp_dir = '/home/language/kriarm/matlab/streams_output/data_preproc';

cd(inp_dir);

jobid_array_tlck = cell(1, numel(subjects));

for k = 1:numel(subjects)
    
    subject = streams_subjinfo(subjects{k});
    load(sprintf('%s_data.mat', subject.name));
    
    jobid_array_tlck{k} = qsubfeval('qsub_streams_dss_auditory', data, subject, ...
                                    'memreq', 1024^3 * 12,...
                                    'timreq', 60*60,...
                                    'batchid', 'streams_tlck');
end

%% CREATE MODEL OUTPUT

subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
features = {'entropy', 'perplexity'};


for k = 1:numel(subjects)
    
    subject = streams_subjinfo(subjects{k});
    
    qsubfeval('qsub_streams_getfeatures', subject, features, ...
                                        'memreq', 1024^3 * 12,...
                                        'timreq', 60*60,...
                                        'batchid', 'streams_features');
end

%% AUDIOCORTICO MI

subjects = {'s08'};
components = {[1,2]};
freqs = {[1 4], [4 8], [8 12], [12 30], [40 60], [60 90], [0.5 40]};

for k = 1 : numel(subjects)
    
    subject = streams_subjinfo(subjects{k});
    comps = components{k};
    
    for kk = 1 : numel(freqs)
    
        bpfreq = freqs{kk};
        
        qsubfeval('qsub_streams_megaudio_MI', subject, bpfreq, comps,...
                                    'memreq', 1024^3 * 15,...
                                    'timreq', 120*60,...
                                    'batchid', 'streams_MI');
        
    end
    
end

%% BAND-PASS-LIMITED DATA ~ FEATURE ANALYSIS

%define subject list & auditory component list for each subject
subjects = {'s03', 's04', 's07', 's09', 's10'};
components = {[1,2,3],[1,2],[1,2],[1,2,3],[1,2]};
freqs = {[0.5 40], [1 4], [4 8], [8 12], [12 30], [40 60], [60 90]};

%check
if numel(subjects) ~= numel(components)
    error('Number of subjects and specified components do not match');
end

for k = 1:numel(subjects)
    
    subject = streams_subjinfo(subjects{k});
    comps = components{k};
    
    for kk = 1:numel(freqs)
        
        fband = freqs{kk};
    
        qsubfeval('qsub_streams_bpl_feature', subject, comps, fband, ...
                                    'memreq', 1024^3 * 20,...
                                    'timreq', 120*60,...
                                    'batchid', 'streams_feature');
    end
    
end

% back to home dir
cd ~;

%% MI AVERAGING

freqs = {'_1_40', '_1_4', '_4_8', '_8_12', '_12_30', '_40_60', '_60_90'};
subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
measure = {'_MI_per'};

for h = 1:numel(measure)

    for k = 1:numel(freqs)

        featureset = measure{h};
        fband = freqs{k};
        
        stat_avg = [];
        stat_avg.stat = zeros(273, 61);
        save_dir = '/home/language/kriarm/matlab/streams_output/stats/meg_model_MI_noDss';
        savename = ['avg' featureset fband '_noDss.mat'];

        for kk = 1:numel(subjects)

            filename = [subjects{kk} featureset fband '_noDss.mat'];
            load(filename)

            stat_temp = stat;
            stat_avg.stat = stat_avg.stat + stat_temp.stat;

        end
        
        stat_avg.label      = stat.label;
        stat_avg.time       = stat.time;
        stat_avg.stat       = stat_avg.stat./kk;
        stat_avg.statshuf   = stat.statshuf;
        stat_avg.dimord     = stat.dimord;

        savein = fullfile(save_dir, savename);
        save(savein, 'stat_avg');

    end
        
end

%% AUDIOCORTICO MI PER SUBJECTS & FREQ BANDS

freqs = {'_1_4', '_4_8', '_8_12', '_12_30', '_40_60', '_60_90'};
subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};

for k = 1:numel(subjects)

        save_dir = '/home/language/kriarm/matlab/streams_output/stats/meg_audio_MI';
        savename = [subjects{k} '_meg_audio' '.mat'];

        for kk = 1:numel(freqs)
            
            fband = freqs{kk};
            
            filename = [subjects{k} fband '_MI.mat'];
            load(filename)
            
            if kk == 1
                stat_all.mi = stat.mi;
            else
                stat_temp = stat;
                stat_all.mi = horzcat(stat_all.mi, stat_temp.mi);
            end
        end
        
        stat_all.label      = stat.label{freqs};
        stat_all.bpfreqs    = freqs;
        stat_all.statshuf   = stat.statshuf;
        stat_all.dimord     = 'chan_freq';

        cd(save_dir)
        save(savename, 'stat_all');

end
