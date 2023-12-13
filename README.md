# Auditory In Autism

Project published in:
1) Hyper-Sensitivity to Pitch and Poorer Prosody Processing in Adults with Autism: an ERP Study by Sarah M Haigh, Patricia Brosseau, Shaun M Eack, David I Leitman, Dean F Salisbury, & Marlene Behrmann (2022). Frontiers in Psychiatry: Autism. 131. https://doi.org/10.3389/fpsyt.2022.844830

2) Assessing Trial-to-Trial Variability in Auditory ERPs in Autism and Schizophrenia. Sarah M Haigh, Laura Van Key, Pat Brosseau, Shaun M Eack, David I Leitman, Dean F Salisbury & Marlene Behrmann (accepted). S.I.: Developmental Approach and Targeted Treatment of Sensory Alterations. Journal of Autism and Developmental Disorders.

There are two main components to the study: pitch-deviant detection (low-level/early processing) and prosody-deviant detection (high-level/late processing). For both components, there is a behavioral and an EEG section.

Requires Psychtoolbox extension in MATLAB .

## Pitch Paradigms:
- ToneMatching.m - pitch discrimination paradigm. Stimuli generated in script
- SimpleTone.m - roving pitch MMN paradigm with an attention manipulation (3 pitches repeated 3 or 9 times before pitch change)

## Prosody Paradigms:
- Emo_id.m - prosody identification paradigm, repeated twice at two different sound levels.
- ComplexSound.m - roving prosody MMN paradigm with an attention manipulation. Only frustration and delight preseneted (x2 different voices; presented 3 or 6 times before speaker/prosody change)
- ProsodyStim.zip - prosodic stimuli used

## ERP Analysis:
See Auditory_Autism_ERPs.m for EEGLAB and ERPLAB code on data analysis steps and how plots were generated.

---------------------

For access to data, see: https://osf.io/pnvay/

---------------------

Questions? Email shaigh at unr dot edu
