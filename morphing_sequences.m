clear all;

% Launched march 14th from a Windows VM - to know if crashes or not

root_data_dir = 'Z:/STRAIGHT_48000Hz_morphing9_test/';
n_steps = 9;
morph_factors = 0.0:(1/(n_steps-1)):1.0;
n_morph_seq_with_errors = 0;

for seq_index=0:1514
    disp(['===== Sequence ' num2str(seq_index) ' =====']);
    
    seq_dir = [root_data_dir num2str(seq_index,'%05d') '/'];
    
    % We have to work with Morphing Objects
    source=createMobject;
    target=createMobject;
    [x,fs] = audioread([seq_dir 'start.wav']);
    source=updateFieldOfMobject(source,'waveform',x);
    [x2,fs2] = audioread([seq_dir 'end.wav']);
    target=updateFieldOfMobject(target,'waveform',x2);
    if (length(x) ~= length(x2)) || (fs ~= fs2)
        error('Morphing inputs must have the same length and sampling frequency');
    end
    
    % Analysis
    tic
    source = executeSTRAIGHTanalysisM(source);
    target = executeSTRAIGHTanalysisM(target);
    disp("Analysis duration:");
    toc
    
    % Morphing: only the 3rd solution is viable
    % Others need some manual time alignment
    tic
    n_steps_with_error = 0;  % number of morphing that have failed
    for i=1:n_steps
        try
            % Error detection (e.g. in sequence 207... incompatible shapes)
            mObject = directSTRAIGHTmorphing(source,target, morph_factors(i), 'linear');
            sy_morphed = executeSTRAIGHTsynthesisM(mObject);
            morphing_error = false;
        catch exception
            morphing_error = true;
            disp(exception);
        end
        if morphing_error == false
            % / 32768 alone: still occasionaly leads to a clipping (morphing 'diverges')
            sy_morphed = 0.99 * sy_morphed / 32768.0;
            if max(abs(sy_morphed)) > 0.99
                sy_morphed = 0.99 * sy_morphed / max(abs(sy_morphed));
            end
        else  % morphing error did happen
            warning(['MORPHING ERROR - sequence ' num2str(seq_index) ' step ' num2str(i-1)]);
            n_steps_with_error = n_steps_with_error + 1;
            % write a null audio file
            sy_morphed = x * 0.0;
        end
        audiowrite([seq_dir 'audio_step' num2str(i-1, '%02d') '.wav'], sy_morphed, fs);
    end
    if n_steps_with_error == n_steps
        error(['All steps from morphing sequence ' num2str(seq_index) ' have failed']);
    elseif n_steps_with_error > 0
        n_morph_seq_with_errors = n_morph_seq_with_errors + 1;
        warning(['n_morph_seq_with_errors = ' num2str(n_morph_seq_with_errors)]);
    end
    disp("Resynthesis duration (TOTAL):");
    toc
    
end

disp(['========== End. n_morph_seq_with_errors = ' num2str(n_morph_seq_with_errors) ' ==========']);
