function p=stopcam(p)

%stop camera acquisition
%5/22/25 fwrite commented out (not using this far)

if p.trial.camera.use %just to double check
    msg='S~';
    %fwrite(p.trial.camera.udpHandle,msg);
    %pds.behavcam.waitforCamResp(p);    
end
