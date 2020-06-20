%% NARSAD Behavioral emotion recognition task
% Vocal Burst stimuli

clearvars

Screen('CloseAll');
AssertOpenGL;

% RestrictKeysForKbCheck([27 83 68]); % 83=s, 68=d, 
fail1='Program aborted. Participant number not entered'; % error message which is printed to command window
prompt = {'Enter participant number:'};
dlg_title = 'New Participant';
num_lines = 1;
def = {'0'};
answer = inputdlg(prompt,dlg_title,num_lines,def); %presents box to enter data into
switch isempty(answer)
    case 1 %deals with both cancel and X presses
        error(fail1)
    case 0
        thissub=(answer{1});
end

P = thissub;  %%% ADD PARTICIPANT NUMBER HERE

screens=Screen('Screens');
screenNumber=max(screens);
[windowPr, rect] = Screen('OpenWindow',screenNumber,127.5,[]);%0,0,1920/2,1080/2]); % @ to abort

start = GetSecs;

width = rect(RectRight) - rect(RectLeft);
height = rect(RectBottom)-rect(RectTop);

white = WhiteIndex(windowPr);
black = BlackIndex(windowPr);
gray = 97; 
[xCenter, yCenter] = RectCenter(rect);

% fixation cross coords
H=width/2; 
H1=width/2-(width/2/70);
H2=width/2+(width/2/70);
V=height/2;
V1=height/2-(width/2/70);
V2=height/2+(width/2/70);
penWidth=2;
textsize=40;
Font='Arial'; Screen('TextSize',windowPr,textsize); Screen('TextFont',windowPr,Font); Screen('TextColor',windowPr,black);
 
Screen('FillRect',windowPr,127.5,rect);
DrawFormattedText(windowPr, 'Experimenter:', 'center', (rect(4)/8)*3);
DrawFormattedText(windowPr, 'Make sure volume is set to 100', 'center', (rect(4)/8)*4);
DrawFormattedText(windowPr, 'Press 1 to quit', 'center', (rect(4)/8)*5);
Screen('Flip', windowPr); 
WaitSecs(.1);
KbWait;

[keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
naming = sort(KbName(keyCode));
if str2num(naming)==1
    Screen('CloseAll');
end

Screen('FillRect',windowPr,127.5,rect); 
DrawFormattedText(windowPr, 'Once the sound has played, please respond using corresponding number', 'center', (rect(4)/8)*3);
DrawFormattedText(windowPr, 'Press any key to continue', 'center', (rect(4)/8)*4);
Screen('Flip', windowPr); 
WaitSecs(.1);
KbWait; 

% sound info
path = 'C:\ExperimentData\SarahHaigh\NARSAD\stimuli\';

s01 = audioread([path 'a011b2_CUT.wav']);
s02 = audioread([path 'a042b_CUT.wav']);
s03 = audioread([path 'a051b_CUT.wav']);
s04 = audioread([path 'a061b_CUT.wav']);

s05 = audioread([path 'b012b_CUT.wav']);
s06 = audioread([path 'b041b_CUT.wav']);
s07 = audioread([path 'b051b_CUT.wav']);
s08 = audioread([path 'b061b_CUT.wav']);

s09 = audioread([path 'h013b_CUT.wav']);
s10 = audioread([path 'h046b_CUT.wav']);
s11 = audioread([path 'h063b_CUT.wav']);
s12 = audioread([path 'h071b_CUT.wav']);

s13 = audioread([path 'j031b_CUT.wav']);
s14 = audioread([path 'j051b_CUT.wav']);
s15 = audioread([path 'j052b_CUT.wav']);
s16 = audioread([path 'j071b_CUT.wav']);

s17 = audioread([path 'k042b_CUT.wav']);
s18 = audioread([path 'k054b_CUT.wav']);
s19 = audioread([path 'k061b_CUT.wav']);
s20 = audioread([path 'k092b_CUT.wav']);

Fs = 44100;

trial = {'s01' 's02' 's03' 's04' 's05' 's06' 's07' 's08' 's09' 's10' 's11' 's12' 's13' 's14' 's15' 's16' 's17' 's18' 's19' 's20'};
block = 3;

vol = [1 .1];
randvol = vol(randperm(length(vol)));

resp = [];

for z = 1:length(vol)
for j = 1:block
    
    randtrial = trial(randperm(length(trial)));

for i = 1:length(trial)
    
    Screen('DrawLine', windowPr ,[0 0 0], H1, V, H2, V, penWidth);
    Screen('DrawLine', windowPr ,[0 0 0], H, V1, H, V2, penWidth);
    Screen('Flip', windowPr);
    WaitSecs(1+rand/2);

    DrawFormattedText(windowPr, 'Which emotion best matches the sound?', 'center', (rect(4)/8)*3);
    Screen('Flip', windowPr); 
    WaitSecs(.1);
    pl = eval(randtrial{i}).*randvol(z);
    sound(pl,Fs);
    secs0 = GetSecs;
    WaitSecs(2);
    
    DrawFormattedText(windowPr, 'Which emotion best matches the sound?', 'center', (rect(4)/8)*3);
    DrawFormattedText(windowPr, 'Laughter(1)   Frustration(2)   Disgust(3)   Delight(4)     Surprise(5)', 'center', (rect(4)/8)*4);
    Screen('Flip', windowPr); 
    WaitSecs(.1);
%     WaitSecs(1.5);
    KbWait;
    
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    naming = sort(KbName(keyCode));
    RT = secs-secs0;
    szR = size(resp);
    
    resp(1,szR(2)+1) = str2double(randtrial{i}(2:3));
    resp(2,szR(2)+1) = randvol(z);
    if isempty(naming);
        resp(3,szR(2)+1) = NaN;
    elseif isnumeric(str2num(naming))
        if length(str2num(naming))==1
            resp(3,szR(2)+1) = str2num(naming);
        end
    else resp(3,szR(2)+1) = NaN;
    end

    resp(4,szR(2)+1) = RT;
    
    clear KbWait
    
     if j == 2 && i == 10
        Screen('FillRect',windowPr,127.5,rect);
        DrawFormattedText(windowPr, 'Please take a break', 'center', (rect(4)/8)*3);
        DrawFormattedText(windowPr, 'Press any key to continue', 'center', (rect(4)/8)*4);
        Screen('Flip', windowPr); 
        WaitSecs(.1);
        KbWait;
    end
    
end
end

% textsize=40;
% Font='Arial'; Screen('TextSize',windowPr,textsize); Screen('TextFont',windowPr,Font); Screen('TextColor',windowPr,white);

Screen('FillRect',windowPr,127.5,rect); 
DrawFormattedText(windowPr, 'Please take a break', 'center', (rect(4)/8)*3);
DrawFormattedText(windowPr, 'When you are ready, press any key to continue', 'center', (rect(4)/8)*4);
Screen('Flip', windowPr); 
WaitSecs(.1);
KbWait;
% WaitSecs(1);

end

fin = GetSecs;
tot = fin-start;

% textsize=40;
% Font='Arial'; Screen('TextSize',windowPr,textsize); Screen('TextFont',windowPr,Font); Screen('TextColor',windowPr,white);

Screen('FillRect',windowPr,127.5,rect); 
DrawFormattedText(windowPr, 'Thank you. You have finished the experiment', 'center', (rect(4)/8)*3);
Screen('Flip', windowPr); 
WaitSecs(1);

xlswrite([P '_EmoID.xlsx'],resp);

Screen('CloseAll');