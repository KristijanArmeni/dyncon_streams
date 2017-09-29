
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06'});

for i = 1:num_sub
    
    subject = subjects{i};
    
    opt = {'save', 1};
    
    qsubfeval('streams_epochdefinecontrast', subject, opt, ...
                  'memreq', 1024^3 * 12,...
                  'timreq', 30*60, ...
                  'matlabcmd', 'matlab2016b');
    
end