function stopIntan(p)

if p.trial.ephys.use
    fwrite(p.ephys.msg,'stop')
end