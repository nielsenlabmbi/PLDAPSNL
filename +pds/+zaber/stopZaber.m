function stopZaber(p)

global zaber 


if p.trial.zaber.use
    import zaber.motion.Library;
    import zaber.motion.ascii.Connection;
   
    zaber.connection.close();
    
end