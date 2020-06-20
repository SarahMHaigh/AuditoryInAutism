%% NARSAD ERP task
% roving simple tones while fixation flashes

clear all;

Screen('Preference', 'SkipSyncTests', 0);
beep OFF;

fail1='Program aborted. Participant number not entered';
prompt = {'Enter participant number:'};
dlg_title = 'New Participant';
num_lines = 1;
def = {'0'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
switch isempty(answer)
    case 1
        error(fail1)
    case 0
        thissub=(answer{1});
end

ID = thissub;

HideCursor;

[windowPr,rect] = Screen('OpenWindow',0,0,[]);
width=rect(RectRight)-rect(RectLeft);
height=rect(RectBottom)-rect(RectTop);

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
DrawFormattedText(windowPr, 'Make sure volume is set to 40', 'center', (rect(4)/8)*4);
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
DrawFormattedText(windowPr, 'Hit button when you see the central cross flash', 'center', (rect(4)/8)*3);
DrawFormattedText(windowPr, 'Remember to focus on center cross', 'center', (rect(4)/8)*4);
DrawFormattedText(windowPr, 'Press any key to continue', 'center', (rect(4)/8)*5);
Screen('Flip', windowPr); 
WaitSecs(.1);
KbWait;  

Screen('DrawLine', windowPr ,[0 0 0], H1, V, H2, V, penWidth); 
Screen('DrawLine', windowPr ,[0 0 0], H, V1, H, V2, penWidth);
Screen('Flip', windowPr);   

% Specs for the tone
toneFreq = [1046.5 1108.73 1244.51];
Fs = 48000;
dt = 1/Fs;
nSeconds = 0.05;
t_beep = [dt:dt:nSeconds];
Tattack = 0.005;

% cosine ramp
A=(0:dt:Tattack)/Tattack;
Tfade=(pi/(length(A)-.5));
RaisedCosine=cos(pi:Tfade:3*pi)+1;
RaisedCosineNormSquare=(RaisedCosine/max(RaisedCosine)).^2;
A=RaisedCosineNormSquare(1:(length(RaisedCosineNormSquare)/2));
rampUp = A;
rampDown = fliplr(rampUp);

% tones + envelope
for i = 1:length(toneFreq)
    yT = [sin(2*pi*toneFreq(i)*t_beep)];
    maxVol = ones(1,length(yT));
    Vol = yT.*(maxVol);
    mid = ones(1,length(Vol) - length(rampUp) - length(rampDown));
    envelope = [rampUp mid rampDown];
    shapedVol(i,:) = Vol.*envelope;
end

trial = repmat([1 2 3, 1 3 2, 3 2 1, 2 1 3, 2 3 1, 3 1 2],1,4);
    
c = length(trial)/2;
repNo = repmat([3 9],1,c);
d = length(trial)/6;
att = [zeros(1,length(trial)-d) ones(1,d)];
attrand = att(randperm(length(att))); 
block = 6;
randrep = repNo(randperm(length(repNo))); 

RT = [];
secs0 = 0;     

%%% set up triggering
object = io64;
status = io64(object);
address = hex2dec('CFF8');

clearvars pressed firstPress KbWait

% start the log file for reporting
logFID = fopen([ID '_simple.txt'],'at+');

KbQueueCreate;

start = GetSecs;

for k = 1:block

KbQueueStart;

for i = 1:length(trial)
    
    if trial(i)==1 && randrep(i)==3
        y = shapedVol(1,:);
        trialinfo = 1;
    elseif trial(i)==2 && randrep(i)==3
        y = shapedVol(2,:);
        trialinfo = 2;
    elseif trial(i)==3 && randrep(i)==3
        y = shapedVol(3,:);
        trialinfo = 3; 
    elseif trial(i)==1 && randrep(i)==9
        y = shapedVol(1,:);
        trialinfo = 4;
    elseif trial(i)==2 && randrep(i)==9
        y = shapedVol(2,:);
        trialinfo = 5;
    elseif trial(i)==3 && randrep(i)==9
        y = shapedVol(3,:);
        trialinfo = 6; 
    end
    
    for j = 1:randrep(i)
        sound(y, Fs);
        io64(object, address, trialinfo);
        WaitSecs(.05);
        io64(object, address, 0);
        WaitSecs(.33);
        sz = size(RT);
        RT(1,sz(2)+1) = trial(i);
        RT(2,sz(2)+1) = randrep(i);
        RT(3,sz(2)+1) = attrand(i);
        
        [pressed, firstPress]=KbQueueCheck; 
        if pressed==1
            io64(object, address, 11);
            WaitSecs(.05);
            io64(object, address, 0);
            react = max(firstPress)-secs0;
            RT(4,sz(2)+1) = react;
            pressedKeys=find(firstPress);
            if pressedKeys == 27
                Screen('CloseAll')
                fclose(logFID);  
            end
            clearvars pressed firstPress
        else
            react = 0;
        end
        
        % print to logfile:
        fprintf(logFID,['%d\t%d\t%d\t%d\t\n']', trial(i), randrep(i), attrand(i), react);
        
    end
    if attrand(i) == 1
        Screen('FillRect',windowPr,127.5);
        Screen('DrawLine', windowPr ,[255 255 255], H1, V, H2, V, penWidth);
        Screen('DrawLine', windowPr ,[255 255 255], H, V1, H, V2, penWidth);
        Screen('Flip', windowPr);
        io64(object, address, 12);
        WaitSecs(.05);
        io64(object, address, 0);
        secs0 = GetSecs;
        WaitSecs(.1);
        Screen('FillRect',windowPr,127.5);
        Screen('DrawLine', windowPr ,[0 0 0], H1, V, H2, V, penWidth); 
        Screen('DrawLine', windowPr ,[0 0 0], H, V1, H, V2, penWidth);
        Screen('Flip', windowPr);
        [pressed, firstPress]=KbQueueCheck;  
    end
end

if k == block
    Screen('FillRect',windowPr,127.5,rect); 
    DrawFormattedText(windowPr, 'You have finished', 'center', (rect(4)/8)*3);
    DrawFormattedText(windowPr, 'Please find experimenter', 'center', (rect(4)/8)*4);
    Screen('Flip', windowPr); 
    WaitSecs(1);    
    dlmwrite([cd '/' ID 'simple_sound.txt'], RT);
    xlswrite([cd '/' ID 'simple_sound.xlsx'], RT);
    Screen('CloseAll');
else
    Screen('FillRect',windowPr,127.5,rect);
    DrawFormattedText(windowPr, 'Please take a break', 'center', (rect(4)/8)*3);
    DrawFormattedText(windowPr, 'Press any key to continue', 'center', (rect(4)/8)*4);
    Screen('Flip', windowPr); 
    WaitSecs(.1);
    KbWait;
    Screen('DrawLine', windowPr ,[0 0 0], H1, V, H2, V, penWidth); 
    Screen('DrawLine', windowPr ,[0 0 0], H, V1, H, V2, penWidth);
    Screen('Flip', windowPr);
end

end
       
finish = GetSecs-start;

fclose(logFID);
dlmwrite([cd '/' ID 'simple_sound.txt'], RT);
xlswrite([cd '/' ID 'simple_sound.xlsx'], RT);