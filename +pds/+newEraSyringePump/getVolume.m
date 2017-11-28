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
        cmd = sprintf([num2str(i) ' '  'DIS']);
        fprintf(s,cmd);
        recvStr = '';
        while s.BytesAvailable > 0                                                  % CLEAR THE BUFFER
            recvStr =  fscanf(s,'%s',s.BytesAvailable);  pause(.001);
        end
        
        if(~strcmp(recvStr, ''))
            fprintf('\n sendCmd bytes in buffer :  <%s>\n', cmd, recvStr);
        end
        volumeGiven = recvStr(6:10);
    else
        volumeGiven = NaN;
    end