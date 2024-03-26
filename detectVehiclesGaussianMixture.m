function detectVehiclesGaussianMixture(filename)
    tic;
    % 初始化视频读取器
    videoReader = VideoReader(filename); % 使用函数参数而非硬编码文件名
    
    % 创建前景检测器，可能需要调整参数以获得最佳效果
    foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, ...
        'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);

    blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    	'AreaOutputPort', true, 'CentroidOutputPort', true, ...
        'MinimumBlobArea', 600);
    
    videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);
    maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
    
    while hasFrame(videoReader)
        frame = readFrame(videoReader);
        % 应用前景检测器
        mask = step(foregroundDetector, frame);

        mask = imopen(mask, strel('rectangle', [3,3]));
        mask = imclose(mask, strel('rectangle', [15, 15]));
        mask = imfill(mask, 'holes');

        % Perform blob analysis to find connected components.
        [~, centroids, bboxes] = blobAnalyser.step(mask);

        % 绘制边界框
        for k = 1:length(centroids)
            frame = insertShape(frame, 'Rectangle', ...
                bboxes, 'Color', 'yellow', 'LineWidth', 2);
        end

        videoPlayer.step(frame);
        maskPlayer.step(mask);
    end
    toc;
    % 打印程序执行时间
    fprintf('Program execution time: %.2f seconds\n', toc);
end
