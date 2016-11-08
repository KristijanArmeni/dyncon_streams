function qsub_streams_anatomy_freesurfer2(subject)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here


% Fressurfer script2
shell_script      = '/home/language/kriarm/pro/streams/code/streams/matlab/streams_anatomy_freesurfer2.sh';
mri_dir           = '/home/language/kriarm/pro/streams/data/MRI/preproc';
subject_dir       = subject;

% streams_anatomy_freesurfer2.sh
command = [shell_script, ' ', mri_dir, ' ', subject_dir];

system(command);

end

