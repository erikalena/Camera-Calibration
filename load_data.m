% This function load data: images and detected points on checkerboard
function [imageData] = load_data(folder)
    clear imageData
    
    files = dir(strcat(folder, '/*.tif'));
    n = numel(files); % find number of files in folder
    
    imageData(n,1) = struct();
    
    squaresize = 30; % mm
    chessboard_size = [12,13];

    for i = 1:n
        imageFileName = fullfile(folder,files(i).name);
        imageData(i).I = imread(imageFileName); 
        imageData(i).XYpixel = detectCheckerboardPoints(imageData(i).I, 'PartialDetections', false);  % this last flag is needed otherwise on few images it detects the wrong number of points
   
        XYpixel = imageData(i).XYpixel;
    
        clear Xmm Ymm
        for j=1:length(XYpixel)
            % this function based on an order provided the index of each
            % point found provides the row and column position of our point 
            % in a matrix of size [12,13] measures (row, column) need to be different in
            % order to properly identify the origin wrt rotations
            [row,col] = ind2sub(chessboard_size,j);
    
            % corresponding coordinates for each point in millimiters
            Xmm = (col-1)*squaresize;
            Ymm = (row-1)*squaresize;
    
            imageData(i).XYmm(j,:) = [Xmm, Ymm];
            
        end
    end
  
end