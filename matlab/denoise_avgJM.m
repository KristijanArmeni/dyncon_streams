function [params, s_new, avg] = denoise_avgJM(params, s, state)
% DSS denoising function: Quasiperiodic averaging respecting 
%   trial boundaries in the original trials
%
%   [params, s_new] = denoise_avg(params, s, state)
%     params                Function specific modifiable parameters
%     params.tr             Trigger indices
%     params.begin          how many samples after the trigger the ON state
%                           begins, if vectorial each element belongs to a 
%                           trigger
%     params.end            how many samples after the trigger the ON state
%                           ends, if vectorial each element belongs to a trigger 
%     state                 DSS algorithm state
%     s                     Source signal estimate, matrix of row vector
%                           signals 
%     s_new                 Denoised signal estimate

% Copyright (C) 2004, 2005 DSS MATLAB package team (dss@cis.hut.fi).
% Distributed by Laboratory of Computer and Information Science,
% Helsinki University of Technology. http://www.cis.hut.fi/projects/dss/.
% $Id: denoise_avg.m,v 1.19 2005/12/02 12:23:18 jaakkos Exp $

if nargin<3 || ~isstruct(state)
    params.name = 'Quasiperiodic averaging with known triggers';
    params.description = '';
    params.param = {'fs','tr','tr_inds','begin','end'};
    params.param_value ={[], [], [], [], []};
    params.param_type = {'scalar','vector','vector','scalar','scalar'};
    params.param_desc = {'sampling frequency','trigger indices','used trigger indices','beginning of the ON mask','end of the ON mask'};
    params.approach = {'pca','defl','symm'};
    params.alpha = {};
    params.beta = {'beta_global'};
    return;
end

% not available, using as direct indices
tr_begin = params.tr_begin(:);
tr_end = params.tr_end(:);

if length(params.tr)==length(state.X)
  % trigger not as indices but as signal
  error('trigger indices must be extracted from the trigger signal first (automatic extraction not implemented yet)');
end

if ~isfield(params,'tr_inds')
  tr_inds = params.tr(:);
else
  tr_inds = params.tr_inds(:);
end

if isfield(params, 'demean') && params.demean==1
  demeanflag = true;
end

s_new = zeros(size(s));

pst   = max(tr_end-tr_inds);
pre   = max(tr_inds-tr_begin);
avg   = zeros(size(s,1),pre+pst+1);
cnt   = zeros(size(avg));

% calculating the average
for i = 1 : length(tr_inds)
  begsmp = pre - (tr_inds(i)-tr_begin(i)) + 1;
  endsmp = begsmp + (tr_end(i)-tr_begin(i));
  tmp    = s(:,tr_begin(i):tr_end(i));
  if demeanflag,
    tmp    = tmp - mean(tmp,2)*ones(1,size(tmp,2));
  end
  avg(:,begsmp:endsmp) = avg(:,begsmp:endsmp) + tmp;
  cnt(:,begsmp:endsmp) = cnt(:,begsmp:endsmp) + 1;
end
avg = avg  ./ cnt;
% reconstructing the signals
for i = 1 : length(tr_inds)
  begsmp = pre - (tr_inds(i)-tr_begin(i)) + 1;
  endsmp = begsmp + (tr_end(i)-tr_begin(i));
  s_new(:,tr_begin(i):tr_end(i))=s_new(:,tr_begin(i):tr_end(i)) + avg(:,begsmp:endsmp);
end
