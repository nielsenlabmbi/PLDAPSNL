function p = setupIntan(p)

if p.trial.ephys.use
    msg = tcpip(p.trial.ephys.IP,p.trial.ephys.tcpRemotePort, 'NetworkRole',p.trial.ephys.role);
    if(strcmp(msg.Status, 'closed'))
        fprintf(['\nTcpMessenger connecting to ' p.trial.ephys.IP '\n']);
        fopen(msg);
    end
    p.trial.ephys.msg = msg;
    
    %update file name - launch iteractive dialog box
    p = pds.intan.updateIntanName(p);
    
    %start recording
    fwrite(p.trial.ephys.msg,'record');
    
    %set trigger status to 0
    p.trial.ephys.trigger.state=0;

end