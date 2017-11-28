function p = setup(p)
%pds.newEraSyringePump.getVolume   sets up connection to a New Era syringe pump
%
% p = pds.newEraSyringePump.setup(p)
% sets up the connection to a New Era syringe pump (syringepump.com) via
% USB. Currently only modes that run a by defined volume per reward are implemented
%
% jk wrote it 2015
% edw adapted 2017



if any(p.trial.newEraSyringePump.use)
    
    s = instrfind('Port',p.trial.newEraSyringePump.port);
    if ~isempty(s);
    fclose(s);
    delete(s);
    end
    
    s = serial(p.trial.newEraSyringePump.port,'BaudRate', 19200, 'Terminator','CR/LF');
    fopen(s);
    
    % This assumes that the pump addresses are the same as the side
    % assignments - I think this will need to be set separately (outside of
    % pldaps)
    
    for i = 1:length(p.trial.newEraSyringePump.noPumps)
        
        cmd = sprintf([num2str(i) ' ' 'DIA ' num2str(p.trial.newEraSyringePump.diameter)]);
        fprintf(s,cmd);
        
        cmd = sprintf([num2str(i) ' ' 'RAT ' num2str(p.trial.newEraSyringePump.rate) ' MH ']);
        fprintf(s,cmd);
        
        cmd = sprintf([num2str(i) ' ' 'DIR INF']);
        fprintf(s,cmd);
        
        cmd = sprintf([num2str(i) ' ' 'LN ' num2str(p.trial.newEraSyringePump.lowNoiseMode) ' MH ']);
        fprintf(s,cmd);
        
        cmd = sprintf([num2str(i) ' ' 'AL ' num2str(p.trial.newEraSyringePump.alarmMode) ' MH ']);
        fprintf(s,cmd);
        
        cmd = sprintf([num2str(i) ' ' 'CLD INF']);
        fprintf(s,cmd);
        
        p.trial.newEraSyringePump.initialVolumeGiven(i) = pds.newEraSyringePump.getVolume(p,i);
        
    end
    p.trial.newEraSyringePump.s = s;
end