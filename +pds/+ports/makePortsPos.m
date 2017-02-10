function p = makePortsPos(p)
% pos = makePortsPos
% makePortsPos determines coordinates for the port status displays (dots)

% 10/26/2016 kn     wrote it

%the status dots (indicating contact)  will be drawn on top of the screen, with an offset
%of 2 deg to account for a possible photodiode rect of 1 deg
%the position dots for movable ports are directly below

if p.trial.pldaps.draw.ports.show
    for i=1:p.trial.ports.nPorts
        pos(1,i) = p.trial.display.winRect(1) + 2*p.trial.display.ppd + ...
            (i-1)*p.trial.mouse.virtualPortRadius*2.5;
        
        pos(2,i) = p.trial.display.winRect(2)+20;
    end
    
    p.trial.pldaps.draw.ports.statusDisp=pos;
    
    if p.trial.ports.movable
        for i=1:p.trial.ports.nPorts
            
            pos(1,i) = p.trial.display.winRect(1) + 2*p.trial.display.ppd + ...
                (i-1)*p.trial.mouse.virtualPortRadius*2.5;
        
            pos(2,i) = p.trial.display.winRect(2)+50;
        end
        p.trial.pldaps.draw.ports.positionDisp=pos;
    end
end