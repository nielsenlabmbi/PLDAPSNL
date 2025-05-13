function p=stopcam(p)

%stop camera acquisition

if p.trial.camera.use %just to double check
    msg='S~';
    %fwrite(p.trial.camera.udpHandle,msg);
    %pds.behavcam.waitforCamResp(p);    
end
