function p = updateSBname(p)
    
    %update file name - launch iteractive dialog box
%     p.trial.session.subject = input('Enter the animal ID:','s');
%     p.trial.session.unit = input('Enter the unit #','s');
%     p.trial.session.expt = input('Enter the experiment #','s');
%     
%     pds.sbserver.send_sbserver(p,sprintf('A%s',p.trial.session.subject));
%     pds.sbserver.send_sbserver(p,sprintf('U%s',p.trial.session.unit));
%     pds.sbserver.send_sbserver(p,sprintf('E%s',p.trial.session.expt));
%     
%     pds.sbserver.send_sbserver(p,sprintf('A%s',p.defaultParameters.session.subject));
%     pds.sbserver.send_sbserver(p,sprintf('U%s',p.defaultParameters.session.unit));
%     pds.sbserver.send_sbserver(p,sprintf('E%s',p.defaultParameters.session.expt));
    
    pds.sbserver.send_sbserver(p,sprintf('A%s',p.defaultParameters.session.filename));
    pds.sbserver.send_sbserver(p,sprintf('U%s','000'));
    pds.sbserver.send_sbserver(p,sprintf('E%s','000'));
    
    % pause to allow response on sb machine
    WaitSecs(5);
