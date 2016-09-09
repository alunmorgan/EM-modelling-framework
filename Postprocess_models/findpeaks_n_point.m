function [peaks] = findpeaks_n_point(x,y,num_points,limit)
% find the points in a dataset which are greater than the preceeding and following num_points points.
% If given one vector it assumes it is the data and generates the scale.
% If both vectors are given it assumes the second is the data and the first
% is the scale.
% limit limits the number of results (optional)
% example [peaks] = findpeaks_n_point(x,y,num_points,limit)

%% Sorting out the inputs
if nargin == 4
elseif nargin == 3
    if max(size(y)) == 1
        limit = num_points;
        num_points = y;
        y = x;
        x = linspace(1,length(y),length(y));
    else
        limit = 0;
    end
    
elseif nargin == 2
    num_points = y;
    y = x;
    x = linspace(1,length(y),length(y));
    limit = 0;
end

%% rotating vectors so that data is in the 1st dimension
x = orient_vector(x,1);
y = orient_vector(y,1);

i=1;
% %%%%%%%% ADD ZERO PADDING TO VECTOR TO ELIMINATE DEADBAND
y = [zeros(num_points,1);y;zeros(num_points,1)];
% find the time step between samples
xstep = x(2,1) - x(1,1);
x = [linspace(x(1,1)- (xstep * num_points),x(1,1)- xstep,num_points)';...
    x;...
    linspace(x(end,1)+ xstep,x(end,1)+ (xstep * num_points),num_points)'];
% iterating along the data set
for j=num_points + 1:length(x)-(num_points + 1)
    %iterating out to num_points
    for n=1:num_points
        if y(j)>=y(j-n) && y(j)>=y(j+n)
        else
            break
        end
        if n==num_points
            ind(i)= j;
            i = i + 1;
        end
    end
end
if exist('ind','var') == 0
    peaks = [];
    return
end
% finding points which are adjacent in x with the same y value and:
%only selecting the first value if it is a pair
% removing all points in the set as it is a step not a peak.
% finding edges
loc_adj_edge = find(diff(ind)==1);
loc_edge = find(diff(loc_adj_edge)==1);
% indicies to remove
if isempty(loc_edge) == 0
ind_rem_edge = loc_adj_edge(unique([loc_edge,(loc_edge +1)]));
ind(unique([ind_rem_edge,(ind_rem_edge + 1)])) = [];
end
% finding adjacent points now edges have been removed or confirmed absent.
loc_adj = find(diff(ind)==1);
if isempty(loc_adj) == 0
ind(loc_adj +1) = [];
end

peaks_x = x(ind);
peaks_y = y(ind);
peaks = cat(2,peaks_x,peaks_y);
if isempty(peaks) == 1
    return
end
% to restrict the number of peaks returned
if limit == 0
else
    peak_maxes = sort(peaks(:,2),'descend');
    if limit > size(peak_maxes,1);
        new_limit = size(peak_maxes,1);
        peaks(peaks(:,2) < peak_maxes(new_limit),:) = [];
        %        peaks = cat(1,peaks,NaN(limit -new_limit,2));
    else
        peaks(peaks(:,2) < peak_maxes(limit),:) = [];
    end
end

