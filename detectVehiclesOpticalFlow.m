function detectVehiclesOpticalFlow(filename)
    tic;
    % 初始化视频读取器
    videoReader = VideoReader(filename); % 使用函数参数

    % 初始化光流对象
    opticFlow = opticalFlowLK('NoiseThreshold',0.009);

    videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);
    maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
    
    blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', true, 'CentroidOutputPort', true, ...
    'MinimumBlobArea', 600);
    
    while hasFrame(videoReader)
        frame = readFrame(videoReader);
        frameGray = rgb2gray(frame); % 转换为灰度图
        flow = estimateFlow(opticFlow, frameGray); % 计算光流
        
        mag = flow.Magnitude;
        magThreshold = 1;
        mask = mag > magThreshold;
        
        mask = imdilate(mask, strel('disk', 10));
        mask = imfill(mask, 'holes');
        mask = bwareaopen(mask, 250);
        
        [B, L] = bwboundaries(mask, 'noholes');
        stats = regionprops(L, 'BoundingBox', 'Area');
        
        minArea = 1000;
        
        for k = 1:length(stats)
            if stats(k).Area > minArea
                frame = insertShape(frame, 'Rectangle', ...
                    stats(k).BoundingBox, 'Color', 'yellow', 'LineWidth', 2);
            end
        end
        videoPlayer.step(frame);
        maskPlayer.step(mask);
    end
    toc;
    % 打印程序执行时间
    fprintf('Program execution time: %.2f seconds\n', toc);
end
