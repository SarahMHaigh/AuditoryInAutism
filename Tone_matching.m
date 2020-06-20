%% NARSAD Behavioural tone matching task for roving ERP study
% Vol 67%

clearvars

Screen('CloseAll');
AssertOpenGL;

% RestrictKeysForKbCheck([27 83 68]); % 83=s, 68=d, 2
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

rep_N = 2;

screens=Screen('Screens');
screenNumber=max(screens);
[windowPr, rect] = Screen('OpenWindow',screenNumber,127.5,[]);%0,0,1920/2,1080/2]); % @ to abort

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

% Specs for the tone

toneFreq = [1046.5 1062.2 1077.9 1108.73 1244.51];  % Tone frequency, in Hertz
Fs = 48000;       % Samples per second
dt = 1/Fs;
nSeconds = 0.05;   % Duration of the sound
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
    yT = [sin(2*pi*toneFreq(i)*t_beep)];% zeros(size(t_beep))];
    maxVol = ones(1,length(yT));
    Vol = yT.*(maxVol);
    mid = ones(1,length(Vol) - length(rampUp) - length(rampDown));
    envelope = [rampUp mid rampDown];
    shapedVol(i,:) = Vol.*envelope;
end

pairs = {[1, 2] [1, 3] [1, 4] [1, 5] [2, 1] [2, 3] [2, 4] [2, 5]...
        [3, 1] [3, 2] [3, 4] [3,5] [4, 1] [4, 2] [4, 3] [4, 5]...
        [5, 1] [5, 2] [5, 3] [5, 4]};
task = [(ones(length(pairs),1)') (ones(length(pairs),1)*2)'];

Screen('FillRect', windowPr, 127.5);
DrawFormattedText(windowPr, 'You will be presented with two tones', 'center', (rect(4)/8)*2);
DrawFormattedText(windowPr, 'If the tones sound the same, press the S key', 'center', (rect(4)/8)*3);
DrawFormattedText(windowPr, 'If the tones sound different, press the D key', 'center', (rect(4)/8)*4);
DrawFormattedText(windowPr, 'Press the S key to continue', 'center', (rect(4)/8)*5);
Screen('Flip', windowPr);
WaitSecs(.1);
KbWait;

StartTime = GetSecs;

Screen('DrawLine', windowPr ,[0 0 0], H1, V, H2, V, penWidth);
Screen('DrawLine', windowPr ,[0 0 0], H, V1, H, V2, penWidth);
Screen('Flip', windowPr);
WaitSecs(0.5);

p = 1; t = 1; sz = 1;
for rep = 1:rep_N
    
    randtask = task(randperm(length(task)));
    
    tone = repmat(1:5,4*rep_N);
    randtone = tone(randperm(length(tone)));
    
    pairsRep = repmat(pairs,rep_N);    
    pairsRand = pairsRep(randperm(length(pairsRep)));
    
    for j = 1:length(task)
    
    if randtask(j) == 1
        presentVol = shapedVol(randtone(t),:);
        sound(presentVol, Fs);
        WaitSecs(.5);
        
        presentVol = shapedVol(randtone(t),:);
        sound(presentVol, Fs);
        WaitSecs(.5);
       
    elseif randtask(j) == 2            
        presentVol = shapedVol(pairsRand{p}(1),:);
        sound(presentVol, Fs);
        WaitSecs(.5);
        
        presentVol = shapedVol(pairsRand{p}(2),:);
        sound(presentVol, Fs);
        WaitSecs(.5);

    end
    
        secs0 = GetSecs;
        
        KbWait;
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        
        if keyCode(27)
            terminate = 1;
            break
        end
        naming = sort(KbName(keyCode));
        if randtask(j) == 1
            out{1,sz} = randtone(t);
            out{2,sz} = randtone(t);
            t = t+1;
        elseif randtask(j) == 2
            out{1,sz} = pairsRand{p}(1);
            out{2,sz} = pairsRand{p}(2);
            p = p+1;
        end
%         out{3,sz} = naming;
        if strmatch(naming, 's')
            out{3,sz} = 0;
        elseif strmatch(naming, 'd')
            out{3,sz} = 1;
        end
        out{4,sz} = secs-secs0;
        sz = sz+1;    
        
        WaitSecs(1);
    end
    
    if keyCode(27)
        terminate = 1;
        break
    end
    
    Screen('DrawLine', windowPr ,[0 0 0], H1, V, H2, V, penWidth);
    Screen('DrawLine', windowPr ,[0 0 0], H, V1, H, V2, penWidth);
    Screen('Flip', windowPr);
    WaitSecs(1);

    if rep == rep_N
        Screen('FillRect', windowPr, 127.5);
        DrawFormattedText(windowPr, 'Thank you, you have finished', 'center', (rect(4)/8)*3);
        DrawFormattedText(windowPr, 'Please tell experimenter', 'center', (rect(4)/8)*4);
        Screen('Flip', windowPr);
        EndTime = GetSecs-StartTime;
        WaitSecs(5);
    else
        Screen('FillRect', windowPr, 127.5);
        DrawFormattedText(windowPr, 'Please take a break', 'center', (rect(4)/8)*3);
        DrawFormattedText(windowPr, 'When ready, press any key to continue', 'center', (rect(4)/8)*4);
        Screen('Flip', windowPr);
        EndTime = GetSecs-StartTime;
        KbWait;
        Screen('DrawLine', windowPr ,[0 0 0], H1, V, H2, V, penWidth);
        Screen('DrawLine', windowPr ,[0 0 0], H, V1, H, V2, penWidth);
        Screen('Flip', windowPr);
        WaitSecs(0.5);
    end
end

Screen('CloseAll');

for tr = 1:length(out)
    if out{1,tr} == out{2,tr}
        out{5,tr} = 0;
    elseif out{1,tr} ~= out{2,tr}
        if out{1,tr} == 1
            t1 = 1046.5;
        elseif out{1,tr} == 2
            t1 = 1062.2;
        elseif out{1,tr} == 3
            t1 = 1077.9;
        elseif out{1,tr} == 4
            t1 = 1108.73;
        elseif out{1,tr} == 5
            t1 = 1244.51;
        end
        
        if out{2,tr} == 1
            t2 = 1046.5;
        elseif out{2,tr} == 2
            t2 = 1062.2;
        elseif out{2,tr} == 3
            t2 = 1077.9;
        elseif out{2,tr} == 4
            t2 = 1108.73;
        elseif out{2,tr} == 5
            t2 = 1244.51;
        end
        
        out{5,tr} = abs(t1-t2);
        
        clearvars t1 t1;
    end
end

pTaba = pivottable(out',[],5,3,@mean);
pTabb = cell2mat(pTaba)';

% figure(1);plot(pTabb(:,1),pTabb(:,2));

rtTaba = pivottable(out',[],5,4,@mean);
rtTabb = cell2mat(rtTaba)';

% figure(2);plot(rtTabb(:,1),rtTabb(:,2));

% dlmwrite([P '_ToneMatch.txt'],out);
xlswrite([P '_ToneMatch.xlsx'],out,1); %%%% make sure this line runs!!!!
xlswrite([P '_ToneMatch.xlsx'],pTabb,2);
xlswrite([P '_ToneMatch.xlsx'],rtTabb,3);

ListenChar(0);
