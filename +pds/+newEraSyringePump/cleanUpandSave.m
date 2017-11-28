function p = cleanUpandSave(p)
%pds.newEraSyringePump.cleanUpandSave   save reward info after the trial
%
% stores the current volume dispensed by the pump
%
% p = pds.newEraSyringePump.cleanUpandSave(p)
%
% jk wrote it 2015

    if any(p.trial.newEraSyringePump.use)
        
        for i = 1:length(p.trial.newEraSyringePump.noPumps)
            p.trial.newEraSyringePump.volumeGiven(i) = pds.newEraSyringePump.getVolume(p,i);
        end
        
    end