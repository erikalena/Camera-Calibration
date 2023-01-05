function superimposeCylinder(data, folder)
    n = length(data);
    for idx=1:n 
        figure('visible','off');
        img = imshow(data(idx).I);
        hold on
        
        % measures
        d = 120;
        r = d/2;
        h = 150;
    
        % center
        x0=150;
        y0=150;
       
        
        % generate random points
        n_points = 20;
        angle = pi/n_points;  
    
        clear m
        % m will contain all the points of the two bases
        m = zeros(n_points*2, 4);
        for i = 1:n_points
            x = x0 + r.*cos(angle + (2*pi/n)*i);
            y = y0 + r.*sin(angle + (2*pi/n)*i);
            a = [x;y;0;1]; % point at the bottom of cylinder
            b = [x;y;h;1]; % corresponding point at top
            m(i,:) = a;
            m(i+n_points,:) = b;
        end
    
        % compute corresponding points in the image reference frame
        projected = zeros(n_points*2, 3);
        for i = 1:length(m)
            res = data(idx).P*m(i,:)';
            if res(3) > 0
                if i > n_points % only for points which have z != 0
                    m(i, 3)= -h;
                end
                res = data(idx).P*m(i,:)';
                projected(i,:) = res./res(3);
            else
                projected(i,:) = res./res(3);
            end
        end
    
        x_bottom = projected(1:n_points,1);
        y_bottom = projected(1:n_points,2);
        x_top = projected(n_points+1:n_points*2,1);
        y_top = projected(n_points+1:n_points*2,2);
        
        % try to show the corpus of cylinder
        % find rightmost and leftmost point
        dist = zeros(n_points/2,1);
        for s=1:n_points/2
            dist(s) = sqrt((x_bottom(s) - x_bottom(s+n_points/2)).^2 + (y_bottom(s) - y_bottom(s+n_points/2)).^2); % distances points at opposite sides (all the possible diameters)
        end
        [~, i] = max(dist);
        k = i + n_points/2;
        
    
        if (y_bottom(i) > y_top(i) && x_bottom(i) < x_bottom(k) ) || (y_bottom(i) < y_top(i) && x_bottom(i) > x_bottom(k) )
            border_x = [x_bottom(i), x_top(i:k)', x_bottom(k:end)', x_bottom(1:i-1)'];
            border_y = [y_bottom(i), y_top(i:k)', y_bottom(k:end)', y_bottom(1:i-1)'];
            
        else
                border_x = [x_top(i), x_bottom(i:k)', x_top(k:end)', x_top(1:i-1)'];
                border_y = [y_top(i), y_bottom(i:k)', y_top(k:end)', y_top(1:i-1)'];
                
                
        end 
    
        patch(border_x, border_y,'green', 'LineStyle','none', 'FaceColor', 'green', 'FaceAlpha', 0.8);
    
        % show basis
        patch(x_bottom, y_bottom, 'red', 'LineStyle','none', 'FaceColor', 'red', 'FaceAlpha', 0.3);
        patch(x_top, y_top,'blue', 'LineStyle','none', 'FaceColor', 'blue', 'FaceAlpha', 0.6);
    
        file_name = sprintf('Image%d.png', idx); % name Image with a sequence of number, ex Image1.png , Image2.png....
        fullFileName = fullfile(folder, file_name);
        saveas(img,fullFileName,'png'); %save the image as a Portable Graphics Format file(png)into the MatLab

    end
end