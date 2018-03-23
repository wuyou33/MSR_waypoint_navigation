%% Variable Setup

grid_size = [15 15];
grid_w = 25;
max_step = 20000;

tol_wp = 15;                    
tol_line_width = 6;

tol_transform = pi/50;
Dy_angv_transform = pi/8;
tol_heading = pi/7;

cvg_sample_side = [20 20];

Algorithm = 'square_waypoint';
Serial_port = 'COM12';
baudrate = 9600;

is_heading_correction = false;
is_coverage_map = true;
is_calculate_coverage = true;
is_display_coverage = true;
is_wp_disappear_upon_reach = false;
is_grid_on = true;
is_xbee_on = false;
is_fixed_offset = true;
is_streaming_on = false;
is_streaming_collect_single_values = true;

navigation_mode = 'Line';

streaming_max_single_val = 1000;                % unit: cm
streaming_max_shift_dis = 25;                      % unit: cm 
streaming_max_shift_dis_single_value = 20;   % unit: cm


update_rate_streaming = 0.4;                      
update_rate_streaming_single_value = 0.4; 
update_rate_simulation = 0.2;

noise_simulation_linear = 20;                        %unit: cm

fixed_offset = [96.5 -54.5];
starting_grid = [1 2];
robot_weight = [1.5 1.5 1.5 1.5];
robot_Form = 1;

time_interval = 5;

max_pos_initialize = 5;

%% Variable initialization


heading = [0 0 pi pi];

time_pause = time_interval/100;

pos_uwb_offset = [0 -3];
pos_uwb_raw =  zeros(2, max_step);
pos_uwb = zeros(2, max_step);

pos_center = zeros(4, 2, max_step);

heading = zeros(4, max_step);

Grid_setup = zeros(grid_size(1),  grid_size(2));
Grid_current =  zeros(grid_size(1),  grid_size(2), max_step);
Grid_visited =  zeros(grid_size(1),  grid_size(2), max_step);

Dy_force = zeros(4, 2, max_step);
Dy_a = zeros(4, 2, max_step);
Dy_v = zeros(4, 2, max_step);

Wp = [];
wp_current = 1;
Circle_Wp = [];

is_rotating = false;

Line_Robot = [];
Line_Robot_area = [];
Line_Border = [];
loc_center = [0 0];

RobotShapes = [0 0 0 0 ;              
                        0 0 pi pi;
                        0 0 0 -pi;
                        -pi 0 0 0;
                        -pi 0 0 -pi;
                        -pi/2 0 pi 0;
                        -pi/2 0 pi pi/2];
       
for idx = 1:3
    RobotShapes = [RobotShapes; RobotShapes + pi/2*idx];
end
                    
%                                    Robot Shapes
%   =====================================
%         s01     s02      s03     s04      s05        s06       s07
%   -----------------------------------------------------------------
%
%          4                  4 3       4
%          3       2 3       2         3       4 3        2 3 4     2 3
%          2       1 4       1       1 2         2 1        1           1 4
%          1                      
%
%         s08           s010         s11        s12       s13      s14
%   -----------------------------------------------------------------
%
%                        1 2 4        1              4         2            2
%       1 2 3 4            3         2 3 4      2 3      1 3         1 3
%                                                     1           4         4
%  

Char_command_array = ['R', 'F', 'L', 'B'];
heading_command_compensate = 0;

char_command = '';
Cvg = [];
count_cvg_point = 0;
cvg_sample_w = grid_w*[grid_size(1)/cvg_sample_side(1) grid_size(2)/cvg_sample_side(2)];
grid_dhw = sqrt(2) / 2 * grid_w;

count_pos_initialize = 0;
is_pos_initialized = false;
pos_initial = [];

if (is_xbee_on)
    delete(instrfindall);
    arduino = serial(Serial_port,'BaudRate',baudrate);
    fopen(arduino);
end

for idxx = 1:(cvg_sample_side(2)+1)
    for idxy = 1:(cvg_sample_side(1)+1)
        Cvg = [Cvg; cvg_sample_w(1)*(idxy-1) cvg_sample_w(2)*(idxx-1) 0];
    end
end

%% Waypoint Generation

if (strcmp(navigation_mode,'Line'))
    disp('Generating robot routes...')
    for idx = 1: grid_size(1)
        if (mod(idx, 4) == 1)
            Wp = [Wp; 0.5*grid_w  (idx+0.5)*grid_w 1];
        end
        if (mod(idx, 4) == 2)
            Wp = [Wp; (grid_size(2) - 1.5)*grid_w  (idx-0.5)*grid_w 1];
        end
        if (mod(idx, 4) == 3)
            Wp = [Wp; (grid_size(2) - 1.5)*grid_w (idx+0.5)*grid_w 2];
        end
        if (mod(idx, 4) == 0)
            Wp = [Wp; 0.5*grid_w  (idx-0.5)*grid_w 2];
        end
    end
elseif (strcmp(navigation_mode,'Point'))
    disp('Generating waypoints...')
    for idx = 1: grid_size(1)
        if (mod(idx, 4) == 1)
            Wp = [Wp; 0.5*grid_w  (idx+0.5)*grid_w 1];
            Wp = [Wp; (0.5+(grid_size(2)-2)*1/4.0)*grid_w  (idx+0.5)*grid_w 25];
            Wp = [Wp; (0.5+(grid_size(2)-2)*2/4.0)*grid_w  (idx+0.5)*grid_w 8];
            Wp = [Wp; (0.5+(grid_size(2)-2)*3/4.0)*grid_w  (idx+0.5)*grid_w 9];
        end
        if (mod(idx, 4) == 2)
            Wp = [Wp; (grid_size(2) - 1.5)*grid_w  (idx-0.5)*grid_w 21];
        end
        if (mod(idx, 4) == 3)
            Wp = [Wp; (grid_size(2) - 1.5)*grid_w (idx+0.5)*grid_w 2];
            Wp = [Wp; (grid_size(2) - 1.5 - (grid_size(2)-2)*1/4.0)*grid_w  (idx+0.5)*grid_w 11];
            Wp = [Wp; (grid_size(2) - 1.5 - (grid_size(2)-2)*2/4.0)*grid_w  (idx+0.5)*grid_w 13];
            Wp = [Wp; (grid_size(2) - 1.5 - (grid_size(2)-2)*3/4.0)*grid_w  (idx+0.5)*grid_w 5];
        end
        if (mod(idx, 4) == 0)
            Wp = [Wp; 0.5*grid_w  (idx-0.5)*grid_w 2];
        end
    end
else
    disp('Navigation method is invalid.')
    disp('Terminating Matlab script...')
    return
end

%% DRAW MAP
figure(1)
axis([-grid_w grid_w*(grid_size(1)+1) -grid_w grid_w*(grid_size(2)+1)])
hold on

 % Draw Waypoints
for idx = 1: size(Wp,1)
    Circle_Wp(idx) = plot(Wp(idx, 1), Wp(idx, 2),'Color', 'r', 'LineWidth', 2, 'Marker', 'o');
end
txt_endLine = [0 0];
txt_endLine_last = [0 0];

%% Square Waypoint  (SW)
tic
if ( strcmp( Algorithm, 'square_waypoint'))
    
    % Algorithm Setup
    occup_start = [2 1; 1 1; 1 2; 2 2];
    
    for idx = 1: 4
        Grid_current( occup_start( idx, 1), occup_start( idx, 2), 1) = idx ;
        Grid_visited( occup_start( idx, 1), occup_start( idx, 2), 1) = 1;
    end 
    pos_uwb_raw(:, 1) = pos_uwb_offset;
    pos_uwb(:, 1) = pos_uwb_raw(:, 1);

    % Algorithm Main Loop
    for step = 1:max_step
        
        
        % Pause function
        pause(time_pause);
           
        % Robot Dynamics
        
        %for robidx = 1:4
        %Dy_v(:, :, step) = robotMovement(char_command, heading, 2);
            %Dy_force(robidx, :, step) = (Wp(wp_current, :) - pos_uwb(:,step).') / 250;
            %Dy_a(robidx, :, step) = Dy_force(robidx, :, step)  / robot_weight(robidx);
            %Dy_v(robidx, :, step+1) = Dy_v(robidx, :, step) + Dy_a(robidx, :, step) * time_interval;
        %end
       
        %pos_uwb(:, step)  
        %Wp(wp_current, :) 
        %norm(pos_uwb(:, step) - Wp(wp_current, :))

        
        % streaming input
        
        if (is_streaming_on)
            
            fid = fopen('C:\Marvelmind\dashboard\logs\TestLog.txt','rt');
            txt_Streaming = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'delimiter', ',','collectoutput',true...
                  , 'HeaderLines', 3);
            txt_Streaming=txt_Streaming{1};
            fclose(fid);
            txt_rows=size(txt_Streaming,1);
            txt_endLine = txt_Streaming(end, 5:6);
            
            if (is_fixed_offset) 
                txt_endLine = txt_endLine*100 + fixed_offset
            end
            
            % Initialize starting position
            if (~is_pos_initialized && (txt_endLine(1) ~= 0 &&  ~isnan(txt_endLine(1))  &&  txt_endLine(2) ~= 0 &&  ~isnan(txt_endLine(2))))
                if (txt_endLine(1) < streaming_max_single_val && txt_endLine(2) < streaming_max_single_val)
                    count_pos_initialize = count_pos_initialize + 1;
                    pos_initial = [pos_initial; txt_endLine];
                    if count_pos_initialize >= max_pos_initialize
                        txt_endLine_last = mean(pos_initial);
                        is_pos_initialized = true;
                        disp('Position initialized!');
                        pos_uwb_offset = txt_endLine_last - starting_grid * grid_w;
                        txt_endLine_last = starting_grid * grid_w;
                    end
                    pos_uwb(:, step+1) = pos_uwb(:, step);
                end
            elseif  (is_pos_initialized)
                % Streaming with Dashboard data
                if (~is_streaming_collect_single_values && txt_endLine(1) ~= 0 &&  ~isnan(txt_endLine(1))  &&  txt_endLine(2) ~= 0 &&  ~isnan(txt_endLine(2)) )
                    if (txt_endLine_last(1) ~= txt_endLine(1) || txt_endLine_last(2) ~= txt_endLine(2)) 
                        if norm(txt_endLine_last - txt_endLine) < streaming_max_shift_dis
                            line([txt_endLine_last(1) txt_endLine(1)], [txt_endLine_last(2) txt_endLine(2)]);
                            txt_endLine_last = txt_endLine;
                            pos_uwb(:, step+1) = (1 - update_rate_streaming) * txt_endLine_last.' + update_rate_streaming * pos_uwb(:, step);
                        else
                            pos_uwb(:, step+1) = pos_uwb(:, step);
                        end
                    else
                        pos_uwb(:, step+1) = pos_uwb(:, step);
                    end
                elseif (is_streaming_collect_single_values && txt_endLine(1) ~= 0  && txt_endLine(2) ~= 0 && (~isnan(txt_endLine(1)) || ~isnan(txt_endLine(2))))
                    if (txt_endLine_last(1) ~= txt_endLine(1) || txt_endLine_last(2) ~= txt_endLine(2)) 
                            if norm(txt_endLine_last - txt_endLine) < streaming_max_shift_dis_single_value
                            line([txt_endLine_last(1) txt_endLine(1)], [txt_endLine_last(2) txt_endLine(2)]);
                            txt_endLine_last = txt_endLine;
                            pos_uwb(:, step+1) = (1 - update_rate_streaming_single_value) * txt_endLine_last.' + update_rate_streaming_single_value * pos_uwb(:, step);
                        else
                            pos_uwb(:, step+1) = pos_uwb(:, step);
                        end
                    else
                        pos_uwb(:, step+1) = pos_uwb(:, step);
                    end
                else
                    pos_uwb(:, step+1) = pos_uwb(:, step);
                end
            else
                pos_uwb(:, step+1) = pos_uwb(:, step);
            end
        end
        
        % Waypoint clearing
        if(norm(pos_uwb(:, step).' - Wp(wp_current, 1:2)) < tol_wp )
            if (is_wp_disappear_upon_reach)
                delete(Circle_Wp(wp_current));
            end
            wp_current = wp_current + 1;
            % Break condition
            if wp_current > size(Wp,1)
                break;
            end
            heading_command_compensate = floor((Wp(wp_current, 3)-1)/7);
        end
        
        % Transformation
        is_require_transform = false;
        for rbtidx = 1:4
            if abs(heading(rbtidx) - RobotShapes(Wp(wp_current, 3),rbtidx)) > tol_transform
                is_require_transform = true;
            end
        end
        
        if (robot_Form ~= Wp(wp_current, 3) && is_require_transform)
            is_transforming = true;
        else 
            robot_Form = Wp(wp_current, 3);
            is_transforming = false;
        end
        
        % Robot Motion
        if (~is_pos_initialized && is_streaming_on)
            pos_uwb(:, step+1) = pos_uwb(:, step);
        elseif (is_transforming)
            heading = robotTransformation(Wp(wp_current, 3), heading, RobotShapes, tol_transform, Dy_angv_transform);
            pos_uwb(:, step+1) = pos_uwb(:, step);
        elseif (heading(2) > tol_heading && is_heading_correction ) 
            [Dy_v(:, :, step), heading] = robotMovement('l', heading, 0);
            pos_uwb(:, step+1) = pos_uwb(:, step);
        elseif (heading(2) < - tol_heading && is_heading_correction) 
            [Dy_v(:, :, step), heading]  = robotMovement('r', heading, 0);
            pos_uwb(:, step+1) = pos_uwb(:, step);
        else
            if (strcmp(navigation_mode,'Point'))
                if abs(Wp(wp_current, 1) - pos_uwb(1,step)) > abs(Wp(wp_current, 2) - pos_uwb(2,step)) 
                    if Wp(wp_current, 1) - pos_uwb(1,step) > 0
                        char_command = Char_command_array(1+mod(heading_command_compensate,4));  
                    else
                        char_command = Char_command_array(1+mod(heading_command_compensate+2,4));
                    end
                else
                    if Wp(wp_current, 2) - pos_uwb(2,step) > 0
                        char_command = Char_command_array(1+mod(heading_command_compensate+1,4));
                    else
                        char_command = Char_command_array(1+mod(heading_command_compensate+3,4));
                    end
                end
            elseif (strcmp(navigation_mode,'Line'))
                if Dis_point_line([pos_uwb(: , step) 0], [Wp(wp_current, 1:2) 0], [Wp(wp_current-1, 1:2) 0]) > abs(Wp(wp_current, 2) - pos_uwb(2,step)) 
                
                if abs(Wp(wp_current, 1) - pos_uwb(1,step)) > abs(Wp(wp_current, 2) - pos_uwb(2,step)) 
                    if Wp(wp_current, 1) - pos_uwb(1,step) > 0
                        char_command = Char_command_array(1+mod(heading_command_compensate,4));  
                    else
                        char_command = Char_command_array(1+mod(heading_command_compensate+2,4));
                    end
                else
                    if Wp(wp_current, 2) - pos_uwb(2,step) > 0
                        char_command = Char_command_array(1+mod(heading_command_compensate+1,4));
                    else
                        char_command = Char_command_array(1+mod(heading_command_compensate+3,4));
                    end
                end
                
                
                
                
                
            end
            
            %[Dy_v(:, :, step), heading]  = robotMovement(char_command, heading, 2);
            
            if (~is_streaming_on)
                [Dy_v(:, :, step), heading]  = robotMovement(char_command, heading, 2);
                pos_uwb(:, step+1) = Dy_v(2, :, step).' * time_interval+ ...
                                                update_rate_simulation* (pos_uwb(:, step) + rand(2,1) * noise_simulation_linear - noise_simulation_linear/2.0)...
                                               + (1-update_rate_simulation)* pos_uwb(:, step);
            end
            
            %pos_uwb(:, step+1) = Dy_v(2, :, step).' * time_interval+...
           %                                 0.2* (pos_uwb(:, step) + rand * 10 - 5) + 0.8* pos_uwb(:, step);
           % for rbtidx = 1:4
           %     heading(rbtidx) = 0.6 * heading(rbtidx) + 0.4 * (rand - 0.5) * 0.1 ;
           % end
           %heading(2) = 0.6 * heading(2) + 0.4 * (rand - 0.5)  ;
           %heading(1) = heading(2);
           %heading(3) = heading(2);
           %heading(4) = heading(2);
        end
        
        
        % Xbee Communication
        
        % pos_uwb(:, step)
        % Robot Commands
        % char_command
        if (is_xbee_on)
            writedata = char(char_command);
            fwrite(arduino,writedata,'char');
        end
        %readData = fscanf(arduino, '%c', 1)
        
        
        
        % calibrate pos here
        pos_x = pos_uwb(1,step);
        pos_nx = pos_uwb(1, step+1);
        pos_y = pos_uwb(2,step);
        pos_ny = pos_uwb(2, step+1);
        
        
        % remove previous robot line plot
        if (~isempty(Line_Robot))
            delete(Line_Robot)
        end
        Line_Robot = [];
        Line_Border = [];
        
        % Draw Robot
        pos_center(2,:, step) = [pos_x pos_y];
        pos_center(1,:, step) =  pos_center(2,:,step) + grid_dhw* ...
                                   [sin(pi/4 - heading(2))-cos(pi/4 - heading(1)) ...
                                    -cos(pi/4 - heading(2))-sin(pi/4 - heading(1))];
        pos_center(3,:, step) =  pos_center(2,:,step) + grid_dhw* ...
                                   [cos(pi/4 - heading(2))+sin(heading(3) - pi/4) ...
                                    sin(pi/4 - heading(2))+cos(heading(3) - pi/4)];
        pos_center(4,:, step) =  pos_center(3,:,step) + grid_dhw* ...
                                   [sin(-pi/4 + heading(3))+sin(pi/4 + heading(4)) ...
                                    cos(-pi/4 + heading(3))+cos(pi/4 + heading(4))]; 
        
        pos_center(2,:, step+1) = [pos_nx pos_ny];
        pos_center(1,:, step+1) =  pos_center(2,:, step+1) + grid_dhw* ...
                                   [sin(pi/4 - heading(2))-cos(pi/4 - heading(1)) ...
                                    -cos(pi/4 - heading(2))-sin(pi/4 - heading(1))];
        pos_center(3,:, step+1) =  pos_center(2,:, step+1) + grid_dhw* ...
                                   [cos(pi/4 - heading(2))+sin(heading(3) - pi/4) ...
                                    sin(pi/4 - heading(2))+cos(heading(3) - pi/4)];
        pos_center(4,:, step+1) =  pos_center(3,:,step+1)  + grid_dhw* ...
                                   [sin(-pi/4 + heading(3))+sin(pi/4 + heading(4)) ...
                                    cos(-pi/4 + heading(3))+cos(pi/4 + heading(4))]; 
        

        % plot robot BG
        if (is_coverage_map == 1)
            for robidx = 1:4
            Line_Robot(robidx,1) = line([pos_center(robidx, 1, step)+grid_dhw*cos(pi/4 - heading(robidx)) ...
                                                     pos_center(robidx, 1, step)+grid_dhw*sin(pi/4 - heading(robidx))], ...
                                                    [pos_center(robidx, 2, step)+grid_dhw*sin(pi/4 -  heading(robidx)) ...
                                                     pos_center(robidx, 2, step)+grid_dhw*-cos(pi/4 -  heading(robidx))], 'Color', 'yellow', 'LineWidth', 2);
            Line_Robot(robidx,2) = line([pos_center(robidx, 1, step)+grid_dhw*cos(pi/4 -  heading(robidx))... 
                                                     pos_center(robidx, 1, step)+grid_dhw*-sin(pi/4 -  heading(robidx))], ...
                                                    [ pos_center(robidx, 2, step)+grid_dhw*sin(pi/4 -  heading(robidx))...
                                                      pos_center(robidx, 2, step)+grid_dhw*cos(pi/4 -  heading(robidx))], 'Color', 'yellow', 'LineWidth', 2);
            Line_Robot(robidx,3) = line([pos_center(robidx, 1, step)+grid_dhw*-cos(pi/4 -  heading(robidx)) ...
                                                     pos_center(robidx, 1, step)+grid_dhw*-sin(pi/4 -  heading(robidx))], ...
                                                    [ pos_center(robidx, 2, step)+grid_dhw*-sin(pi/4 -  heading(robidx)) ...
                                                      pos_center(robidx, 2, step)+grid_dhw*cos(pi/4 -  heading(robidx))], 'Color', 'yellow', 'LineWidth', 2);
            Line_Robot(robidx,4) = line([pos_center(robidx, 1, step)+grid_dhw*-cos(pi/4 -  heading(robidx)) ...
                                                     pos_center(robidx, 1, step)+grid_dhw*sin(pi/4 -  heading(robidx))], ...
                                                    [ pos_center(robidx, 2, step)+grid_dhw*-sin(pi/4 -  heading(robidx))...
                                                      pos_center(robidx, 2, step)+grid_dhw*-cos(pi/4 -  heading(robidx))], 'Color', 'yellow', 'LineWidth', 2);
        
             end
        end
            
        % Draw Outer Border
        Line_Border(1) = line([0 0], [0 grid_w*grid_size(1)], 'Color', 'black', 'LineWidth', 2);
        Line_Border(2) =line([0 grid_w*grid_size(2)], [0 0], 'Color', 'black', 'LineWidth', 2);
        Line_Border(3) =line([grid_w*grid_size(2) grid_w*grid_size(1)], [0 grid_w*grid_size(1)], 'Color', 'black', 'LineWidth', 2);
        Line_Border(4) =line([grid_w*grid_size(2) 0], [grid_w*grid_size(2) grid_w*grid_size(1)], 'Color', 'black', 'LineWidth', 2);
        if (is_grid_on)
            for idxx = 1:(grid_size(1) + 1)
                line(grid_w*[(idxx-1) (idxx-1)], grid_w*[0 grid_size(2)], 'Color', 'black', 'LineWidth', 0.5);
            end
            for idxy = 1:(grid_size(2) + 1)
                line(grid_w*[0 grid_size(1)], grid_w*[(idxy-1) (idxy-1)], 'Color', 'black', 'LineWidth', 0.5);
            end
        end
        
        % Draw Robot Outline
        for robidx = 1:4
            %line([pos_center(robidx,1,step) pos_center(robidx,1,step+1)], [pos_center(robidx,2,step) pos_center(robidx,2,step+1)])  
            Line_Robot(robidx,1) = line([pos_center(robidx, 1, step)+grid_dhw*cos(pi/4 - heading(robidx)) ...
                                                     pos_center(robidx, 1, step)+grid_dhw*sin(pi/4 - heading(robidx))], ...
                                                    [pos_center(robidx, 2, step)+grid_dhw*sin(pi/4 -  heading(robidx)) ...
                                                     pos_center(robidx, 2, step)+grid_dhw*-cos(pi/4 -  heading(robidx))], 'Color', 'green', 'LineWidth', 1);
            Line_Robot(robidx,2) = line([pos_center(robidx, 1, step)+grid_dhw*cos(pi/4 -  heading(robidx))... 
                                                     pos_center(robidx, 1, step)+grid_dhw*-sin(pi/4 -  heading(robidx))], ...
                                                    [ pos_center(robidx, 2, step)+grid_dhw*sin(pi/4 -  heading(robidx))...
                                                      pos_center(robidx, 2, step)+grid_dhw*cos(pi/4 -  heading(robidx))], 'Color', 'green', 'LineWidth', 1);
            Line_Robot(robidx,3) = line([pos_center(robidx, 1, step)+grid_dhw*-cos(pi/4 -  heading(robidx)) ...
                                                     pos_center(robidx, 1, step)+grid_dhw*-sin(pi/4 -  heading(robidx))], ...
                                                    [ pos_center(robidx, 2, step)+grid_dhw*-sin(pi/4 -  heading(robidx)) ...
                                                      pos_center(robidx, 2, step)+grid_dhw*cos(pi/4 -  heading(robidx))], 'Color', 'green', 'LineWidth', 1);
            Line_Robot(robidx,4) = line([pos_center(robidx, 1, step)+grid_dhw*-cos(pi/4 -  heading(robidx)) ...
                                                     pos_center(robidx, 1, step)+grid_dhw*sin(pi/4 -  heading(robidx))], ...
                                                    [ pos_center(robidx, 2, step)+grid_dhw*-sin(pi/4 -  heading(robidx))...
                                                      pos_center(robidx, 2, step)+grid_dhw*-cos(pi/4 -  heading(robidx))], 'Color', 'green', 'LineWidth', 1);   
        end
        
        if(is_calculate_coverage)
            for cvg_idx = 1: numel(Cvg(:, 1))
                if (abs(pos_center(2, :, step)-Cvg(cvg_idx, 1:2)) < 2.5*sqrt(2)*grid_w)
                    for robidx = 1:4
                        if (Cvg(cvg_idx, 3) == 0)
                            tri1_x = [pos_center(robidx, 1, step)+grid_dhw*cos(pi/4 - heading(robidx)) ...
                                          pos_center(robidx, 1, step)+grid_dhw*sin(pi/4 - heading(robidx)) ...
                                          Cvg(cvg_idx, 1)];
                            tri1_y = [pos_center(robidx, 2, step)+grid_dhw*sin(pi/4 -  heading(robidx))  ...
                                          pos_center(robidx, 2, step)+grid_dhw*-cos(pi/4 -  heading(robidx)) ...
                                          Cvg(cvg_idx, 2)];
                            area1 = polyarea(tri1_x,tri1_y);
                            tri2_x = [pos_center(robidx, 1, step)+grid_dhw*cos(pi/4 -  heading(robidx)) ...
                                          pos_center(robidx, 1, step)+grid_dhw*-sin(pi/4 -  heading(robidx)) ...
                                          Cvg(cvg_idx, 1)];
                            tri2_y = [pos_center(robidx, 2, step)+grid_dhw*sin(pi/4 -  heading(robidx))  ...
                                          pos_center(robidx, 2, step)+grid_dhw*cos(pi/4 -  heading(robidx)) ...
                                          Cvg(cvg_idx, 2)];
                            area2 = polyarea(tri1_x,tri1_y);
                            tri3_x = [pos_center(robidx, 1, step)+grid_dhw*-cos(pi/4 -  heading(robidx)) ...
                                          pos_center(robidx, 1, step)+grid_dhw*-sin(pi/4 - heading(robidx)) ...
                                          Cvg(cvg_idx, 1)];
                            tri3_y = [pos_center(robidx, 2, step)+grid_dhw*-sin(pi/4 -  heading(robidx))  ...
                                          pos_center(robidx, 2, step)+grid_dhw*cos(pi/4 -  heading(robidx)) ...
                                          Cvg(cvg_idx, 2)];
                            area3 = polyarea(tri3_x,tri3_y);
                            tri4_x = [pos_center(robidx, 1, step)+grid_dhw*-cos(pi/4 -  heading(robidx)) ...
                                          pos_center(robidx, 1, step)+grid_dhw*sin(pi/4 -  heading(robidx)) ...
                                          Cvg(cvg_idx, 1)];
                            tri4_y = [pos_center(robidx, 2, step)+grid_dhw*-sin(pi/4 -  heading(robidx)) ...
                                          pos_center(robidx, 2, step)+grid_dhw*-cos(pi/4 -  heading(robidx)) ...
                                          Cvg(cvg_idx, 2)];
                            area4 =  polyarea(tri4_x,tri4_y);
                            if area1 + area2 + area3 + area4 <= grid_w* grid_w + 0.1
                                Cvg(cvg_idx,3) = 1;
                                count_cvg_point = count_cvg_point+1;
                            end
                        end
                    end
                end
            end
            if (is_display_coverage)
                disp(['Coverage: ',  num2str(count_cvg_point*100 / numel(Cvg(:, 1))), ' %']);
            end
        end
        % Draw Robot Center
        line([pos_x pos_nx], [pos_y pos_ny])
    end
end


if (is_xbee_on)
     writedata = char('S');
     fwrite(arduino,writedata,'char');
end

disp('===================');
disp('Robot Navigation Completed!');
toc
if (is_calculate_coverage)
    disp(['Final Map Coverage: ',  num2str(count_cvg_point*100 / numel(Cvg(:, 1))), ' %']);
end