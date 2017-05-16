function p = initTicks(p)
% p = initTicks(p)
% Initialize grid of tick marks for Screen('DrawLines')
% initTicks creates a matrix for drawing tick marks on the human display
% spaced every degree of visual angle. This grids up the screen into 1deg and
% 5deg step sizes so the experimenter can easily see the eccentricity of the
% stimulus. Set p.trial.pldaps.draw.grid.use=true if you want ticks on your
% display.
%
% INPUTS:
%   p [class]
%     .trial [struct] - main variables structure (see PLDAPShelp)
%       .display   - display structure
%           .dWidth screen width in degree
%           .dHeight screen height in degree
% OUTPUTS:
%   p [class]
%     .trial [struct] - main variables structure (modified)
%       .display   - display stucture  (modified)
%         .draw
%           .grid
%             .tick_line_matrix - field added in format called by
%                               Screen('DrawLines')
%
%
% 2011?      kme Wrote it
% 2013?      lnk Cave_samsung addendum added by ktz, 2013. rest is untouched.
%                (added more vairables to the d2p function call and increased
%                number of ticks)
% 12/12/2013 jly Updated help text and robustified screensize calculation
% 05/30/2014 jk  couple of changes:
%                  output is now in pixels
%                  grid is now made of '+'s instead of 'L's
%                  converted loops to one liners

if nargin < 1
    help initTicks
    return
end

if p.trial.pldaps.draw.grid.use
    small_tick_length = 2;
    small_tick_length=small_tick_length(1);
    big_tick_length = 5;
    big_tick_length = big_tick_length(1);
    
    screen_size_h = floor(p.trial.display.dWidth/2);
    screen_size_v = floor(p.trial.display.dHeight/2);
    
    small_vert_degrees=-screen_size_v:screen_size_v;
    small_horiz_degrees=-screen_size_h:screen_size_h;
    
    big_grid_size=5;
    screen_size_h = floor(screen_size_h/big_grid_size)*big_grid_size;
    screen_size_v = floor(screen_size_v/big_grid_size)*big_grid_size;
    
    big_vert_degrees=-screen_size_v:big_grid_size:screen_size_v;
    big_horiz_degrees=-screen_size_h:big_grid_size:screen_size_h;
    
    small_horizontal_matrix=pds.deg2px([reshape(repmat(small_horiz_degrees,[2,1]),1,2*length(small_horiz_degrees)); zeros(1,2*length(small_horiz_degrees))],p.trial.display.viewdist,p.trial.display.w2px);
    small_horizontal_matrix(2,:)= small_horizontal_matrix(2,:)+repmat([-small_tick_length small_tick_length],[1,length(small_horiz_degrees)]);
    
    small_vertical_matrix=pds.deg2px([zeros(1,2*length(small_vert_degrees)); reshape(repmat(small_vert_degrees,[2,1]),1,2*length(small_vert_degrees))],p.trial.display.viewdist,p.trial.display.w2px);
    small_vertical_matrix(1,:)=small_vertical_matrix(1,:)+repmat([-small_tick_length small_tick_length],[1,length(small_vert_degrees)]);
    
    big_horizontal_matrix=pds.deg2px([reshape(repmat(big_horiz_degrees,[2,1]),1,2*length(big_horiz_degrees)); zeros(1,2*length(big_horiz_degrees))],p.trial.display.viewdist,p.trial.display.w2px);
    big_horizontal_matrix(2,:)=big_horizontal_matrix(2,:)+repmat([-big_tick_length big_tick_length],[1,length(big_horiz_degrees)]);
    
    big_vertical_matrix=pds.deg2px([zeros(1,2*length(big_vert_degrees));reshape(repmat(big_vert_degrees,[2,1]),1,2*length(big_vert_degrees))],p.trial.display.viewdist,p.trial.display.w2px);
    big_vertical_matrix(1,:)=big_vertical_matrix(1,:)+repmat([-big_tick_length big_tick_length],[1,length(big_vert_degrees)]);
    
    big_vertical_grid_matrix=pds.deg2px([reshape(repmat(big_horiz_degrees,[2*length(big_vert_degrees),1]),1,2*length(big_horiz_degrees)*length(big_vert_degrees)); ...
        repmat(reshape([big_vert_degrees; big_vert_degrees],1,2*length(big_vert_degrees)), [1, length(big_horiz_degrees)])],p.trial.display.viewdist,p.trial.display.w2px);
    big_vertical_grid_matrix(2,:)=big_vertical_grid_matrix(2,:)+...
        repmat(reshape([-small_tick_length; small_tick_length],1,2), [1, length(big_horiz_degrees)*length(big_vert_degrees)]);
    
    big_horizontal_grid_matrix=pds.deg2px([repmat(reshape([big_horiz_degrees; big_horiz_degrees],1,2*length(big_horiz_degrees)), [1, length(big_vert_degrees)]);...
        reshape(repmat(big_vert_degrees,[2*length(big_horiz_degrees),1]),1,2*length(big_vert_degrees)*length(big_horiz_degrees))],p.trial.display.viewdist,p.trial.display.w2px);
    big_horizontal_grid_matrix(1,:)=big_horizontal_grid_matrix(1,:)+...
        repmat(reshape([-small_tick_length;small_tick_length],1,2), [1, length(big_vert_degrees)*length(big_horiz_degrees)]);
    
    
    line_matrix = [small_horizontal_matrix,small_vertical_matrix,big_horizontal_matrix,big_vertical_matrix,big_vertical_grid_matrix,big_horizontal_grid_matrix];
    
    p.trial.pldaps.draw.grid.tick_line_matrix = line_matrix;
    
end









