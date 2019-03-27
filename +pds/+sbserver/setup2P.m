function p = setup2P(p)

if p.trial.twoP.use
    
    port = instrfindall('RemoteHost',p.trial.twoP.IP);
    if ~isempty(port)
        fclose(port);
        delete(port);
        clear port;
    end
    
    p.trial.twoP.sbudp  = udp(p.trial.twoP.IP, 'RemotePort', p.trial.twoP.udpRemortPort);
    fopen(p.trial.twoP.sbudp);
    
    
    stat=get(p.trial.twoP.sbudp, 'Status');
    
    if ~strcmp(stat, 'open')
        disp([' Trouble opening connection to sbserver; cannot proceed']);
        p.trial.twoP.sbudp=[];
        return;
    else
        disp('UDP connection to sbserver established');
    end
    
    %update file name
    p = pds.sbserver.updateSBname(p);

    %start the laser
    pds.sbserver.send_sbserver(p,'G');
    %blank the laser until trial initiation
    pds.sbserver.shutter2P(p,'0');
    

end
