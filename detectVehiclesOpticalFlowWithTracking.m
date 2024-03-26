function detectVehiclesOpticalFlowWithTracking(method, filename)
    tic;
    % 初始化视频读取器
    videoReader = VideoReader(filename); % 使用函数参数

    % 初始化光流对象
    opticFlow = opticalFlowLK('NoiseThreshold',0.009);
    
    blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', true, 'CentroidOutputPort', true, ...
    'MinimumBlobArea', 1800);
    
 
    global tracks;
    global maskPlayer;
    global videoPlayer;
    
    maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
    videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);
    
    initializeTracks(); % Create an empty array of tracks.
    nextId = 1; % ID of the next track
    showId = 1;
    
    while hasFrame(videoReader)
        frame = readFrame(videoReader);
        frameGray = rgb2gray(frame); % 转换为灰度图
        flow = estimateFlow(opticFlow, frameGray); % 计算光流
        
        mag = flow.Magnitude;
        magThreshold = 1.1;
        mask = mag > magThreshold;
        
        mask = imdilate(mask, strel('disk', 12));
        mask = imfill(mask, 'holes');
        mask = bwareaopen(mask, 250);
        
%         [B, L] = bwboundaries(mask, 'noholes');
%         stats = regionprops(L,'Centroid', 'BoundingBox', 'Area');
%         
%         % 初始化变量
%         centroids = zeros(numel(stats), 2, 'double');
%         bboxes = zeros(numel(stats), 4, 'int32');
%         
%         for i = 1:numel(stats)
%             % 提取并保存Centroid
%             centroids(i, :) = stats(i).Centroid;
%             bboxes(i, :) = int32(stats(i).BoundingBox);
%         end
        
        [~, centroids, bboxes] = blobAnalyser.step(mask);
        if method == 0
            predictNewLocationsOfTracksByKalman();
        elseif method == 1
            predictNewLocationsOfTracksByParticle(mask,centroids);
        end

        [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(1, centroids);
    
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



          


function showId = displayTrackingResults( frame,mask,showId)
    global tracks;
    global maskPlayer;
	global videoPlayer;
    % Convert the frame and the mask to uint8 RGB.
    frame = im2uint8(frame);
    mask = uint8(repmat(mask, [1, 1, 3])) .* 255;

    minVisibleCount = 8;
    if ~isempty(tracks)

    	% Noisy detections tend to result in short-lived tracks.
        % Only display tracks that have been visible for more than
        % a minimum number of frames.
        reliableTrackInds = ...
            [tracks(:).totalVisibleCount] > minVisibleCount;
        reliableTracks = tracks(reliableTrackInds);
            
        for i=1:length(tracks)
            if reliableTrackInds(i) == 1 && tracks(i).showId == 0
                tracks(i).showId = showId;
                showId = showId + 1;
            end
        end
                    
        % Display the objects. If an object has not been detected
        % in this frame, display its predicted bounding box.
        if ~isempty(reliableTracks)
            % Get bounding boxes.
            bboxes = cat(1, reliableTracks.bbox);

            % Get ids.
            ids = int32([reliableTracks(:).showId]);

            % Create labels for objects indicating the ones for
            % which we display the predicted rather than the actual
            % location.
            labels = cellstr(int2str(ids'));
            predictedTrackInds = ...
                [reliableTracks(:).consecutiveInvisibleCount] > 0;
            isPredicted = cell(size(labels));
            isPredicted(predictedTrackInds) = {' predicted'};
            labels = strcat(labels, isPredicted);

            % Draw the objects on the frame.
            for i=1:length(labels)
            frame = insertObjectAnnotation(frame, 'circle', ...
                [tracks(i).particles(:,1),tracks(i).particles(:,2) ones(size(tracks(i).particles,1),1)*1],labels(i));
            end
            frame = insertObjectAnnotation(frame, 'rectangle', ...
                bboxes, labels);
                % Draw the objects on the mask.
                mask = insertObjectAnnotation(mask, 'rectangle', ...
                    bboxes, labels);
        end
    end

	% Display the mask and the frame.
    maskPlayer.step(mask);
	videoPlayer.step(frame);
end