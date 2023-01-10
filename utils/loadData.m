% This function load data and find keypoints on the checkerboard images
% input: folder with images, checkerboard size
% output: a data structure with all the chessboard points saved for each
% image, with corresponding coordinates in pixels and mm

function [imageData] = loadData(folder, chessSize)
    clear imageData
    
    files = dir(strcat(folder, '/*.tif'));
    n = numel(files); % find number of files in folder
    
    imageData(n,1) = struct();
    
    squaresize = 30; % mm

    for i = 1:n
        imageFileName = fullfile(folder,files(i).name);
        imageData(i).I = imread(imageFileName); 
        % if image is not already B/N
        if length(size(imageData(i).I)) > 2
            imageData(i).I = rgb2gray(imageData(i).I );
        end
        
        imageData(i).XYpixel = detectCheckerboardPoints(imageData(i).I, 'PartialDetections', false);  
   
        XYpixel = imageData(i).XYpixel;
    
        clear Xmm Ymm
        for j=1:length(XYpixel)
            % this function based provides the row and column position of 
            % each point on a checkerboard of the given size
            [row,col] = ind2sub(chessSize,j);
            
            % corresponding coordinates for each point in millimiters
            Xmm = (col-1)*squaresize;
            Ymm = (row-1)*squaresize;
    
            imageData(i).XYmm(j,:) = [Xmm, Ymm];
            
        end
    end
  
end