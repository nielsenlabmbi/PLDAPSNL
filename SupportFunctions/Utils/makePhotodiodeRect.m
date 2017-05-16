function p = makePhotodiodeRect(p)
% rect = makePhotodiodeRect(p)
% makePhotodiodeRect makes a 4 coordinate rectangle for PTB fillRect calls
% INPUTS
%   p [struct]
%     .trial
%       .pldaps             %pldaps internal parameters
%         .draw
%           .photodiode
%             .use
%             .location
%       .diaplay
%           .ppd     [1x1] pixels per degree
%           .winRect [1x4] screen coords [x_ul, y_ul, x_br, y_br]
% OUTPUT
% dv [struct]
%     .trial
%       .pldaps             %pldaps internal parameters
%         .draw
%           .photodiode
%             .rect

% 12/15/2013 jly    Wrote it
% 06/03/2014 jk     made compatible with pldaps class

if(p.trial.pldaps.draw.photodiode.use)
    switch p.trial.pldaps.draw.photodiode.location
        case 1
            rect = [p.trial.display.winRect(1:2) p.trial.display.winRect(1:2)+p.trial.display.ppd];
        case 2
            rect = [p.trial.display.winRect(1) p.trial.display.winRect(4)-p.trial.display.ppd ...
                p.trial.display.winRect(1)+p.trial.display.ppd p.trial.display.winRect(4)];
        case 3
            rect = [p.trial.display.winRect(3)-p.trial.display.ppd p.trial.display.winRect(2)...
                p.trial.display.winRect(3) p.trial.display.winRect(2)+p.trial.display.ppd];
        case 4
            rect = [p.trial.display.winRect(3:4)-p.trial.display.ppd p.trial.display.winRect(3:4)];
        otherwise
            rect = [p.trial.display.winRect(1) p.trial.display.winRect(4)-p.trial.display.ppd ...
                p.trial.display.winRect(1)+p.trial.display.ppd p.trial.display.winRect(4)];
    end
    
    p.trial.pldaps.draw.photodiode.rect=rect;
end