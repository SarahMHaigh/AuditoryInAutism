% to analyse EEG data using EEGLAB and ERPLAB
% Simple_tone and Complex_sound
% Delays from trig onset to start of stim = 300ms (simple=240ms,
% complex=370ms)

clear all

eeglab

path = pwd;
eegpath = '~/Documents/MATLAB/';

P = {'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25'...};
    'C1' 'C2' 'C3' 'C4' 'C5' 'C6' 'C7' 'C8' 'C9' 'C10' 'C11' 'C12' 'C13' 'C14' 'C15' 'C16' 'C17' 'C18' 'C19' 'C20' 'C21' 'C22' 'C23' 'C24' 'C25' 'C26' 'C27' 'C28'};
[~, szP] = size(P);

mods = {'SimpleTone' 'ComplexSound'};
[~, szMods] = size(mods);
alt = 0;

for j = 1:szP
    for i = 1:szMods
        pathup = [path P{j} '/' mods{i} '/'];
        if alt == 1
            EEG = pop_loadset('filename',[P{j} '_' mods{i} '.set'],'filepath',pathup);
            EEG=pop_chanedit(EEG, 'lookup',[ eegpath 'eeglab14_1_2b/plugins/dipfit2.3/NARSAD_cap_try.ced'],'load',{'/Users/sarahhaigh/Documents/MATLAB/eeglab14_1_2b/plugins/dipfit2.3/NARSAD_cap_copy.ced' 'filetype' 'chanedit'});
        else
            EEG = pop_biosig([pathup P{j} '_' mods{i} '.bdf'], 'ref',[129 130] ,'refoptions',{'keepref' 'off'});
            EEG.setname=[P(j) '_' mods(i)];
            EEG = eeg_checkset( EEG );
            EEG=pop_chanedit(EEG, 'lookup',[ eegpath 'eeglab14_1_2b/plugins/dipfit2.3/NARSAD_cap_try.ced']);
            EEG = eeg_checkset( EEG );
        end
        EEG = pop_eegfiltnew(EEG, 0.1,100,16896,0,[],0);
        EEG = eeg_checkset( EEG );       
        EEG = pop_saveset( EEG, 'filename',[P{j} '_' mods{i} '_filt.set'],'filepath',pathup);
    end
end

for j = 1:szP
    for i = 1:szMods
        pathup = [path P{j} '/' mods{i} '/'];
        EEG = pop_loadset('filename',[P{j} '_' mods{i} '_filt.set'],'filepath',pathup);
        EEG = pop_saveset( EEG, 'filename',[P{j} '_' mods{i} '_int.set'],'filepath',pathup);
    end
end

for j = 1:szP
    for i = 1:szMods
        pathup = [path P{j} '/' mods{i} '/'];
        EEG = pop_loadset('filename',[P{j} '_' mods{i} '_int.set'],'filepath',pathup);
        EEG = pop_eegchanoperator( EEG, {  'ch142 = ch129 - ch130 label hEOG',  'ch143 = ch132 - ch131 label vEOG'} , 'ErrorMsg', 'popup', 'Warning','on' );
        EEG = pop_select( EEG,'nochannel',{'LO1' 'LO2' 'IO1' 'SO1' 'IO2' 'GSR1' 'GSR2' 'Erg1' 'Erg2' 'Resp' 'Plet' 'Temp' 'EXG3' 'EXG4' 'EXG5' 'EXG6' 'EXG7'});
        EEG = eeg_checkset( EEG );
        EEG = pop_runica(EEG, 'extended',1,'interupt','on', 'chanind', [1:64 129:131]);
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename',[P{j} '_' mods{i} '_postica.set'],'filepath',pathup);
        EEG = eeg_checkset( EEG );
    end
end

for j = 1:szP
    for i = 1:szMods
        pathup = [path P{j} '/' mods{i} '/'];
        EEG = pop_loadset('filename',[P{j} '_' mods{i} '_postica_pruned.set'],'filepath',pathup);
        EEG = pop_select( EEG,'nochannel',{'LO1' 'LO2' 'IO1' 'SO1' 'IO2' 'GSR1' 'GSR2' 'Erg1' 'Erg2' 'Resp' 'Plet' 'Temp' 'EXG3' 'EXG4' 'EXG5' 'EXG6' 'EXG7'});
        if strmatch('Simple',mods{i})
            for n = 1:length(EEG.event)
                EEG.event(n).latency = EEG.event(n).latency+(298/2);
            end
        else
            for n = 2:length(EEG.event)
                EEG.event(n).latency = EEG.event(n).latency+(300/2);%430/2);
            end
        end
        EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
            [pathup P{j} '_' mods{i} '_conds.txt'] );
        EEG  = pop_binlister( EEG , 'BDF', [path mods{i} '_codes.txt'], 'ExportEL',...
            [pathup P{j} '_' mods{i} '_elist.txt'], 'ImportEL', [pathup P{j} '_' mods{i} '_conds.txt'],...
            'IndexEL',  1, 'SendEL2', 'EEG&Text', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
        
        if strmatch('Simple',mods{i})
            EEG = pop_epochbin( EEG , [-50.0  330.0],  'pre');
            EEG  = pop_artextval( EEG , 'Channel',  [1:64 129:131], 'Flag',  1, 'Threshold', [ -100 100], 'Twindow',...
            [ -50 330] );
        else
            EEG = pop_epochbin( EEG , [-150.0  1500.0],  'pre');
            EEG  = pop_artextval( EEG , 'Channel',  1:128, 'Flag',  1, 'Threshold', [ -200 200], 'Twindow',...
            [ -150 1500] );
        end
        EEG  = pop_basicfilter( EEG,  1:131 , 'Boundary', 'boundary', 'Cutoff',  20, 'Design', 'butter', 'Filter', 'lowpass', 'Order', 2 );        
        ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
        ERP = pop_savemyerp(ERP, 'erpname',...
            [P{j} '_' mods{i}], 'filename', [P{j} '_' mods{i} '.erp'], 'filepath', pathup, 'Warning', 'off');
        ERP = make_SEM_set(ERP,'gui',1);        
        ERP = pop_savemyerp(ERP, 'erpname',...
            [P{j} '_' mods{i} '_SEM'], 'filename', [P{j} '_' mods{i} '_SEM.erp'], 'filepath', pathup, 'Warning', 'off');        

    end
end

% Create simple ASD grand averages
ERP = pop_gaverager( '/Volumes/MyPassportC/NARSAD/SimpleTone_ASDgrandAvg.txt' , 'ExcludeNullBin', 'on' );
ERP = pop_savemyerp(ERP, 'erpname',...
 'Simple_ASDgrandAvg', 'filename', 'Simple_ASDgrandAvg.erp', 'filepath', '/Volumes/MyPassportC/NARSAD', 'Warning', 'off');

% Create small change
ERP = pop_binoperator( ERP, {  'bin33=(b9+b11+b15+b17)/4'});
% Create mid change
ERP = pop_binoperator( ERP, {  'bin34=(b12+b14+b18+b20)/4'});
% Create large change
ERP = pop_binoperator( ERP, {  'bin35=(b10+b13+b16+b19)/4'});
% Create average ERP
ERP = pop_binoperator( ERP, {  'bin36=(b32+b33+b34)/3'});

ERP = pop_ploterps( ERP,  33:35,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ -4.0 5.0   -3:3:3 ] );

% Create short chain
ERP = pop_binoperator( ERP, {  'bin37=(b9+b10+b11+b12+b13+b14)/6'});
% Create long chain
ERP = pop_binoperator( ERP, {  'bin38=(b15+b16+b17+b18+b19+b20)/6'});

ERP = pop_ploterps( ERP,  37:38,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ -4.0 5.0   -3:3:3 ] );

% Create small standard
ERP = pop_binoperator( ERP, {  'bin39=(b21+b23+b27+b29)/4'});
% Create mid standard
ERP = pop_binoperator( ERP, {  'bin40=(b24+b26+b30+b32)/4'});
% Create large standard
ERP = pop_binoperator( ERP, {  'bin41=(b22+b25+b28+31)/4'});

ERP = pop_ploterps( ERP,  39:41,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ -4.0 5.0   -3:3:3 ] );

% Create short standard
ERP = pop_binoperator( ERP, {  'bin42=(b21+b22+b23+b24+b25+b26)/6'});
% Create long standard
ERP = pop_binoperator( ERP, {  'bin43=(b27+b28+b29+b30+b31+b32)/6'});

ERP = pop_ploterps( ERP,  42:43,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ -4.0 5.0   -3:3:3 ] );

% Create small subtraction
ERP = pop_binoperator( ERP, {  'bin44=b33-b39'});
% Create mid subtraction
ERP = pop_binoperator(ERP, {  'bin45=b34-b40'});
% Create large subtraction
ERP = pop_binoperator( ERP, {  'bin46=b35-b41'});

ERP = pop_ploterps( ERP,  44:46,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ -4.0 5.0   -3:3:3 ] );

% Create short subtraction
ERP = pop_binoperator( ERP, {  'bin47=b37-b42'});
% Create long subtraction
ERP = pop_binoperator( ERP, {  'bin48=b38-b43'});

ERP = pop_ploterps( ERP,  47:48,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ -4.0 5.0   -3:3:3 ] );

% Create simple HC grand averages
ERP = pop_gaverager( '/Volumes/MyPassportC/NARSAD/SimpleTone_HCgrandAvg.txt' , 'ExcludeNullBin', 'on' );
ERP = pop_savemyerp(ERP, 'erpname',...
 'Simple_HCgrandAvg', 'filename', 'Simple_HCgrandAvg.erp', 'filepath', '/Volumes/MyPassportC/NARSAD', 'Warning', 'off');

% Create small change
ERP = pop_binoperator( ERP, {  'bin33=(b9+b11+b15+b17)/4'});
% Create mid change
ERP = pop_binoperator( ERP, {  'bin34=(b12+b14+b18+b20)/4'});
% Create large change
ERP = pop_binoperator( ERP, {  'bin35=(b10+b13+b16+b19)/4'});
% Create average ERP
ERP = pop_binoperator( ERP, {  'bin36=(b32+b33+b34)/3'});

ERP = pop_ploterps( ERP,  33:35,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ -4.0 5.0   -3:3:3 ] );

% Create short chain
ERP = pop_binoperator( ERP, {  'bin37=(b9+b10+b11+b12+b13+b14)/6'});
% Create long chain
ERP = pop_binoperator( ERP, {  'bin38=(b15+b16+b17+b18+b19+b20)/6'});

ERP = pop_ploterps( ERP,  37:38,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ -4.0 5.0   -3:3:3 ] );

% Create small standard
ERP = pop_binoperator( ERP, {  'bin39=(b21+b23+b27+b29)/4'});
% Create mid standard
ERP = pop_binoperator( ERP, {  'bin40=(b24+b26+b30+b32)/4'});
% Create large standard
ERP = pop_binoperator( ERP, {  'bin41=(b22+b25+b28+31)/4'});

ERP = pop_ploterps( ERP,  39:41,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ -4.0 5.0   -3:3:3 ] );

% Create short standard
ERP = pop_binoperator( ERP, {  'bin42=(b21+b22+b23+b24+b25+b26)/6'});
% Create long standard
ERP = pop_binoperator( ERP, {  'bin43=(b27+b28+b29+b30+b31+b32)/6'});

ERP = pop_ploterps( ERP,  42:43,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ -4.0 5.0   -3:3:3 ] );

%Create small subtraction
ERP = pop_binoperator( ERP, {  'bin44=b33-b39'});
% Create mid subtraction
ERP = pop_binoperator(ERP, {  'bin45=b34-b40'});
% Create large subtraction
ERP = pop_binoperator( ERP, {  'bin46=b35-b41'});

ERP = pop_ploterps( ERP,  44:46,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ -4.0 5.0   -3:3:3 ] );

% Create short subtraction
ERP = pop_binoperator( ERP, {  'bin47=b37-b42'});
% Create long subtraction
ERP = pop_binoperator( ERP, {  'bin48=b38-b43'});

ERP = pop_ploterps( ERP,  47:48,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ -4.0 5.0   -3:3:3 ] );

%% Create simple SEM
ERP = pop_gaverager( '/Volumes/MyPassportC/NARSAD/SimpleTone_ASDgrandAvg_SEM.txt' , 'ExcludeNullBin', 'on' );
ERP = pop_savemyerp(ERP, 'erpname',...
 'Simple_ASDgrandAvg_SEM', 'filename', 'Simple_ASDgrandAvg_SEM.erp', 'filepath', '/Volumes/MyPassportC/NARSAD', 'Warning', 'off');

% Create small change
ERP = pop_binoperator( ERP, {  'bin33=(b9+b11+b15+b17)/4'});
% Create mid change
ERP = pop_binoperator( ERP, {  'bin34=(b12+b14+b18+b20)/4'});
% Create large change
ERP = pop_binoperator( ERP, {  'bin35=(b10+b13+b16+b19)/4'});
% Create average ERP
ERP = pop_binoperator( ERP, {  'bin36=(b32+b33+b34)/3'});
% Create short chain
ERP = pop_binoperator( ERP, {  'bin37=(b9+b10+b11+b12+b13+b14)/6'});
% Create long chain
ERP = pop_binoperator( ERP, {  'bin38=(b15+b16+b17+b18+b19+b20)/6'});

ERP = pop_ploterps( ERP,  37:38,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ 0 5.0   0:1:5 ] );

ERP = pop_gaverager( '/Volumes/MyPassportC/NARSAD/SimpleTone_HCgrandAvg_SEM.txt' , 'ExcludeNullBin', 'on' );
ERP = pop_savemyerp(ERP, 'erpname',...
 'Simple_HCgrandAvg_SEM', 'filename', 'Simple_HCgrandAvg_SEM.erp', 'filepath', '/Volumes/MyPassportC/NARSAD', 'Warning', 'off');

% Create small change
ERP = pop_binoperator( ERP, {  'bin33=(b9+b11+b15+b17)/4'});
% Create mid change
ERP = pop_binoperator( ERP, {  'bin34=(b12+b14+b18+b20)/4'});
% Create large change
ERP = pop_binoperator( ERP, {  'bin35=(b10+b13+b16+b19)/4'});
% Create average ERP
ERP = pop_binoperator( ERP, {  'bin36=(b32+b33+b34)/3'});
% Create short chain
ERP = pop_binoperator( ERP, {  'bin37=(b9+b10+b11+b12+b13+b14)/6'});
% Create long chain
ERP = pop_binoperator( ERP, {  'bin38=(b15+b16+b17+b18+b19+b20)/6'});

ERP = pop_ploterps( ERP,  37:38,  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',  5, 'Maximize',...
 'on', 'Position', [ 68.6429 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -50.0 330.0   -50 0:100:300 ],...
 'YDir', 'normal', 'yscale', [ 0 5.0   0:1:5 ] );

%% Create complex ASD grand averages
ERP = pop_gaverager( '/Volumes/MyPassportC/NARSAD/Complex_ASDgrandAvg.txt' , 'ExcludeNullBin', 'on' );
ERP = pop_savemyerp(ERP, 'erpname',...
 'Complex_ASDgrandAvg', 'filename', 'Complex_ASDgrandAvg.erp', 'filepath', '/Volumes/MyPassportC/NARSAD', 'Warning', 'off');

ERP = pop_ploterps( ERP, [ 23 25 27 29],  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-', 'b-', 'g-' }, 'LineWidth',  5, 'Maximize', 'on',...
 'Position', [ 34.75 10.8333 106.875 31.9444], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -150.0 650.0   -100 0:200:650 ],...
 'YDir', 'normal', 'yscale', [ -6.0 8.0   -6:6:6 ] );

ERP = pop_ploterps( ERP, [ 31:34],  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-', 'b-', 'g-' }, 'LineWidth',  5, 'Maximize', 'on',...
 'Position', [ 34.75 10.8333 106.875 31.9444], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -150.0 650.0   -100 0:200:650 ],...
 'YDir', 'normal', 'yscale', [ -6.0 8.0   -6:6:6 ] );

% Create short delight subtraction
ERP = pop_binoperator( ERP, {  'bin35=b23-b31'});
% Create long delight subtraction
ERP = pop_binoperator( ERP, {  'bin36=b24-b32'});
% Create short frustration subtraction
ERP = pop_binoperator( ERP, {  'bin37=b25-b33'});
% Create long frustration subtraction
ERP = pop_binoperator( ERP, {  'bin38=b26-b34'});

ERP = pop_ploterps( ERP, [ 35:38],  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-', 'b-', 'g-' }, 'LineWidth',  5, 'Maximize', 'on',...
 'Position', [ 34.75 10.8333 106.875 31.9444], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -150.0 650.0   -100 0:200:650 ],...
 'YDir', 'normal', 'yscale', [ -6.0 8.0   -6:6:6 ] );

%% Create complex HC grand averages
ERP = pop_gaverager( '/Volumes/MyPassportC/NARSAD/Complex_HCgrandAvg.txt' , 'ExcludeNullBin', 'on' );
ERP = pop_savemyerp(ERP, 'erpname',...
 'Complex_HCgrandAvg', 'filename', 'Complex_HCgrandAvg.erp', 'filepath', '/Volumes/MyPassportC/NARSAD', 'Warning', 'off');

ERP = pop_ploterps( ERP, [ 23 25 27 29],  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-', 'b-', 'g-' }, 'LineWidth',  5, 'Maximize', 'on',...
 'Position', [ 34.75 10.8333 106.875 31.9444], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -150.0 650.0   -100 0:200:650 ],...
 'YDir', 'normal', 'yscale', [ -6.0 8.0   -6:6:6 ] );

ERP = pop_ploterps( ERP, [ 31:34],  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-', 'b-', 'g-' }, 'LineWidth',  5, 'Maximize', 'on',...
 'Position', [ 34.75 10.8333 106.875 31.9444], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -150.0 650.0   -100 0:200:650 ],...
 'YDir', 'normal', 'yscale', [ -6.0 8.0   -6:6:6 ] );

% Create short delight subtraction
ERP = pop_binoperator( ERP, {  'bin35=b23-b31'});
% Create long delight subtraction
ERP = pop_binoperator( ERP, {  'bin36=b24-b32'});
% Create short frustration subtraction
ERP = pop_binoperator( ERP, {  'bin37=b25-b33'});
% Create long frustration subtraction
ERP = pop_binoperator( ERP, {  'bin38=b26-b34'});

ERP = pop_ploterps( ERP, [ 35:38],  [ 6 7 11 22 36 40 16 17 45] , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 3], 'ChLabel', 'on', 'FontSizeChan',...
  1, 'FontSizeLeg',  1, 'FontSizeTicks',  20, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-', 'b-', 'g-' }, 'LineWidth',  5, 'Maximize', 'on',...
 'Position', [ 34.75 10.8333 106.875 31.9444], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -150.0 650.0   -100 0:200:650 ],...
 'YDir', 'normal', 'yscale', [ -6.0 8.0   -6:6:6 ] );

