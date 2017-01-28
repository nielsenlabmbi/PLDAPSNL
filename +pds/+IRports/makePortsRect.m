function p = makePortsRect(p)
% rect = makePortsRect
% makePortsRect makes 4xn coordinate rectangles for PTB fillRect calls
% INPUTS
%   p [struct]
%     .trial
%       .pldaps             %pldaps internal parameters
%         .draw
%           .ports
%             .use
%             .nPorts
%             .size (in px)
%       .diaplay
%           .ppd     [1x1] pixels per degree
%           .winRect [1x4] screen coords [x_ul, y_ul, x_br, y_br]
% OUTPUT
% p [struct]
%     .trial
%       .pldaps             %pldaps internal parameters
%         .draw
%           .ports
%             .rect

% 10/26/2016 kn     wrote it

%the squares will be drawn on top of the screen, with an offset of 2 deg to
%account for a possible photodiode rect of 1 deg

if(p.trial.pldaps.draw.ports.show)
    for i=1:p.trial.ports.nPorts
        rect(1,i) = p.trial.display.winRect(1) + 2*p.trial.display.ppd + ...
            (i-1)*1.5*p.trial.pldaps.draw.ports.size;
        
        rect(2,i) = p.trial.display.winRect(2);
        
        rect(3,i) = rect(1,i) + p.trial.pldaps.draw.ports.size;
        
        rect(4,i) = rect(2,i) + p.trial.pldaps.draw.ports.size;
        
    end
    
    p.trial.pldaps.draw.ports.rect=rect;
end