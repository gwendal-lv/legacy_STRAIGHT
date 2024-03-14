clear all;

% Launched march 14th from a Windows VM - to know if crashes or not

root_data_dir = 'Z:/STRAIGHT_48000Hz_morphing9_test/';
n_steps = 9;
morph_factors = 0.0:(1/(n_steps-1)):1.0;

for seq_index=0:1514
    disp(['===== Sequence ' num2str(seq_index) ' =====']);
    
    seq_dir = [root_data_dir num2str(seq_index,'%05d') '/'];
    
    % We have to work with Morphing Objects
    source=createMobject;
    target=createMobject;
    [x,fs] = audioread([seq_dir 'start.wav']);
    source=updateFieldOfMobject(source,'waveform',x);
    [x,fs] = audioread([seq_dir 'end.wav']);
    target=updateFieldOfMobject(target,'waveform',x);
    
    % Analysis
    tic
    source = executeSTRAIGHTanalysisM(source);
    target = executeSTRAIGHTanalysisM(target);
    disp("Analysis duration:");
    toc
    
    % Morphing: only the 3rd solution is viable
    % Others need some manual time alignment
    tic
    for i=1:n_steps
        mObject = directSTRAIGHTmorphing(source,target, morph_factors(i), 'linear');
        % / 32768 alone: still leads to a clipping warnings
        sy_morphed = 0.99 * executeSTRAIGHTsynthesisM(mObject) / 32768;
        audiowrite([seq_dir 'audio_step' num2str(i-1, '%02d') '.wav'], sy_morphed, fs);
    end
    disp("Resynthesis duration (TOTAL):");
    toc
    
end
