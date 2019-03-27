function p = stopIntan(p)

if p.trial.ephys.use
    fwrite(p.trial.ephys.msg,'stop')
end