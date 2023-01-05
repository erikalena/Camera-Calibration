function [data] = estimateCamParam(data)
    n = length(data); % number of images

    % estimate H for each image
    for idx=1:n
        XYpixel = data(idx).XYpixel;
        XYmm = data(idx).XYmm;
        
        A = zeros(2*length(XYpixel), 9); % size of A is 2n x 9
    
        for j=1:length(XYpixel)
            Xpixel=XYpixel(j,1); % u
            Ypixel=XYpixel(j,2); % v
            Xmm=XYmm(j,1);  % x
            Ymm=XYmm(j,2); % y
    
            m = [Xmm; Ymm; 1];
            
            % stack equations in matrices
            O = [0; 0; 0];
            A((j*2-1):j*2,:) = [m' O' -Xpixel*m'; O' m' -Ypixel*m']; 
    
        end
    
        [~,~,V] = svd(A);
        h=V(:,end);
    
        data(idx).H = reshape(h, [3 3])';
    end
    
    % compute V
    V = zeros(2*n,6);
    
    for i=1:n
        % v
        v_11 = findV(1,1, data(i).H);
        v_12 = findV(1,2, data(i).H);
        v_22 = findV(2,2, data(i).H);
        
        % stack all the equations
        V((i*2-1):i*2,:) = [v_12'; (v_11 - v_22)'];
    end
        
    % compute b, knowing that Vb = 0
    [~,~,S] = svd(V);
    b = S(:,end); % solve system by least square
    b = b./b(6); % divide by scale factor
    
    % B symmetric matrix
    B = zeros(3,3); % this matrix should be filled with results of the solution  of next linear system
    
    % vector b defined in Zhang's paper is: b = [B11, B12, B22, B13, B23, B33]T
    % we exchange values in position 3 and 4 so that we can fill matrix B in order
    % matrix B is symmetric
    tmp = b(3);
    b(3) = b(4);
    b(4) = tmp;
    
    k = 1;
    for i=1:3
        for j=1:3
            if j < i
                B(i,j) = B(j,i);
            else
                B(i,j) = b(k);
                k = k+1;
            end
        end
    end
    
    % compute K
    % compute matrix K, given that B = (K*K')^(-1)
    K = inv(chol(B));
    
    % get the proper scale of K
    K = K./K(3,3);

    % once we have K, we can compute R,t (camera extrinsic for each image)
    % find extrinsic parameters for each image
    for idx=1:n
        % verify lambda = 1/norm(inv(K)*data(idx).H(:,2))
        inv_K = inv(K);
        lambda = norm(inv_K*data(idx).H(:,1));
    
        % define rotation matrix R
        r1 = (1/lambda)*inv_K*data(idx).H(:,1);
        r2 = (1/lambda)*inv_K*data(idx).H(:,2);
        t = (1/lambda)*inv_K*data(idx).H(:,3);
        
        r3 = cross(r1,r2);
        R = [r1 r2 r3];
        [U,~,V] = svd(R); % this because due to noise R may be not orthogonal
        data(idx).R = [U*V' t]; % add R to data
        data(idx).K = K;    % add K to data
        data(idx).P = data(idx).K*data(idx).R;
        data(idx).lambda = lambda;
    end

end