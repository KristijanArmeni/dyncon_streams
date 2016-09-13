function [data] = streams_dss_rejectauditory(subject, data, comps, path)
%STREAMS_DSS_REJECTAUDITORY...
%  
%  ... loads the .mat file containing detected auditory components in the MEG
%  signal and rejects the components specified in the 'comps' input argument 
%  with a call to ft_rejectcomponent.
%  Streams_dss_auditory() outputs the new data structure with rejected
%  auditory components.
%  
% use as:
% 
%       data        = streams_reject_auditory(subject, data, comps, path);
% 
% input arguments
% 
%       subject       = matlab data structure as obtained from 
%       data          = MEG data structure as obtained from streams_preproc
%       comps         = array, specifiying which components to reject per
%                       subject
%       path          = string, path to the directory where .mat file with dss
%                       components is stored
% 
% custom functions called in streams_dss_rejectauditory()
% 
%       streams_existfile()
    
    [status, compfile] = streams_existfile([subject.name '_dss_audcomp.mat'], path);
    if status
      load(compfile);
    else
      error('Cannot find .mat file with components.\n Check filename or pathname variable.');
    end
    
    cfg= [];
    cfg.component = comps;
    data = ft_rejectcomponent(cfg, comp, data);

end

