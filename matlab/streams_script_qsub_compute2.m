%% run it
clear all;

subjects = {'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's09' 's10'};
features = {'perplexity' 'entropy' 'depind' 'gra_perpl' 'pho_perpl'};
%subjects = streams_subjinfo({'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's10'});
bpfreqs   = [4 8;12 18];
lpfreqs   = [1 3];
%bpfreqs   = [4 8];
%lpfreqs   = 1;

memreq = 12*1024^3;
timreq = 15*60;
for j = 1:numel(subjects)
	subject    = streams_subjinfo(subjects{j});
	audiofiles = subject.audiofile;
	for k = 1:numel(audiofiles)
		audiofile = audiofiles{k};
		tmp       = strfind(audiofile, 'fn');
		audiofile = audiofile(tmp+(0:7));
% 		for m = 1:size(bpfreqs,1)
% 			bpfreq   = bpfreqs(m,:);
% 			lpfreq   = lpfreqs(m);
% 			savefile = fullfile('/home/language/jansch/projects/streams/data/preproc/',[subject.name,'_',audiofile,'_data_',num2str(bpfreq(1),'%02d'),'-',num2str(bpfreq(2),'%02d'),'_30Hz']);
% 			qsubfeval('streams_extract_data',subject,'audiofile',audiofile,'bpfreq',bpfreq,'savefile',savefile,...
% 				'lpfreq',lpfreq,'memreq',memreq,'timreq',timreq);
% 			
% 			
% 		end
		savefile = fullfile('/home/language/jansch/projects/streams/data/featuredata/',[subject.name,'_',audiofile,'_featuredata_30Hz']);
		qsubfeval('streams_extract_feature',subject,'audiofile',audiofile,'feature',features,'savefile',savefile,...
			'memreq',memreq,'timreq',timreq);
		
	end
end
