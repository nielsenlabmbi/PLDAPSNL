function p = updateIntanName(p)
%     p.session.subject = input('Enter the animal ID:','s');
%     p.session.unit = input('Enter the unit #','s');
%     p.session.expt = input('Enter the experiment #','s');
%     
%     name = [p.session.subject '_u' p.session.unit '_' p.session.expt];
%     
%     dd = fullfile(p.trial.ephys.dataRoot,p.session.subject,name);

    name = p.defaultParameters.session.filename;
    dd = fullfile(p.trial.ephys.dataRoot,p.defaultParameters.session.subject,name);
    
    name = ['basefilename ' dd];
    fwrite(p.ephys.msg, name)
end