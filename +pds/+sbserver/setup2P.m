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
    
    %update file name - launch iteractive dialog box
    p.trial.session.subject = input('Enter the animal ID:','s');
    p.trial.session.unit = input('Enter the unit #','s');
    p.trial.session.expt = input('Enter the experiment #','s');
    
    pds.sbserver.send_sbserver(p,sprintf('A%s',p.trial.session.subject));
    pds.sbserver.send_sbserver(p,sprintf('U%s',p.trial.session.unit));
    pds.sbserver.send_sbserver(p,sprintf('E%s',p.trial.session.expt));
%     
%     pds.sbserver.send_sbserver(p,sprintf('A%s',p.defaultParameters.session.subject));
%     pds.sbserver.send_sbserver(p,sprintf('U%s',p.defaultParameters.session.unit));
%     pds.sbserver.send_sbserver(p,sprintf('E%s',p.defaultParameters.session.expt));
    
    
    %start the laser
    pds.sbserver.send_sbserver(p,'G');
    %blank the laser until trial initiation
    pds.sbserver.shutter2P(p,'0');
    

end
