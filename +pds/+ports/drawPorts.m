function drawPorts(portWindow,portPos,portStatus,lowColor,highColor)

%draws rectangles to indicate the status of the IR ports
%portWindow: ID of the window to plot the ports on
%portRect: coordinates for each port indicator
%portStatus: status of each port
%portColor: color of the ports

idx=find(portStatus==0);
if ~isempty(idx)
    Screen('Drawdots',portWindow,portPos(:,idx),20,lowColor);
end

idx=find(portStatus==1);
if ~isempty(idx)
    Screen('Drawdots',portWindow,portPos(:,idx),20,highColor);
end
