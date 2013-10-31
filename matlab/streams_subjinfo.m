function [subject] = streams_subjinfo(name)

% STREAMS_SUBJINFO gets the subject specific information
%
% Use as
%   subject = streams_subjinfo(name), where name is a string representing the subject
%   name

if iscell(name)
  for k = 1:numel(name)
    subject(k,1) = streams_subjinfo(name{k});
  end
  return;
end

subject.name = name;

subject.montage          = [];
subject.montage.labelorg = {'EEG057';'EEG058';'EEG059'};
subject.montage.labelnew = {'EOGh';  'EOGv';  'ECG'};
subject.montage.tra      = eye(3);

subject.datadir   = '/home/language/jansch/MEG/3011044.02';
subject.mridir    = '/home/language/jansch/MRI/3011044.02';
subject.audiodir  = '/home/language/jansch/projects/streams/audio/audio_stories';
    

switch name
  case 'p01'
    subject.datadir   = '/home/language/jansch/MEG/';
    subject.dataset   = {fullfile(subject.datadir, 'streampilot_1200hz_20120611_01.ds');
      fullfile(subject.datadir, 'streampilot_1200hz_20120611_02.ds');
      fullfile(subject.datadir, 'streampilot_1200hz_20120611_03.ds');
      fullfile(subject.datadir, 'streampilot_1200hz_20120611_04.ds')};
    subject.trl       = [  9824 823638 0 12;
      9291 284257 0 22;
      14013 884990 0 21;
      41607 761265 0 11];
    subject.audiodir  = '/home/language/jansch/projects/streams/audio/20120611/';
    subject.audiofile = {fullfile(subject.audiodir, 'fn000249_dialogue2', 'fn000249_dialog2.wav');
      fullfile(subject.audiodir, 'fn001055_lit2', 'fn001055_lit2.wav');
      fullfile(subject.audiodir, 'fn001163_lit1.wav');
      fullfile(subject.audiodir, 'fn000752_dialog1.wav')};
    subject.awdfile     = {fullfile(subject.audiodir, 'fn000249_dialogue2', 'fn00249.awd');
      fullfile(subject.audiodir, 'fn001055_lit2', 'fn001055.awd');
      fullfile(subject.audiodir, 'fn001163.awd');
      fullfile(subject.audiodir, 'fn000752.awd')};
    subject.streamsfile = {fullfile(subject.audiodir, 'fn00249_dialogue2', 'fn000249.words.donderstest');
      fullfile(subject.audiodir, 'fn001055_lit2', 'fn001055.words.donderstest');
      fullfile(subject.audiodir, 'fn001163.words.donderstest');
      fullfile(subject.audiodir, 'fn000752.words.donderstest')};
    
    
  case 'p02'
    subject.datadir   = '/home/language/jansch/MEG/';
    subject.dataset   = {fullfile(subject.datadir, 'streampilot_1200hz_20120709_02.ds');
      fullfile(subject.datadir, 'streampilot_1200hz_20120709_02.ds');
      fullfile(subject.datadir, 'streampilot_1200hz_20120709_02.ds')};
    subject.trl       = [  35901  710002 0 11;
      869024 1432662 0 21;
      1532322 2346136 0 12];
    subject.audiodir  = '/home/language/jansch/projects/streams/audio/20120709/';
    subject.audiofile = {fullfile(subject.audiodir, 'fn000606_dialog1.wav');
      fullfile(subject.audiodir, 'fn001100_lit1.wav');
      fullfile(subject.audiodir, 'fn000249_dialog2.wav')};

    
  case 's01'
    subject.dataset   = fullfile(subject.datadir, [name, '_1200hz_20130429_01.ds']);
    subject.trl       = [  28757  297926 0  1;
      311914  597034 0  2;
      771421 1058574 0 31;
      1068018 1637770 0 32;
      1657392 2235306 0  4;
      2243405 2534693 0  5];
    subject.audiofile = {fullfile(subject.audiodir, 'fn001078.wav');
      fullfile(subject.audiodir, 'fn001155.wav');
      fullfile(subject.audiodir, 'fn001293.wav');
      fullfile(subject.audiodir, 'fn001294.wav');
      fullfile(subject.audiodir, 'fn001443.wav');
      fullfile(subject.audiodir, 'fn001481.wav')};
    % subject JM
  case 's02'
    subject.dataset   = fullfile(subject.datadir, [name, '_1200hz_20130502_01.ds']);
    %subject.trl       = [   9094  278263 0  1;
    %  307261  592369 0  2;
    %  685246  972394 0 31;
    %  997073 1566829 0 32;
    %  1649126 2227042 0  4;
    %  2306239 2597527 0  5;
    %  2632845 3214041 0  6];
    subject.audiofile = {fullfile(subject.audiodir, 'fn001078.wav');
      fullfile(subject.audiodir, 'fn001155.wav');
      fullfile(subject.audiodir, 'fn001293.wav');
      fullfile(subject.audiodir, 'fn001294.wav');
      fullfile(subject.audiodir, 'fn001443.wav');
      fullfile(subject.audiodir, 'fn001481.wav');
      fullfile(subject.audiodir, 'fn001498.wav')};
    subject.id = '43513';
  case 's03'
    subject.dataset   = fullfile(subject.datadir, [name, '_1200hz_20130516_01.ds']);
    %subject.trl       = [  17197  286367 0  1;
    %  332065  617174 0  2;
    %  660872  948021 0 31;
    %  1037798 1607556 0 32;
    %  1692193 2270110 0  4;
    %  2310449 2601717 0  5;
    %  2638236 3219433 0  6;
    %  3332969 4251833 0  7];
    subject.audiofile = {fullfile(subject.audiodir, 'fn001078.wav');
      fullfile(subject.audiodir, 'fn001155.wav');
      fullfile(subject.audiodir, 'fn001293.wav');
      fullfile(subject.audiodir, 'fn001294.wav');
      fullfile(subject.audiodir, 'fn001443.wav');
      fullfile(subject.audiodir, 'fn001481.wav');
      fullfile(subject.audiodir, 'fn001498.wav');
      fullfile(subject.audiodir, 'fn001172.wav')};
    subject.id = '78310';
    
  case 's04'
    subject.dataset   = fullfile(subject.datadir, [name, '_1200hz_20130517_01.ds']);
    subject.audiofile = {fullfile(subject.audiodir, 'fn001078.wav');
      fullfile(subject.audiodir, 'fn001155.wav');
      fullfile(subject.audiodir, 'fn001293.wav');
      fullfile(subject.audiodir, 'fn001294.wav');
      fullfile(subject.audiodir, 'fn001443.wav');
      fullfile(subject.audiodir, 'fn001481.wav');
      fullfile(subject.audiodir, 'fn001498.wav')};
    subject.id = '55066';

  case 's05'
    subject.dataset   = fullfile(subject.datadir, [name, '_1200hz_20130521_01.ds']);
    subject.audiofile = {fullfile(subject.audiodir, 'fn001078.wav');
      fullfile(subject.audiodir, 'fn001155.wav');
      fullfile(subject.audiodir, 'fn001293.wav');
      fullfile(subject.audiodir, 'fn001294.wav');
      fullfile(subject.audiodir, 'fn001443.wav');
      fullfile(subject.audiodir, 'fn001481.wav');
      fullfile(subject.audiodir, 'fn001498.wav');
      fullfile(subject.audiodir, 'fn001172.wav')};
    subject.id = '47143';
   
  case 's07'
    subject.dataset   = fullfile(subject.datadir, [name, '_1200hz_20130522_01.ds']);
    subject.audiofile = {fullfile(subject.audiodir, 'fn001078.wav');
      fullfile(subject.audiodir, 'fn001155.wav');
      fullfile(subject.audiodir, 'fn001293.wav');
      fullfile(subject.audiodir, 'fn001294.wav');
      fullfile(subject.audiodir, 'fn001443.wav');
      fullfile(subject.audiodir, 'fn001481.wav');
      fullfile(subject.audiodir, 'fn001498.wav');
      fullfile(subject.audiodir, 'fn001172.wav')};
    subject.id = '79969';

  case 's08'
    subject.dataset   = fullfile(subject.datadir, [name, '_1200hz_20130522_01.ds']);
    subject.audiofile = {fullfile(subject.audiodir, 'fn001078.wav');
      fullfile(subject.audiodir, 'fn001155.wav');
      fullfile(subject.audiodir, 'fn001293.wav');
      fullfile(subject.audiodir, 'fn001294.wav');
      fullfile(subject.audiodir, 'fn001443.wav');
      fullfile(subject.audiodir, 'fn001481.wav');
      fullfile(subject.audiodir, 'fn001498.wav')};
    subject.id = '46726';

  case 's09'
    subject.dataset   = {fullfile(subject.datadir, [name, '_1200hz_20130523_01.ds']);
      fullfile(subject.datadir, [name, '_1200hz_20130523_02.ds'])};
    subject.audiofile = {fullfile(subject.audiodir, 'fn001078.wav');
      fullfile(subject.audiodir, 'fn001155.wav');
      fullfile(subject.audiodir, 'fn001293.wav');
      fullfile(subject.audiodir, 'fn001294.wav');
      fullfile(subject.audiodir, 'fn001443.wav');
      fullfile(subject.audiodir, 'fn001481.wav');
      fullfile(subject.audiodir, 'fn001498.wav');
      fullfile(subject.audiodir, 'fn001172.wav')};
    subject.id = '71926';

  case 's10'
    subject.dataset   = fullfile(subject.datadir, [name, '_1200hz_20130606_01.ds']);
    subject.audiofile = {fullfile(subject.audiodir, 'fn001078.wav');
      fullfile(subject.audiodir, 'fn001155.wav');
      fullfile(subject.audiodir, 'fn001293.wav');
      fullfile(subject.audiodir, 'fn001294.wav');
      fullfile(subject.audiodir, 'fn001443.wav');
      fullfile(subject.audiodir, 'fn001481.wav');
      fullfile(subject.audiodir, 'fn001498.wav');
      fullfile(subject.audiodir, 'fn001172.wav')};
    subject.id = '78250';
    subject.montage.labelorg = {'EEG058';'EEG057';'EEG059'};

end

if ~strcmp(name, 's01')
  % compute trial definition
  subject.trl = streams_definetrial(subject.dataset, name);
end

% get squid artifacts
cfg = streams_artifact_squidjumps(subject);
if ~iscell(cfg)
  subject.artfctdef.squidjumps = cfg.artfctdef.zvalue;
else
  for k = 1:numel(cfg)
    subject.artfctdef.squidjumps{k} = cfg{k}.artfctdef.zvalue;
  end
end
  
% get muscle artifacts
cfg = streams_artifact_muscle(subject);
if ~iscell(cfg)
  subject.artfctdef.muscle = cfg.artfctdef.zvalue;
else
  for k = 1:numel(cfg)
    subject.artfctdef.muscle{k} = cfg{k}.artfctdef.zvalue;
  end
end

% get eogv unmixing/mixing matrices
[avgcomp, avgpre, avgeog, mixing, unmixing] = streams_artifact_eog_dss_blinks(subject);
subject.eogv.mixing   = mixing;
subject.eogv.unmixing = unmixing;
subject.eogv.avgcomp  = avgcomp;
subject.eogv.avgpre   = avgpre;
subject.eogv.avgeog   = avgeog;

