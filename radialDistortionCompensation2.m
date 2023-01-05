% This function implement the iterative procedure to adjust
% projection matrix P wrt radial distortion
function [data, k] = radialDistortionCompensation2(data)

    data = estimateCamParam(data); % estimate matrix P and all the parameters
    n = length(data); % number of images
    prev_P = data(1).P;
    prev_k1 = 0;
    prev_k2 = 0;
    tol = 10^(-8);
    repeat = true; % repeat unitl convergence
    
    s = 0; % counter 
    maxiter = 100;

    while repeat && s < maxiter
        s = s+1;
        fprintf("iteration %d\n", s);
        
        % computed expected projection (in pixel) for each point
        npoints = length(data(1).XYpixel); % number of points detected on checkerboard
        
        % find current estimated points 
        % using computed matrix P
        for i=1:n
            XYmm = data(i).XYmm;
            for j=1:npoints
                Xmm=XYmm(j,1);
                Ymm=XYmm(j,2); 
                m = [Xmm; Ymm; 0; 1];
                    
                res = data(i).P*m; % projected point
                data(i).expected(j,:) = res./res(3); % expected "ideal" projection (u, v coordinates)
            end
        end
        
        % initialize matrices and set the system
        % to find k1, k2 parameters

        A = zeros(2*npoints*2, 2); % matrix A has two equations for each point of each image
        b = zeros(2*npoints*2, 1); % column vector b of solutions
        K = data(1).K; % matrix K of intrinsic parameters
    
        % alphau, alphav, u0, v0 parameters in already computed matrix 
        alpha_u = K(1,1);
        theta = acot(K(1,2)/alpha_u); % skew angle between u and v axes, the angle is measured in radians
        alpha_v = K(2,2)*sin(theta);
        
        u0 = K(1,3);
        v0 = K(2,3);
        
        % fill A and b
        for i=1:2
            for j=1:npoints
        
                uhat = data(i).XYpixel(j,1);
                u = data(i).expected(j,1);
        
                vhat = data(i).XYpixel(j,2);
                v = data(i).expected(j,2);
        
                rd = ((u-u0)/alpha_u)^2 + ((v-v0)/alpha_v)^2;
                
                idx = (i-1)*2*npoints + (j)*2-1;
              
                A(idx,1) = (u - u0)*rd;
                A(idx,2) = (u - u0)*rd^2;
                A(idx+1, 1) = (v - v0)*rd;
                A(idx+1, 2) = (v - v0)*rd^2;
                b(idx) = uhat - u;
                b(idx+1) = vhat - v;
            end
            
        end


        k = lsqr(A,b); % same as: inv((A'*A))*A'*b
        k1 = k(1); k2 = k(2);
        fprintf("k1 %d  k2 %d\n", k1, k2);

        diff_k = max(abs(prev_k2 - k2), abs(prev_k1 -k1));
        prev_k1 = k1; prev_k2 = k2; % update radial distortion parameters values
        
        % new system in which the unknowns are x,y
        for i=1:n
            for j=1:npoints
        
                % find the new x,y for each of selected points using newton method
                uhat = data(i).XYpixel(j,1);
                vhat = data(i).XYpixel(j,2);
                xhat = (uhat - u0)/alpha_u; 
                yhat = (vhat - v0)/alpha_v; 
                
                f1 = @(x,y) x*(1 + k1*(x^2 + y^2) + k2*(x^4 +2*x^2*y^2 + y^4)) - xhat;
                f2 = @(x,y) y*(1 + k1*(x^2 + y^2) + k2*(x^4 +2*x^2*y^2 + y^4)) - yhat;
                J = @(x,y) [1+ 3*k1*x^2 + k1*y^2 + 5*k2*x^4 + 6*k2*x^2*y^2 + k2*y^4, ...
                            2*k1*x*y + 4*k2*x^3*y + 4*k2*x*y^3; ...
                            2*k1*x*y + 4*k2*x*y^3 + 4*k2*x^3*y, ...
                            1+ 3*k1*y^2 + k1*x^2 + 5*k2*y^4 + 6*k2*x^2*y^2 + k2*x^4];
                
                x0 = [0; 0]; % starting point for newton's method
                res = newtonMethod(f1,f2, J, x0, 10^(-8), 100);
                
                x = res(1); y = res(2);
                % update m' (pixel values of each point) using the obtained result
                % (values of x,y)
                data(i).expected(j,1) = alpha_u*x + u0; %update u
                data(i).expected(j,2) = alpha_v*y + v0; %update v
                
            end
        end
        
%         for i=1:n
%             data(i).XYpixel = data(i).expected; % update uhat and vhat for each point in order to estimate new camera parameters
%         end
        data = estimating(data); % estimate matrix P and all the parameters
        P = data(1).P;
        diff_P = norm(P-prev_P);
        prev_P = P; 

        if diff_k < tol || diff_P < tol % if we reached convergence, stop
            repeat = false;
        end
    end


end