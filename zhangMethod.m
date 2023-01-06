% use this function to compute prospective projection
% matrix for each image provided
% constraint: provide at least 4 images
% input: folder with images, checkerboard size
% output: a data structure with all the parameters for each image (matrix P, R, t)

function [data] = zhangMethod(folder, chessSize)
    
    % load data (images) and
    % find checkerboard points
    clear imageData
    imageData = load_data(folder, chessSize);
    n = length(imageData); % number of images
    
    fprintf('Data loaded and points detected \n');

    % check that the right number of points for each image has been found  
    fprintf('Checking the number of keypoints... \n');
    npoints = chessSize(1)*chessSize(2);
    for i=1:n
        if length(imageData(i).XYpixel) ~= npoints
            error(message('Wrong number of points detected'));
        end
    end
    
    fprintf('Estimating camera parameters for each image... \n');
    % compute camera intrinsic and extrinsic parameters for each image
    clear data
    data = estimateCamParam(imageData); 
    
    fprintf('Everything done. \n');
end