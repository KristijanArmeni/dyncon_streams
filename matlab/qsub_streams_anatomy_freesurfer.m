function qsub_streams_anatomy_freesurfer(subject)

% Fressurfer script1
shell_script      = '/home/language/kriarm/pro/streams/code/streams/matlab/streams_anatomy_freesurfer.sh';
mri_dir           = '/home/language/kriarm/pro/streams/data/MRI/preproc';
subject_dir       = subject;

% create the string pointing to streams_anatomy_freesurfer.sh
command = [shell_script, ' ', mri_dir, ' ', subject_dir];

% call the script
system(command);

end

