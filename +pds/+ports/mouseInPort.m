function status = mouseInPort(p)

%this function tests whether the mouse cursor is over one of the response
%port squares, and if yes, sets the status of that port to active

if p.trial.pldaps.draw.ports.show && p.trial.mouse.useAsPort
        
    status=zeros(1,p.trial.ports.nPorts); 
    
    x = p.trial.mouse.cursorSamples(1,p.trial.mouse.samples);
    y = p.trial.mouse.cursorSamples(2,p.trial.mouse.samples);
   
    
    %get distance from the ports
    distport=sqrt((p.trial.pldaps.draw.ports.statusDisp(1,:)-x).^2 + ...
        (p.trial.pldaps.draw.ports.statusDisp(2,:)-y).^2);
    
    portIdx=find(distport<p.trial.mouse.virtualPortRadius);
    
    if ~isempty(portIdx)
        status(portIdx)=1;
    end
    
end