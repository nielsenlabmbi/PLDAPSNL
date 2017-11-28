function p = finish(p)
%pds.newEraSyringePump.finish   closes the IO Port to the pump
%
% typically called at the end of the experiment
%
% p = pds.newEraSyringePump.finish(p)
%
% jk wrote it 2015
% edw edited 2017

if any(p.trial.newEraSyringePump.use)
    
    fclose(p.trial.newEraSyringePump.s);
    delete(p.trial.newEraSyringePump.s);
    
end