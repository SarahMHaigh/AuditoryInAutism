# Auditory ERPs in Autism and Schizophrenia

Project published in:
1) Sarah M Haigh, Patricia Brosseau, Shaun M Eack, David I Leitman, Dean F Salisbury, & Marlene Behrmann (2022). Hyper-Sensitivity to Pitch and Poorer Prosody Processing in Adults with Autism: an ERP Study. _Frontiers in Psychiatry: Autism. 131_. https://doi.org/10.3389/fpsyt.2022.844830

2) Sarah M Haigh, Laura Van Key, Pat Brosseau, Shaun M Eack, David I Leitman, Dean F Salisbury & Marlene Behrmann (2022). Assessing Trial-to-Trial Variability in Auditory ERPs in Autism and Schizophrenia. S.I.: Developmental Approach and Targeted Treatment of Sensory Alterations. _Journal of Autism and Developmental Disorders. 53_(12), 4856-4871. https://doi.org/10.1007/s10803-022-05771-0

Data also used Sarah M Haigh, Tabatha P Walford & Pat Brosseau (2021). Heart Rate Variability in Schizophrenia and Autism. Frontiers in Psychiatry: Schizophrenia. 12, 2129. https://doi.org/10.3389/fpsyt.2021.760396

See: https://github.com/SarahMHaigh/HRV_AutismSchizophrenia

There are two main components to the study: pitch-deviant detection (low-level/early processing) and prosody-deviant detection (high-level/late processing). For both components, there is a behavioral and an EEG section.

Requires Psychtoolbox extension in MATLAB .

## Pitch Paradigms:
- ToneMatching.m - pitch discrimination paradigm. Stimuli generated in script
- SimpleTone.m - roving pitch MMN paradigm with an attention manipulation (3 pitches repeated 3 or 9 times before pitch change)
- SimpleTone_codes.txt - triggers reflecting which tone was presented when. The 'low', 'mid', and 'high' are referring to the frequency of the sound. The '3' and '9' are referring to how many tones are in a train. The 'Attend_cross' refers to when the fixation cross flashed and the participants had to respond. The 'Button_press' refers to when(if) the participant responded.

## Prosody Paradigms:
- Emo_id.m - prosody identification paradigm, repeated twice at two different sound levels.
- ComplexSound.m - roving prosody MMN paradigm with an attention manipulation. Only frustration and delight preseneted (x2 different voices; presented 3 or 6 times before speaker/prosody change)
- ProsodyStim.zip - prosodic stimuli used
- Complex_Sound_codes.txt - triggers reflecting which sound was presented when. There were two different voices for each utterance and these are denoted by 1 and 2 (e.g. 'Delight1'). The 's' and the 'l' refer to whether the train was short (3 utterances) or long (6 utterances). The 'Attend_cross' refers to when the fixation cross flashed and the participants had to respond. The 'Button_press' refers to when(if) the participant responded.

## ERP Analysis:
A 128 electrode montage was used for recording, but only the first 64 electrodes contain EEG data. Please load in the NARSAD_cap_try.ced file to get the correct electrode naming.

For the non-EEG electrodes, the following were used: EXG1 and EXG2 were on the mastoids and used as the offline reference, EXG3 and EXG4 were on the outer canthi of the eyes, EXG6 and EXG7 were above and below the right eye, and EXG8 was on the clavicle for ECG

See Auditory_Autism_ERPs.m for EEGLAB and ERPLAB code on data analysis steps and how plots were generated.

See additional ReadMe.txt file for details on which datasets were included in which analysis and why.

## Data Availability:
See here: https://nevada.box.com/s/2vjjtyaqa0j7hecqwzg3oyozexd95vs6

(The ERP files for the schizophrenia group are under the ‘SimpleTones’ data folder)

---------------------

Project doi: https://doi.org/10.17605/OSF.IO/PNVAY

---------------------

Questions? Email shaigh at unr dot edu

For more information, see: https://sarahmhaigh.github.io/
