function sourcemodel = streams_parcellate_leadfield(sourcemodelin, parcellation, varargin)

param = ft_getopt(varargin, 'parcellationparam', 'parcellation');

nval = max(parcellation.(param));
for k = 1:nval
  sel = parcellation.(param)==k;
  lf{k,1} = cat(2, sourcemodelin.leadfield{sel});
  [u,s,v] = svd(lf{k},'econ');
  S{k,1}  = diag(s);
  
  selcomp = cumsum(S{k,1}.^2)./sum(S{k,1}.^2)<0.95;
  %lf{k,1} = lf{k,1}*v(:,selcomp);
  lf{k,1} = u(:,selcomp);
  pos(k,:) = mean(sourcemodelin.pos(sel,:));
end

sourcemodel           = [];
sourcemodel.label     = parcellation.([param,'label']);
sourcemodel.leadfield = lf;
sourcemodel.S         = S;
sourcemodel.pos       = pos;
sourcemodel.inside    = true(size(pos,1),1);
