%% basic 2P for debugging

% open
    port = instrfindall('RemoteHost',p.trial.twoP.IP);
    if ~isempty(port)
        fclose(port);
        delete(port);
        clear port;
    end
    
    p.trial.twoP.sbudp  = udp('172.30.11.132', 'RemotePort', 7000);
    fopen(p.trial.twoP.sbudp);
    
    
    stat=get(p.trial.twoP.sbudp, 'Status');
    
    if ~strcmp(stat, 'open')
        disp([' Trouble opening connection to sbserver; cannot proceed']);
        p.trial.twoP.sbudp=[];
        return;
    else
        disp('UDP connection to sbserver established');
    end
    
 % shutter
 %state = 1 to open, 0 to close
fprintf(p.trial.twoP.sbudp,s);
 
 % close
 %close the udp connection
if ~isempty(p.trial.twoP.sbudp)
    fclose(p.trial.twoP.sbudp);
    p.trial.twoP.sbudp = [];
end


port = instrfindall('RemoteHost',p.trial.twoP.IP);
    if ~isempty(port)
        fclose(port);
        delete(port);
        clear port;
    end
    
end