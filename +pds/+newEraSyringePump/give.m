function p = give(p, amount)
%pds.newEraSyringePump.give   dispense a specified amount of volume
%
% p = pds.newEraSyringePump.getVolume(p)
%
% jk wrote it 2015
% edw edited 2017

if p.trial.newEraSyringePump.use(p.trial.side)
    s = p.trial.newEraSyringePump.s;
    if nargin <2 %repeat last given Volume
        cmd = sprintf([num2str(p.trial.side) ' ' 'RUN']);
        fprintf(s,cmd);
    elseif amount>=0.001
        cmd = sprintf([num2str(p.trial.side) ' ' 'VOL' sprintf('%3.3f',amount) ]);                                 % pump1, query alarm status
        fprintf(s,cmd);
        cmd = sprintf([num2str(p.trial.side) ' ' 'RUN']);
        fprintf(s,cmd);
    end
end