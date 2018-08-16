% -----------------------------------------------------------
% Author: AxDante <knight16729438@gmail.com>
% Singapore University of Technology and Design
% Created: August 2018
% Modified: August 2018
% -----------------------------------------------------------

% Instructions: This is a matlab file that creates a navigation map and
% save it as a ".mat" file for the main path planning algorithm. Please
% specify the waypoint patterns along with the obstacle map used here.

filename = 'gbpp_10_01';

obsmap_name = 'obs_10_01';

grid_size = [10,10];        % Map grid size
rcg = [2, 2];        % Robot starting center grid
robot_Form = 1;   % Robot starting shape

% Robot waypoints
create_Wp = [1 2;
                    9 4;
                    9 6;
                    1 6];

% Robot sweeping rows
create_Row_sweep = [1 2;
                         0 0;
                         3 4;
                         0 0;
                         5 6;
                         0 0;
                         7 8;
                         0 0;
                         9 10];
                     
Row_sweep_sequence = [1 4; 5 8];                     
                     
                     
save(['navmap/', filename], 'obsmap_name', 'grid_size', 'rcg', 'robot_Form', ...
    'create_Wp', 'create_Row_sweep', 'Row_sweep_sequence')