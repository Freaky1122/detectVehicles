% function [] = Tracking_Cars(method, file_name)
% This function is the main entrance
% Create System objects used for reading video, detecting moving objects and displaying the results.
%  使用Kalman滤波进行跟踪,将method 置0
%  使用Particle滤波进行跟踪，将method 置1
% 
% Inputs:
%              method:         int
%           file_name:         string
% Outputs:

function detectVehiclesGaussianMixtureWithTracking(method, file_name)
    tic;
    global obj;
    global tracks;
    obj = setupSystemObjects(file_name);
    tracks = initializeTracks(); % Create an empty array of tracks.
    nextId = 1; % ID of the next track
    showId = 1;
    
    % Detect moving objects, and track them across video frames.
    while ~isDone(obj.reader)
        frame = obj.reader.step();
        [centroids, bboxes, mask] = detectObjects(frame);
        
        if method == 0
            predictNewLocationsOfTracksByKalman();
        elseif method == 1
            predictNewLocationsOfTracksByParticle(mask,centroids);
        end
        [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment(method, centroids);
        updateAssignedTracks(assignments,centroids, bboxes);
        updateUnassignedTracks(unassignedTracks);
        deleteLostTracks();
        [nextId]=createNewTracks(centroids, unassignedDetections, bboxes,nextId);
        showId= displayTrackingResults(frame,mask,showId);
    end
    toc;
    % 输出检测到的车辆总数
    fprintf('Total number of detected vehicles: %d\n', showId - 1);
    % 打印程序执行时间
    fprintf('Program execution time: %.2f seconds\n', toc);
end