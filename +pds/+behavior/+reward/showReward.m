function showReward(p,mapString)
%this function prints the current reward values in the command window
%input: 
% p - pldaps structure
% mapString - names for reward channels for easier display


if p.trial.pldaps.draw.reward.show
    if p.trial.pldaps.draw.reward.verbose
        if p.trial.behavior.reward.nChannels==3
            disp(['(1/2) - (3/4) - (5/6)'])
        else
            disp(['(1/2) - (3/4) - (5/6) - (7/8)'])
        end
    end
    
    outStr='';
    for i=1:length(mapString) 
        outStr=[outStr '  ' mapString{i} ': ' num2str(p.trial.behavior.reward.amount(i))]; 
    end   
    disp(outStr)
    
end