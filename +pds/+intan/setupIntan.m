function p = setupIntan(p)

if p.trial.ephys.use
    msg = tcpip(p.trial.ephys.IP,p.trial.ephys.tcpRemotePort, 'NetworkRole',p.trial.ephys.role);
    if(strcmp(msg.Status, 'closed'))
        fprintf(['\nTcpMessenger connecting to ' p.trial.ephys.IP '\n']);
        fopen(msg);
    end
    p.ephys.msg = msg;
    
    %update file name - launch iteractive dialog box
    p.session.subject = input('Enter the animal ID:','s');
    p.session.unit = input('Enter the unit #','s');
    p.session.expt = input('Enter the experiment #','s');
    
    name = [p.session.subject '_u' p.session.unit '_' p.session.expt];
    
    dd = fullfile(p.trial.ephys.dataRoot,p.session.subject,name);
    
    name = ['basefilename ' dd];
    fwrite(p.ephys.msg, name)
    
    %start recording
    fwrite(p.ephys.msg,'record');
    
end