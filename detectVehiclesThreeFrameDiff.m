function detectVehiclesThreeFrameDiff(videoFile)
    tic;
    videoReader = VideoReader("Data/Sample.mp4");

    % 读取前两帧
    frame1 = rgb2gray(readFrame(videoReader));
    frame2 = rgb2gray(readFrame(videoReader));
    
    videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);
    maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
    
    while hasFrame(videoReader)
        frame = readFrame(videoReader);
        frame3 = rgb2gray(frame); % 读取下一帧
        
        % 计算相邻帧的差异
        diff12 = abs(frame1 - frame2);
        diff23 = abs(frame2 - frame3);
        
        % 对差异图像进行二值化
        thresh = 30; % 阈值，可根据实际情况调整
        binaryImage12 = diff12 > thresh;
        binaryImage23 = diff23 > thresh;
        
        % 取两个二值化图像的交集
        mask = binaryImage12 & binaryImage23;
        
        % 应用形态学操作来去除噪声并填充检测区域
        mask = imdilate(mask, strel('disk', 9)); % 合并相邻区域
        mask = imfill(mask, 'holes');
        

        % 过滤掉小于特定面积的区域
        minArea = 500; % 面积阈值，可根据实际情况调整
        mask = bwareaopen(mask, minArea);
        
        % 计算检测到的区域的边界框
        [B, L] = bwboundaries(mask, 'noholes');
        stats = regionprops(L, 'BoundingBox', 'Area');
        
        % 如果有重叠的框，只显示最大的框
        if numel(stats) > 1
            % 根据区域面积排序，选择最大的
            [~, idx] = max([stats.Area]);
            stats = stats(idx);
        end
        
        % 在当前帧上绘制边界框
        for k = 1:length(stats)
            frame = insertShape(frame, 'Rectangle', stats(k).BoundingBox, 'Color', 'yellow', 'LineWidth', 2);
        end
        
        % 更新帧以进行下一轮计算
        frame1 = frame2;
        frame2 = frame3;
        
        videoPlayer.step(frame);
        maskPlayer.step(mask);
    end
    toc;
    % 打印程序执行时间
    fprintf('Program execution time: %.2f seconds\n', toc);
end
