function p = stop(p)
%pds.newEraSyringePump.stop   stop dispensing
%
% p = pds.newEraSyringePump.stop(p)
%
% jk wrote it 2015
% edw edited 2017

    if any(p.trial.newEraSyringePump.use)
        s = p.trial.newEraSyringePump.s;
        
        for i = 1:length(p.trial.newEraSyringePump.noPumps)
        cmd = sprintf([num2str(i) ' ' 'STP']);
        fprintf(s,cmd);
        end
        
    end