clear 
clc
clf
cla 
close all


max_step = 100;

size_ws = [4 4];
s_tl = 1;
s_rt = 1/12;

d_r = 10;

wp = zeros(max_step,5);
wp(1,:) = [25,25, 0, 4/3, 8/3];

Line_Rbt = [];

figure(1)
set(figure(1), 'Position', [100, 100, 1020, 900])
axis([-d_r*1.5 d_r*(size_ws(1)+1.5) -d_r*1.5 d_r*(size_ws(2)+1.5)])
title('hTetro Waypoint Map')
hold on


wp_cur = 1;
Wp = [25,25, 0, 4/3, 4/3;
           40, 32, 0, 4/3, 4/3;
           30, 12, 0, 1/3, 6/3;
           20, 20, 0.5, 4/3, 7/3];

step = 1;


while step < max_step && wp_cur <= size(Wp,1)
   
    if abs(Wp(wp_cur, 3) - wp(step,3)) > 1e-10 || abs(Wp(wp_cur, 4) - wp(step,4)) > 1e-10 ||abs(Wp(wp_cur, 5) - wp(step,5)) > 1e-10
       a_add = [0 0 0];
       if Wp(wp_cur, 3) - wp(step,3) > 1e-10
           a_add = a_add + [s_rt 0 0];
       elseif Wp(wp_cur, 3) - wp(step,3) < -1e-10
           a_add = a_add + [-s_rt 0 0];
       end
       if Wp(wp_cur, 4) - wp(step,4) > 1e-10
           a_add = a_add + [0 s_rt 0];
       elseif Wp(wp_cur, 4) - wp(step,4) < -1e-10
           a_add = a_add + [0 -s_rt 0];
       end
       if Wp(wp_cur, 5) - wp(step,5) > 1e-10
           a_add = a_add + [0 0 s_rt];
       elseif Wp(wp_cur, 5) - wp(step,5) < -1e-10
           a_add = a_add + [0 0 -s_rt];
       end
       wp(step+1, :)  = wp(step, :) + [0 0 a_add(1) a_add(2) a_add(3)];
        
    elseif Wp(wp_cur, 1) - wp(step,1) == 0 && Wp(wp_cur, 2) - wp(step,2) == 0 
        wp(step+1, :)  = wp(step, :);
        wp_cur = wp_cur + 1;
    elseif abs(Wp(wp_cur, 1) - wp(step,1)) > abs(Wp(wp_cur, 2) - wp(step,2)) 
        if Wp(wp_cur, 1) - wp(step,1) > 0
            wp(step+1, :) = wp(step, :) + [s_tl 0 0 0 0];
        else
            wp(step+1, :) = wp(step, :) + [-s_tl 0 0 0 0];
        end
    elseif abs(Wp(wp_cur, 1) - wp(step,1)) <= abs(Wp(wp_cur, 2) - wp(step,2)) 
        if Wp(wp_cur, 2) - wp(step,2) > 0
            wp(step+1, :) = wp(step, :) + [0 s_tl 0 0 0];
        else
            wp(step+1, :) = wp(step, :) + [0 -s_tl 0 0 0];
        end
    end

    

    a_vc13 = 1/3 - wp(step+1, 3);
    a_vc24 = 1/6 + wp(step+1, 3);
    a_v11 = -wp(step+1, 4) - wp(step+1, 3) + 11/6;
    a_v12 = -wp(step+1, 4) - wp(step+1, 3) + 3/2;
    a_v21 = wp(step+1, 5) + wp(step+1, 3) - 3/2;
    a_v22 = wp(step+1, 5) + wp(step+1, 3) - 7/6; 
    
    p_vc1 = wp(step+1, 1:2) + d_r/2 * [-cos(pi*a_vc13) sin(pi*a_vc13)];
    p_vc2 = wp(step+1, 1:2) + d_r*sqrt(3)/2 * [cos(pi*a_vc24) sin(pi*a_vc24)];
    p_vc3 = wp(step+1, 1:2) + d_r/2 * [cos(pi*a_vc13) -sin(pi*a_vc13)];
    p_vc4 = wp(step+1, 1:2) + d_r*sqrt(3)/2 * [-cos(pi*a_vc24) -sin(pi*a_vc24)];

    p_v11 = p_vc1 + d_r * [-sin(pi*a_v11) -cos(pi*a_v11)];
    p_v12 = p_vc1 + d_r * [-sin(pi*a_v12) -cos(pi*a_v12)];
    p_v21 = p_vc2 + d_r * [sin(pi*a_v21) -cos(pi*a_v21)];
    p_v22 = p_vc2 + d_r * [sin(pi*a_v22) -cos(pi*a_v22)];
    
    
    if (~isempty(Line_Rbt))
        delete(Line_Rbt);
    end
    Line_Rbt = [];

    
    
    Line_Rbt(1) = line([p_vc1(1) p_vc2(1)], [p_vc1(2) p_vc2(2)], 'Color', 'black', 'LineWidth', 2);
    Line_Rbt(2) = line([p_vc2(1) p_vc3(1)], [p_vc2(2) p_vc3(2)], 'Color', 'black', 'LineWidth', 2);
    Line_Rbt(3) = line([p_vc3(1) p_vc4(1)], [p_vc3(2) p_vc4(2)], 'Color', 'black', 'LineWidth', 2);
    Line_Rbt(4) = line([p_vc4(1) p_vc1(1)], [p_vc4(2) p_vc1(2)], 'Color', 'black', 'LineWidth', 2);

    Line_Rbt(5) = line([p_vc1(1) p_v11(1)], [p_vc1(2) p_v11(2)], 'Color', 'black', 'LineWidth', 2);
    Line_Rbt(6) = line([p_v11(1) p_v12(1)], [p_v11(2) p_v12(2)], 'Color', 'black', 'LineWidth', 2);
    Line_Rbt(7) = line([p_v12(1) p_vc1(1)], [p_v12(2) p_vc1(2)], 'Color', 'black', 'LineWidth', 2);

    Line_Rbt(8) = line([p_vc2(1) p_v21(1)], [p_vc2(2) p_v21(2)], 'Color', 'black', 'LineWidth', 2);
    Line_Rbt(9) = line([p_v21(1) p_v22(1)], [p_v21(2) p_v22(2)], 'Color', 'black', 'LineWidth', 2);
    Line_Rbt(10) = line([p_v22(1) p_vc2(1)], [p_v22(2) p_vc2(2)], 'Color', 'black', 'LineWidth', 2);

    step = step + 1;
    pause(0.1)
    
end
