% function updateAssignedTracks(assignments,centroids, bboxes)
% updates each assigned track with the corresponding detection
% Inputs:   
%           assignments:               array
%           centroids:                 array
%           bboxes:                    array
% Outputs:
%           
function updateAssignedTracks(assignments,centroids, bboxes)
    global obj;
    global tracks;
    numAssignedTracks = size(assignments, 1);
    for i = 1:numAssignedTracks
    	trackIdx = assignments(i, 1);
        detectionIdx = assignments(i, 2);
        centroid = centroids(detectionIdx, :);
        bbox = bboxes(detectionIdx, :);

        % Correct the estimate of the object's location
        % using the new detection.
        tracks(trackIdx).particles= pfCorrect(tracks(trackIdx).particles, centroid);
        correct(tracks(trackIdx).kalmanFilter, centroid);
        % Replace predicted bounding box with detected
        % bounding box.
        tracks(trackIdx).bbox = bbox;

        % Update track's age.
        tracks(trackIdx).age = tracks(trackIdx).age + 1;

        % Update visibility.
        tracks(trackIdx).totalVisibleCount = ...
            tracks(trackIdx).totalVisibleCount + 1;
        tracks(trackIdx).consecutiveInvisibleCount = 0;
    end
end