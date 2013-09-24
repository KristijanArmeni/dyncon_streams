

donders_path = '/home/language/jansch/projects/streams/audio/fn001078/fn001078.donders';
textgrid_path = '/home/language/jansch/projects/streams/audio/fn001078/fn001078short.TextGrid';


textgrid_data = read_textgrid(textgrid_path);
donders_data = read_donders(donders_path);

combined_data = combine_donders_textgrid(donders_data, textgrid_data);


[ time, feature_value_vector ] = get_time_series( combined_data, 'perplexity', 1200 );


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