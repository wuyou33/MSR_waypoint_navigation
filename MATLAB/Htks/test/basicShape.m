clear 
clc
clf

size_ws = [4 4];
s_tl = 1;
s_rt = pi/36;

d_r = 10;
a_c = pi/10;
a_1 = pi*3/3;
a_2 = pi*6/3;


a_vc13 = pi/3 - a_c;
a_vc24 = pi/6 + a_c;
a_v21 = a_2 + a_c - pi*3/2;
a_v22 = a_2 + a_c - pi*7/6; 
a_v11 = -a_1 - a_c + pi*11/6;
a_v12 = -a_1 - a_c + pi*3/2;

p_c = [25 25];

p_vc1 = p_c + d_r/2 * [-cos(a_vc13) sin(a_vc13)];
p_vc2 = p_c + d_r*sqrt(3)/2 * [cos(a_vc24) sin(a_vc24)];
p_vc3 = p_c + d_r/2 * [cos(a_vc24) -sin(a_vc24)];
p_vc4 = p_c + d_r*sqrt(3)/2 * [-cos(a_vc24) -sin(a_vc24)];

p_v11 = p_vc1 + d_r * [-sin(a_v11) -cos(a_v11)];
p_v12 = p_vc1 + d_r * [-sin(a_v12) -cos(a_v12)];
p_v21 = p_vc2 + d_r * [sin(a_v21) -cos(a_v21)];
p_v22 = p_vc2 + d_r * [sin(a_v22) -cos(a_v22)];

Line_Rbt = [];

figure(1)
set(figure(1), 'Position', [100, 100, 1020, 900])
axis([-d_r*1.5 d_r*(size_ws(1)+1.5) -d_r*1.5 d_r*(size_ws(2)+1.5)])
title('hTetro Waypoint Map')
hold on

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



