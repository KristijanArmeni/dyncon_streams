
% read_donders does not seem to work - needs a simpler way of parsing the
% text

f = 'fn000249.donders';
path = strcat('/home/language/jansch/projects/streams/audio/20120709/fn000249_dialogue2/', f);

data = read_donders(path);

disp(data)

% 
% for i = 1:5
%     field_name{1,i} = int2str(i*3);
% end
% disp(field_name)