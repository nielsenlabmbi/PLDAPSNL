function p = makePortsRect(p)
% rect = makePortsRect
% makePortsRect makes 4xn coordinate rectangles for PTB fillRect calls

% 10/26/2016 kn     wrote it

%the status squares (indicating contact)  will be drawn on top of the screen, with an offset
%of 2 deg to account for a possible photodiode rect of 1 deg
%the position squares for movable ports are directly below

if p.trial.pldaps.draw.ports.show
    for i=1:p.trial.ports.nPorts
        rect(1,i) = p.trial.display.winRect(1) + 2*p.trial.display.ppd + ...
            (i-1)*1.5*p.trial.pldaps.draw.ports.size;
        
        rect(2,i) = p.trial.display.winRect(2);
        
        rect(3,i) = rect(1,i) + p.trial.pldaps.draw.ports.size;
        
        rect(4,i) = rect(2,i) + p.trial.pldaps.draw.ports.size;
    end
    
    p.trial.pldaps.draw.ports.statusRect=rect;
    
    
    if p.trial.ports.movable
        for i=1:p.trial.ports.nPorts
            rect(1,i) = p.trial.display.winRect(1) + 2*p.trial.display.ppd + ...
                (i-1)*1.5*p.trial.pldaps.draw.ports.size;
            
            rect(2,i) = p.trial.display.winRect(2)+p.trial.pldaps.draw.ports.size;
            
            rect(3,i) = rect(1,i) + p.trial.pldaps.draw.ports.size;
            
            rect(4,i) = rect(2,i) + p.trial.pldaps.draw.ports.size;
        end
        p.trial.pldaps.draw.ports.positionRect=rect;
    end
end