% function predictNewLocationsOfTracksByKalman(mask,centroids)
% Use the Kalman filter to predict the centroid of each 
% track in the current frame, and update its bounding box accordingly.
% Inputs:
%           mask:              array 
%           centroids:         array
% Outputs:
% 

function predictNewLocationsOfTracksByKalman()
    global obj;
    global tracks;
    for i = 1:length(tracks)
    	bbox = tracks(i).bbox;
        % Predict the current location of the track.
        predictedCentroid = predict(tracks(i).kalmanFilter);
            
        % Shift the bounding box so that its center is at
        % the predicted location.
        predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
        tracks(i).bbox = [predictedCentroid, bbox(3:4)];
    end
end