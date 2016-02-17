%% run it
clear all;

subjects = {'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's09' 's10'};
features = {'perplexity' 'entropy'};
%subjects = streams_subjinfo({'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's10'});
bpfreqs   = [4 8;12 18];

memreq = 4*1024^3;
timreq = 20*60;
for j = 1:numel(subjects)
	subject    = streams_subjinfo(subjects{j});
	audiofiles = subject.audiofile;
	for k = 1:numel(audiofiles)
		audiofile = audiofiles{k};
		tmp       = strfind(audiofile, 'fn');
		audiofile = audiofile(tmp+(0:7));
		for m = 1:size(bpfreqs,1)
			bpfreq   = bpfreqs(m,:);
			datafile = fullfile('/home/language/jansch/projects/streams/data/preproc/',[subject.name,'_',audiofile,'_data_',num2str(bpfreq(1),'%02d'),'-',num2str(bpfreq(2),'%02d'),'_30Hz']);
			featurefile = fullfile('/home/language/jansch/projects/streams/data/featuredata/',[subject.name,'_',audiofile,'_featuredata_30Hz']);
			
			load(datafile);
			load(featurefile);
			
			for p = 1:numel(features)
				feature  = features{p};
				
				savefile = fullfile('/home/language/jansch/projects/streams/data/mutualinformation/',[subject.name,'_',audiofile,'_',feature,'_30Hz']);
				
				qsubfeval('streams_bpl_feature',subject,data,featuredata,'feature',feature,'lag',-30:3:30,'nshuffle',20,'savefile',savefile,...
					'memreq',memreq,'timreq',timreq);
			end
			
		end
	end
end