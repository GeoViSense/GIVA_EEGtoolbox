=============================================

  Latest update - June 10th, 2018
  Author - Jihyun Lee (jihyun.lee@geo.uzh.ch)

=============================================

  [ Updated festures ]

* GIVA_EEGtoolbox (prototype)
Select one EDF file and choose measurement type 
(Alpha power or FAA). It gives a plot of measurement
value over time (~4 seconds after stimulation onset) 

* GIVA_EEGtoolbox_v1_2
EEG channel selection option is added. Average measurement
value across time (4 seconds) is presented at the end of
the toolbox GUI.

* GIVA_EEGtoolbox_v1_3
Multiple files can be selected and the selected file
names are presented in the white box below. Graph area
for plotting across time is excluded. 

* GIVA_EEGtoolbox_v1_4
Irregular epoch length error caused during .set to .edf 
file conversion in EEGLAB is resolved in this v1.4 toolbox 
by truncating the last bits whenever it happens. 

* GIVA_EEGtoolbox_v2_0
'Alpha test' option is added to the attention measurement 
type, to reserve alpha powers of each individual channel 
without averaging across them and to analyze their trend.
File name for saving the result file can be assigned 
within the toolbox GUI. 

* GIVA_EEGtoolbox_v3_0
Rectangular window is replaced by Hamming window as a band 
pass filter, without overlaps, which is used to filter 
epoched data. Hamming window is advantageous over 
rectangular (default) window as fourier transform is 
applied to a finite signal which generates ripples. 
Hamming window is useful for compensating this issue. 

* GIVA_EEGtoolbox_v3_1
Engagement and arousal options are newly added to the 
attention measurement type. 'Band power ratio' calculation 
is replaced by 'band power changes ratio', which is expressed 
as the following formula: (reference band power-stimulation 
band power)/reference band power, following a well-known 
paper (Klimesch, 1999)-cited over 4300 times. Previously 'band 
power ratio' was calculated as follows: stimulation band power/reference 
band power.



