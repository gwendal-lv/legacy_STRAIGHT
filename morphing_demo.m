clear all;

% We have to work with Morphing Objects
source=createMobject;
target=createMobject;
[x,fs] = audioread('lead_4s_48000Hz.wav');
source=updateFieldOfMobject(source,'waveform',x);
[x,fs] = audioread('organ_4s_48000Hz.wav');
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
mObject = directSTRAIGHTmorphing(source,target,0.5,'linear');
sy_morphed = executeSTRAIGHTsynthesisM(mObject) / 32768;
disp("Resynthesis duration:");
toc

audiowrite('lead_MORPH_organ.wav', sy_morphed, fs);
