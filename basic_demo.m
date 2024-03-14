clear all;

% use audioread instead of the deprecated wavread
% default sound: 800ms at 22.5 kHz
[x,fs] = audioread('vaiueo2d.wav');

% OLD f0 and ap extractors
%tic
% Source params = f0 + periodicity indices (ap)
%[f0raw,ap]=exstraightsource(x,fs);  % quite fast (a few seconds)
%toc

% NEW f0 and ap extractors (interpseech 05)
% TODO: find an automatic solution if pitch cannot be estimated
%   e.g. use a default fixed f0 vecror? (corresponding to the MIDI 
%        note played?) Or: Same as SMT?
tic
f0raw = MulticueF0v14(x,fs);
ap = exstraightAPind(x,fs,f0raw);
toc

tic
% smoothed Time-freq representation - a time slice is called a
% "STRAIGHT spectrum" by the authors
n3sgram=exstraightspec(x,f0raw,fs);
toc

tic
% re-synthesis (here, without modif)
sy = exstraightsynth(f0raw,n3sgram,ap,fs);
% That demo leads to a distorted sound (amplitude definitely too high)
% "output normalized to -22dB vs. 16bit integer"
% Official doc says to compute sy/32768
sy = sy / 32768;
toc

sound(sy, fs);
audiowrite('vaiueo2d_resynthesized.wav', sy, fs);
