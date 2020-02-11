function [idx, C, sumD, D] = kmeans_tns(X, k,w_pos,w_odf,varargin)

if nargin < 2
    error('stats:kmeans:TooFewInputs','At least two input arguments required.');
else
    % Cheking the weighting factors
    if~(w_pos+w_odf==1);
        error('The sum of the weighting factors should be equal to 1');
    end
end

wasnan = any(isnan(X),2);
hadNaNs = any(wasnan);
if hadNaNs
    warning(message('stats:kmeans:MissingDataRemoved'));
    X = X(~wasnan,:);
end

% n points in p dimensional space
[n, p] = size(X);

pnames = {   'distance'  'start' 'replicates' 'emptyaction' 'onlinephase' 'options' 'maxiter' 'display'};
dflts =  {'sqeuclidean' 'sample'          []  'singleton'         'on'        []        []        []};
[distance,start,reps,emptyact,online,options,maxit,display] ...
    = internal.stats.parseArgs(pnames, dflts, varargin{:});

if ischar(distance)
    distNames = {'sqeuclidean','cityblock','cosine','correlation','hamming','tns'}; %'tns' is the added distance used for the thalamic nuclei segmentation
    distance = internal.stats.getParamVal(distance,distNames,'''Distance''');
switch distance
    case 'cosine'
        Xnorm = sqrt(sum(X.^2, 2));
        if any(min(Xnorm) <= eps(max(Xnorm)))
            error(message('stats:kmeans:ZeroDataForCos'));
        end
        X = X ./ Xnorm(:,ones(1,p));
    case 'correlation'
        X = bsxfun(@minus, X, mean(X,2));
        Xnorm = sqrt(sum(X.^2, 2));
        if any(min(Xnorm) <= eps(max(Xnorm)))
            error(message('stats:kmeans:ConstantDataForCorr'));
        end
        X = X ./ Xnorm(:,ones(1,p));
    case 'hamming'
        if ~all(ismember(X(:),[0 1]))
            error(message('stats:kmeans:NonbinaryDataForHamm'));
        end
end

end

if ischar(start)
    startNames = {'uniform','sample','cluster'};
    j = find(strncmpi(start,startNames,length(start)));
    if length(j) > 1
        error(message('stats:kmeans:AmbiguousStart', start));
    elseif isempty(j)
        error(message('stats:kmeans:UnknownStart', start));
    elseif isempty(k)
        error(message('stats:kmeans:MissingK'));
    end
    start = startNames{j};
    if strcmp(start, 'uniform')
        if strcmp(distance, 'hamming')
            error(message('stats:kmeans:UniformStartForHamm'));
        end
        Xmins = min(X,[],1);
        Xmaxs = max(X,[],1);
    end
elseif isnumeric(start)
    CC = start;
    start = 'numeric';
    if isempty(k)
        k = size(CC,1);
    elseif k ~= size(CC,1);
        error(message('stats:kmeans:StartBadRowSize'));
    elseif size(CC,2) ~= p
        error(message('stats:kmeans:StartBadColumnSize'));
    end
    if isempty(reps)
        reps = size(CC,3);
    elseif reps ~= size(CC,3);
        error(message('stats:kmeans:StartBadThirdDimSize'));
    end
    
    if isequal(distance, 'correlation')
          CC = bsxfun(@minus, CC, mean(CC,2));
    end
else
    error(message('stats:kmeans:InvalidStart'));
end


if ischar(emptyact)
    emptyactNames = {'error','drop','singleton'};
    j = strmatch(lower(emptyact), emptyactNames);
    if length(j) > 1
        error('stats:kmeans:AmbiguousEmptyAction', ...
              'Ambiguous ''EmptyAction'' parameter value:  %s.', emptyact);
    elseif isempty(j)
        error('stats:kmeans:UnknownEmptyAction', ...
              'Unknown ''EmptyAction'' parameter value:  %s.', emptyact);
    end
    emptyact = emptyactNames{j};
else
    error('stats:kmeans:InvalidEmptyAction', ...
          'The ''EmptyAction'' parameter value must be a string.');
end

if ischar(online)
    j = strmatch(lower(online), {'on','off'});
    if length(j) > 1
        error('stats:kmeans:AmbiguousOnlinePhase', ...
              'Ambiguous ''OnlinePhase'' parameter value:  %s.', online);
    elseif isempty(j)
        error('stats:kmeans:UnknownOnlinePhase', ...
              'Unknown ''OnlinePhase'' parameter value:  %s.', online);
    end
    online = (j==1);
else
    error('stats:kmeans:InvalidOnlinePhase', ...
          'The ''OnlinePhase'' parameter value must be ''on'' or ''off''.');
end

% 'maxiter' and 'display' are grandfathered as separate param name/value pairs
if ~isempty(display)
    options = statset(options,'Display',display);
end
if ~isempty(maxit)
    options = statset(options,'MaxIter',maxit);
end

options = statset(statset('kmeans'), options);
display = strmatch(lower(options.Display), {'off','notify','final','iter'}) - 1;
maxit = options.MaxIter;

if ~(isscalar(k) && isnumeric(k) && isreal(k) && k > 0 && (round(k)==k))
    error('stats:kmeans:InvalidK', ...
          'X must be a positive integer value.');
% elseif k == 1
    % this special case works automatically
elseif n < k
    error('stats:kmeans:TooManyClusters', ...
          'X must have more rows than the number of clusters.');
end

% Assume one replicate
if isempty(reps)
    reps = 1;
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Done with input argument processing, begin clustering %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dispfmt = '%6d\t%6d\t%8d\t%12g';
if online, Del = NaN(n,k); end % reassignment criterion

totsumDBest = Inf;
emptyErrCnt = 0;
iter = 0;
for rep = 1:reps
    switch start
    case 'uniform'
        C = unifrnd(Xmins(ones(k,1),:), Xmaxs(ones(k,1),:));

        if isequal(distance, 'correlation')
            C = C - repmat(mean(C,2),1,p);
        end
        if isa(X,'single')
            C = single(C);
        end
    case 'sample'
        C = X(randsample(n,k),:);
        if ~isfloat(C)      % X may be logical
            C = double(C);
        end
    case 'cluster'
        Xsubset = X(randsample(n,floor(.1*n)),:);
        [dum, C] = kmeans(Xsubset, k, varargin{:}, 'start','sample', 'replicates',1);
    case 'numeric'
        C = CC(:,:,rep);
    end
    
    % Compute the distance from every point to each cluster centroid and the
    % initial assignment of points to clusters
    D = distfun(X, C, distance, 0,w_pos,w_odf);
    [d, idx] = min(D, [], 2);
    m = accumarray(idx,1,[k,1]);

    try % catch empty cluster errors and move on to next rep
        
        % Begin phase one:  batch reassignments
        [converged, ~] = batchUpdate();
        
        % Begin phase two:  single reassignments
        if online
            converged = onlineUpdate();
        end
        
        if ~converged
            warning('stats:kmeans:FailedToConverge', ...
                    'Failed to converge in %d iterations%s.',maxit,repsMsg(rep,reps));
        end

        % Calculate cluster-wise sums of distances
        nonempties = find(m>0);
        D(:,nonempties) = distfun(X, C(nonempties,:), distance, iter,w_pos,w_odf);
        d = D((idx-1)*n + (1:n)');
        sumD = accumarray(idx,d,[k,1]);
        totsumD = sum(sumD);
        
        if display > 1 % 'final' or 'iter'
            disp(sprintf('%d iterations, total sum of distances = %g',iter,totsumD));
        end

        % Save the best solution so far
        if totsumD < totsumDBest
            totsumDBest = totsumD;
            idxBest = idx;
            Cbest = C;
            sumDBest = sumD;
            if nargout > 3
                Dbest = D;
            end
        end

    % If an empty cluster error occurred in one of multiple replicates, catch
    % it, warn, and move on to next replicate.  Error only when all replicates
    % fail.  Rethrow an other kind of error.
    catch ME
        if reps == 1 || ~isequal(ME.identifier,'stats:kmeans:EmptyCluster')
            rethrow(ME);
        else
            emptyErrCnt = emptyErrCnt + 1;
            warning('stats:kmeans:EmptyCluster', ...
                    'Replicate %d terminated: empty cluster created at iteration %d.',rep,iter);
            if emptyErrCnt == reps
                error('stats:kmeans:EmptyClusterAllReps', ...
                      'An empty cluster error occurred in every replicate.');
            end
        end
    end % catch
    
end % replicates

% Return the best solution
idx = idxBest;
C = Cbest;
sumD = sumDBest;
if nargout > 3
    D = Dbest;
end

if hadNaNs
    idx = statinsertnan(wasnan, idx);
end


        %------------------------------------------------------------------

        function [converged,centroids] = batchUpdate

        % Every point moved, every cluster will need an update
        moved = 1:n;
        changed = 1:k;
        previdx = zeros(n,1);
        prevtotsumD = Inf;

        if display > 2 % 'iter'
            disp(fprintf('  iter\t phase\t     num\t         sum'));
        end

        %
        % Begin phase one:  batch reassignments
        %

        iter = 0;
        converged = false;
        while true
            iter = iter + 1;


            % Calculate the new cluster centroids and counts, and update the
            % distance from every point to those new cluster centroids
            [C(changed,:), m(changed)] = gcentroids(X, idx, changed, distance);

            if (iter==1)

               D(:,changed) = distfun(X, C(changed,:), distance, iter,w_pos,w_odf);

            else

                D(:,changed) = distfun(X, C(changed,:), distance, iter,w_pos,w_odf);
            end


            % Deal with clusters that have just lost all their members
            empties = changed(m(changed) == 0);
            if ~isempty(empties)
                switch emptyact
                case 'error'
                    error('stats:kmeans:EmptyCluster', ...
                          'Empty cluster created at iteration %d%s.',iter,repsMsg(rep,reps));
                case 'drop'
                    % Remove the empty cluster from any further processing
                    D(:,empties) = NaN;
                    changed = changed(m(changed) > 0);
                    warning('stats:kmeans:EmptyCluster', ...
                            'Empty cluster created at iteration %d%s.',iter,repsMsg(rep,reps));
                case 'singleton'
                    warning('stats:kmeans:EmptyCluster', ...
                            'Empty cluster created at iteration %d%s.',iter,repsMsg(rep,reps));

                    for i = empties
                        d = D((idx-1)*n + (1:n)'); % use newly updated distances

                        % Find the point furthest away from its current cluster.
                        % Take that point out of its cluster and use it to create
                        % a new singleton cluster to replace the empty one.
                        [dlarge, lonely] = max(d);
                        from = idx(lonely); % taking from this cluster
                        if m(from) < 2
                            % In the very unusual event that the cluster had only
                            % one member, pick any other non-singleton point.
                            from = find(m>1,1,'first');
                            lonely = find(idx==from,1,'first');
                        end
                        C(i,:) = X(lonely,:);
                        m(i) = 1;
                        idx(lonely) = i;

                        if (iter==1)

                           D(:,changed) = distfun(X, C(changed,:), distance, iter,w_pos,w_odf);

                        else

                           D(:,changed) = distfun(X, C(changed,:), distance, iter,w_pos,w_odf);

                        end


                        % Update clusters from which points are taken
                        [C(from,:), m(from)] = gcentroids(X, idx, from, distance);

                        if (iter==1)

                          D(:,from) = distfun(X, C(from,:), distance, iter, w_pos, w_odf);

                        else

                          D(:,from) = distfun(X, C(from,:), distance, iter, w_pos, w_odf);


                        end


                        %D(:,from) = distfun(X, C(from,:), distance, iter);

                        changed = unique([changed from]);


                    end

                end

            end

            centroids(:,:,iter)=C;

            % Compute the total sum of distances for the current configuration.
            totsumD = sum(D((idx-1)*n + (1:n)'));
            % Test for a cycle: if objective is not decreased, back out
            % the last step and move on to the single update phase
            if prevtotsumD <= totsumD
                idx = previdx;
                [C(changed,:), m(changed)] = gcentroids(X, idx, changed, distance);
                iter = iter - 1;
                break;
            end
            if display > 2 % 'iter'
                disp(fprintf(dispfmt,iter,1,length(moved),totsumD));
            end
            if iter >= maxit
                break;
            end

            % Determine closest cluster for each point and reassign points to clusters
            previdx = idx;
            prevtotsumD = totsumD;
            [d, nidx] = min(D, [], 2);

            % Determine which points moved
            moved = find(nidx ~= previdx);
            if ~isempty(moved)
                % Resolve ties in favor of not moving
                moved = moved(D((previdx(moved)-1)*n + moved) > d(moved));
            end
            if isempty(moved)
                converged = true;
                break;
            end
            idx(moved) = nidx(moved);

            % Find clusters that gained or lost members
            changed = unique([idx(moved); previdx(moved)])';

        end % phase one

        end % nested function

        %------------------------------------------------------------------

function converged = onlineUpdate

% Initialize some cluster information prior to phase two
switch distance
case 'cityblock'
    Xmid = zeros([k,p,2]);
    for i = 1:k
        if m(i) > 0
            % Separate out sorted coords for points in i'th cluster,
            % and save values above and below median, component-wise
            Xsorted = sort(X(idx==i,:),1);
            nn = floor(.5*m(i));
            if mod(m(i),2) == 0
                Xmid(i,:,1:2) = Xsorted([nn, nn+1],:)';
            elseif m(i) > 1
                Xmid(i,:,1:2) = Xsorted([nn, nn+2],:)';
            else
                Xmid(i,:,1:2) = Xsorted([1, 1],:)';
            end
        end
    end
case 'hamming'
    Xsum = zeros(k,p);
    for i = 1:k
        if m(i) > 0
            % Sum coords for points in i'th cluster, component-wise
            Xsum(i,:) = sum(X(idx==i,:), 1);
        end
    end
end

%
% Begin phase two:  single reassignments
%
changed = find(m' > 0);
lastmoved = 0;
nummoved = 0;
iter1 = iter;
converged = false;
while iter < maxit

    switch distance
        
    case 'tns'  % the case for segmenting the thalamic nuclei 
        for i = 1:changed
        
            mbrs = (idx == i);
            sgn = 1 - 2*mbrs; % -1 for members, 1 for nonmembers
        
            if m(i) == 1
                sgn(mbrs) = 0; % prevent divide-by-zero for singleton mbrs
            end  
            
            % The Euclidean distance between the voxels (spatial position)
            dPOS=((X(:,1)-C(i,1)).^2 + (X(:,2)-C(i,2)).^2+(X(:,3)-C(i,3)).^2).^0.5;
        
            % The Euclidean distance between the ODF coefficients
            dODF=zeros(size(dPOS));
            for jj=1:(size(X,2)-3)
                dODF=dODF+(X(:,3+jj)-C(i,3+jj)).^2;
            end
            dODF=dODF.^0.5;
        
            % The distance metric as a weighted sum
            D(:,i) = dPOS.*w_pos + dODF.*w_odf;
        
        end
    
        Del(:,i) = (m(i) ./ (m(i) + sgn)) .* D(:,i);
          
    end

    % Determine best possible move, if any, for each point.  Next we
    % will pick one from those that actually did move.
    previdx = idx;
    prevtotsumD = totsumD;
    [minDel, nidx] = min(Del, [], 2);
    moved = find(previdx ~= nidx);
    if ~isempty(moved)
        % Resolve ties in favor of not moving
        moved = moved(Del((previdx(moved)-1)*n + moved) > minDel(moved));
    end
    if isempty(moved)
        % Count an iteration if phase 2 did nothing at all, or if we're
        % in the middle of a pass through all the points
        if (iter == iter1) || nummoved > 0
            iter = iter + 1;
            if display > 2 % 'iter'
                disp(sprintf(dispfmt,iter,2,nummoved,totsumD));
            end
        end
        converged = true;
        break;
    end

    % Pick the next move in cyclic order
    moved = mod(min(mod(moved - lastmoved - 1, n) + lastmoved), n) + 1;

    % If we've gone once through all the points, that's an iteration
    if moved <= lastmoved
        iter = iter + 1;
        if display > 2 % 'iter'
            disp(sprintf(dispfmt,iter,2,nummoved,totsumD)); %#ok<*DSPS>
        end
        if iter >= maxit, break; end
        nummoved = 0;
    end
    nummoved = nummoved + 1;
    lastmoved = moved;

    oidx = idx(moved);
    nidx = nidx(moved);
    totsumD = totsumD + Del(moved,nidx) - Del(moved,oidx);

    % Update the cluster index vector, and the old and new cluster
    % counts and centroids
    idx(moved) = nidx;
    m(nidx) = m(nidx) + 1;
    m(oidx) = m(oidx) - 1;
    switch distance
    case 'sqeuclidean'
        C(nidx,:) = C(nidx,:) + (X(moved,:) - C(nidx,:)) / m(nidx);
        C(oidx,:) = C(oidx,:) - (X(moved,:) - C(oidx,:)) / m(oidx);
    case 'cityblock'
        for i = [oidx nidx]
            % Separate out sorted coords for points in each cluster.
            % New centroid is the coord median, save values above and
            % below median.  All done component-wise.
            Xsorted = sort(X(idx==i,:),1);
            nn = floor(.5*m(i));
            if mod(m(i),2) == 0
                C(i,:) = .5 * (Xsorted(nn,:) + Xsorted(nn+1,:));
                Xmid(i,:,1:2) = Xsorted([nn, nn+1],:)';
            else
                C(i,:) = Xsorted(nn+1,:);
                if m(i) > 1
                    Xmid(i,:,1:2) = Xsorted([nn, nn+2],:)';
                else
                    Xmid(i,:,1:2) = Xsorted([1, 1],:)';
                end
            end
        end
    case {'cosine','correlation'}
        C(nidx,:) = C(nidx,:) + (X(moved,:) - C(nidx,:)) / m(nidx);
        C(oidx,:) = C(oidx,:) - (X(moved,:) - C(oidx,:)) / m(oidx);
    case 'hamming'
        % Update summed coords for points in each cluster.  New
        % centroid is the coord median.  All done component-wise.
        Xsum(nidx,:) = Xsum(nidx,:) + X(moved,:);
        Xsum(oidx,:) = Xsum(oidx,:) - X(moved,:);
        C(nidx,:) = .5*sign(2*Xsum(nidx,:) - m(nidx)) + .5;
        C(oidx,:) = .5*sign(2*Xsum(oidx,:) - m(oidx)) + .5;
    end
    changed = sort([oidx nidx]);
end % phase two

end % nested function

end % main function

%------------------------------------------------------------------

function D = distfun(X, C, dist,~, w_pos, w_odf)
%DISTFUN Calculate point to cluster centroid distances.
[n,~] = size(X);
D = zeros(n,size(C,1));
nclusts = size(C,1);

    switch dist

    case 'tns' % the case for segmenting the thalamic nuclei
        for i = 1:nclusts

            % The Euclidean distance between the voxels (spatial position)
            dPOS=((X(:,1)-C(i,1)).^2 + (X(:,2)-C(i,2)).^2+(X(:,3)-C(i,3)).^2).^0.5;

            % The Euclidean distance between the ODF coefficients
            dODF=zeros(size(dPOS));
            for jj=1:(size(X,2)-3)
                dODF=dODF+(X(:,3+jj)-C(i,3+jj)).^2;
            end
            dODF=dODF.^0.5;

            % The distance metric as a weighted sum
            D(:,i) = dPOS.*w_pos + dODF.*w_odf;
        end

    end

end % function

%-----------------------------------------------------------------


%------------------------------------------------------------------

function [centroids, counts] = gcentroids(X, index, clusts, dist)
%GCENTROIDS Centroids and counts stratified by group.
[n,p] = size(X);
num = length(clusts);
centroids = NaN(num,p);
%centroids=C;
counts = zeros(num,1);

for i = 1:num
    members = (index == clusts(i));
    if any(members)
        counts(i) = sum(members);
        switch dist
            
        case 'tns' % the case for segmenting the thalamic nuclei
              centroids(i,:) = sum(X(members,:),1) / counts(i);  
    end
end
end % function

%------------------------------------------------------------------

end % function
