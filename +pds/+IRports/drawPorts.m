function drawPorts(portWindow,portRect,portStatus,portColor)

%draws rectangles to indicate the status of the IR ports
%portWindow: ID of the window to plot the ports on
%portRect: coordinates for each port indicator
%portStatus: status of each port
%portColor: color of the ports

for i=1:size(portRect,2)
    if portStatus(i)==1
        Screen('FillRect', portWindow,portColor,portRect(:,i));
    else
        Screen('FrameRect', portWindow,portColor,portRect(:,i));
    end
end