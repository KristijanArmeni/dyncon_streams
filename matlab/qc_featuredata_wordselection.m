

load /project/3011044.02/preproc/meg/s02_featuredata1.mat % 'all quantified'
f1 = featuredata;
clear featuredata
load /project/3011044.02/preproc/meg/s02_featuredata2.mat % 'content-non-initial'
f2 = featuredata;
clear featuredata
load /project/3011044.02/preproc/meg/s02_featuredata3.mat % 'content only'
f3 = featuredata;
clear featuredata
load /project/3011044.02/preproc/meg/s02_featuredata4.mat % 'non-initial only'
f4 = featuredata;
clear featuredata

t = 1:4800; % select initial segment ('eerste deel. ga met me mee naar de Amazone etc.')

% plot
figure(1); plot(f1.time{1}(t), f1.trial{1}(end, t))
hold on;   plot(f2.time{1}(t), f2.trial{1}(end, t), 'r*')
title('non-initial content words only')

figure(2); plot(f1.time{1}(t), f1.trial{1}(end, t))
hold on;   plot(f3.time{1}(t), f3.trial{1}(end, t), 'r*')
title('content words only')

figure(3); plot(f1.time{1}(t), f1.trial{1}(end, t))
hold on;   plot(f4.time{1}(t), f4.trial{1}(end, t), 'r*')
title('non-initial words only')


