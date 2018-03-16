function volumeGiven = getVolume(p,i)
%pds.newEraSyringePump.getVolume   retrieves the current volume dispensed by the pump
%
% p = pds.newEraSyringePump.getVolume(p)
%
% jk wrote it 2015
% edw edited 2017

    if any(p.trial.newEraSyringePump.use)
        s = p.trial.newEraSyringePump.s;
        
        % get volume
        cmd = sprintf([num2str(i-1) ' DIS']);
        fprintf(s,cmd);
        recvStr = '';
        while s.BytesAvailable > 0                                                  % CLEAR THE BUFFER
            fscanf(s,'%c',s.BytesAvailable);  pause(.001);
        end
        fprintf(s,cmd);                                                             % SEND THE COMMAND
        while s.BytesAvailable < 10; pause(.001); end;                              % WAIT FOR THE RESPONSE
        recvStr = fscanf(s,'%s',s.BytesAvailable);                                      % READ THE RESPONSE
        
        volumeGiven = str2num(recvStr(6:10));
    else
        volumeGiven = NaN;
    end