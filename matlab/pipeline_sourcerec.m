clear all

if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

%% INITIALIZE

[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06', 's09', 's01'});
ivars = {'log10perp'};
foilim = {[40 40]};

%% SUBJECT LOOP

for k = 1:numel(foilim)

    cfgfreq.foilim = foilim{k};
    freq = cfgfreq.foilim(1);
    
    if freq < 8; taper = 'hanning'; end
    if freq > 8 && freq < 30; taper = 'dpss'; tapsmofrq = 4; end
    if freq > 30 && freq < 90; taper = 'dpss'; tapsmofrq = 8; end
   
    cfgfreq.taper = taper;
    if strcmp(taper, 'dpss'); cfgfreq.tapsmofrq = tapsmofrq; end
    
    cfgdics.freq = cfgfreq.foilim(1);

    for i = 1:numel(ivars)

    ivar = ivars{i};
    
        for kk = 1:num_sub

        subject = subjects{kk};
        qsubfeval('streams_dics', cfgfreq, cfgdics, subject, ivar, ...
                  'memreq', 1024^3 * 12,...
                  'timreq', 240*60,...
                  'batchid', 'streams_dics', ...
                  'matlabcmd', 'matlab2016b');
        
        end
        
    end
    
end