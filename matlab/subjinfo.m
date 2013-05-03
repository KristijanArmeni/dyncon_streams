function [subject] = subjinfo(name)

% SUBJINFO gets the subject specific information
% 
% Use as
%   subject = subjinfo(n), where n is a scalar representing the subject
%   number

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
  subject.datadir   = '/home/language/jansch/MEG/streams';
  subject.dataset   = fullfile(subject.datadir, [name, '_1200hz_20130429_01.ds']);
  subject.trl       = [  28757  297926 0  1;
                        311914  597034 0  2;
                        771421 1058574 0 31;
                       1068018 1637770 0 32;
                       1657392 2235306 0  4;
                       2243405 2534693 0  5];
  subject.audiodir  = '/home/language/jansch/projects/streams/audio/';
  subject.audiofile = {fullfile(subject.audiodir, 'fn001078.wav');
                       fullfile(subject.audiodir, 'fn001155.wav');
                       fullfile(subject.audiodir, 'fn001293.wav');
                       fullfile(subject.audiodir, 'fn001294.wav');
                       fullfile(subject.audiodir, 'fn001443.wav');
                       fullfile(subject.audiodir, 'fn001481.wav')};
case 's02'
  subject.datadir   = '/home/language/jansch/MEG/streams';
  subject.dataset   = fullfile(subject.datadir, [name, '_1200hz_20130502_01.ds']);
  subject.trl       = [   9094  278263 0  1;
                        307261  592369 0  2;
                        685246  972394 0 31;
                        997073 1566829 0 32;
                       1649126 2227042 0  4;
                       2306239 2597527 0  5;
                       2632845 3214041 0  6];
  subject.audiodir  = '/home/language/jansch/projects/streams/audio/';
  subject.audiofile = {fullfile(subject.audiodir, 'fn001078.wav');
                       fullfile(subject.audiodir, 'fn001155.wav');
                       fullfile(subject.audiodir, 'fn001293.wav');
                       fullfile(subject.audiodir, 'fn001294.wav');
                       fullfile(subject.audiodir, 'fn001443.wav');
                       fullfile(subject.audiodir, 'fn001481.wav');
                       fullfile(subject.audiodir, 'fn001498.wav')};
end
