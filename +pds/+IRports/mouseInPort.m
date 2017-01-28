function status = mouseInPort(p)

%this function tests whether the mouse cursor is over one of the response
%port squares, and if yes, sets the status of that port to active

if p.trial.pldaps.draw.ports.show
    
    status=zeros(1,p.trial.ports.nPorts); 
    
    x = p.trial.mouse.cursorSamples(1,p.trial.mouse.samples);
    y = p.trial.mouse.cursorSamples(2,p.trial.mouse.samples);
   
    %test y first - assumes that the ports are organized as a row on
    %the screen
    if y>=p.trial.pldaps.draw.ports.rect(2,1) && y<=p.trial.pldaps.draw.ports.rect(4,1)
        
        %now figure out which port
        pId=0;
        for i=1:p.trial.ports.nPorts
           if x>=p.trial.pldaps.draw.ports.rect(1,i) && x<=p.trial.pldaps.draw.ports.rect(3,i)
               pId=i;
               break;
           end
        end
        if pId>0
            status(pId)=1;
        end
       
    end
    
end