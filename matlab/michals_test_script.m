

donders_path = '/home/language/jansch/projects/streams/audio/fn001078/fn001078.donders';
textgrid_path = '/home/language/jansch/projects/streams/audio/fn001078/fn001078.TextGrid';
% 
% 
textgrid_data = read_textgrid(textgrid_path);
donders_data = read_donders(donders_path);
% 
%combined_data = combine_donders_textgrid(donders_data, textgrid_data);
% 
% 
%[ time, feature_value_vector ] = get_time_series( combined_data, 'perplexity', 1200 );
% 
% 

% audio_file = '/home/language/jansch/projects/streams/audio/audio_stories/fn001078.wav';
% data = streams_getdata_addfeature('s02', audio_file, 'perplexity', 1200)


% subject = streams_subjinfo('s02');
% cfg = [];
% cfg.dataset = subject.dataset;
% cfg.trl     = subject.trl;
% cfg.artfctdef = subject.artfctdef;
% cfg.artfctdef.reject = 'partial';
% data2 = ft_rejectartifact(cfg, data);


% switch extension
%   case 'shorttext.TextGrid' 
%     textgrid_data = read_textgrid(path);
%     data = textgrid_data;
%   case '.donders'
%     donders_data = read_donders(path);
%     data = donders_data;
%   case '.awd'
%     awd_data = read_awd(path);
%     data = awd_data;
%   case '.ort'
%     ort_data = read_ort(path);
%     data = ort_data;
% end


% 
% for i = 1:5
%     field_name{1,i} = int2str(i*3);
% end
% disp(field_name)