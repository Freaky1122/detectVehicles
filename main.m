
filename = "Data/Sample.mp4";
% 如果使用卡尔曼滤波将method置0
% 如果使用粒子滤波将method置1
method = 0;


% 上面为不计数的算法，下面为计数的算法

% 光流法不计数
% detectVehiclesOpticalFlow(filename);
% 帧差法不计数
% detectVehiclesThreeFrameDiff(filename);
% 混合高斯不计数
% detectVehiclesGaussianMixture(filename);

%-----------------------------------------------------------------%

% 光流法计数
% detectVehiclesOpticalFlowWithTracking(method, filename);
% 帧差法计数
% detectVehiclesThreeFrameDiffWithTracking(method, filename);
% 混合高斯计数
detectVehiclesGaussianMixtureWithTracking(method, filename);