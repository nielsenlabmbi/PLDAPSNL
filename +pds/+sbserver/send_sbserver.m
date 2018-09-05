function p = send_sbserver(p,s)

if p.trial.twoP.use && ~isempty(p.trial.twoP.sbudp)
    fprintf(p.trial.twoP.sbudp,s);
end