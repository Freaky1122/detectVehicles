% function [assignments, unassignedTracks, unassignedDetections] = ...
%            detectionToTrackAssignment(centroids)
% compute an assignment which minimizes the total cost
% Inputs:   
%           centroids:                 array
% Outputs:
%           assignments:               array
%           unassignedTracks:          array
%           unassignedDetections:      array
function [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment(method, centroids)
    global obj;
    global tracks;
	nTracks = length(tracks);
	nDetections = size(centroids, 1);
	% Compute the cost of assigning each detection to each track.
	cost = zeros(nTracks, nDetections);
	for i = 1:nTracks
        if method == 0
            cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
        elseif method == 1
            cost(i, :) = distance(mean(tracks(i).particles), centroids); 
        end   
    end
    
	% Solve the assignment problem.
    if method == 0
        costOfNonAssignment = 10;
    elseif method == 1
        costOfNonAssignment = 20;
    end
        
        
	[assignments, unassignedTracks, unassignedDetections] = ...
        assignDetectionsToTracks(cost, costOfNonAssignment);
end