# GIVA_EEGtoolbox
This toolbox allows you to measure alpha power and FAA values from EDF files containing EEG data.

1) Functionality of each panel

1.1) EEG signals

Multiple EDF files can be selected and transformed into spectral domain using Fourier Transform. The file should be a converted form from a ‘.set’ file, which is an output file from EEGLAB toolbox after each epoch is segmented and concatenated (each epoch contains from -0.5 to 4 seconds with respect to each animation onset. For the experimental details, please refer to the Ph.D. thesis of Dr. Sara Maggi). Once you select the EDF file(s), the blank window under the ‘Select’ button shows the file names of your choice. Once the files are chosen, the data is segmented into each epoch. If the length of each epoch is irregular, the toolbox will give you an error message.

1.2) Attention measurement type

Depending on how you would like to measure the attention level, you can choose between the Alpha power, FAA (Frontal Alpha Asymmetry), Engagement Index, Arousal, and Alpha test (functionality of each is described later). EEG signals recorded during 0.5 seconds before the animation onset is used as baseline signals in all measurement types.

1.3) Alpha power

4 seconds after animation onset is segmented into 8 pieces, whose length is 0.5 second each. Each piece’s average alpha power (at 8-12Hz) is first subtracted from average alpha power of the baseline signal power and then divided by the average alpha power of the baseline signal to calculate alpha power ratio and the same procedure is repeated for all channels you selected (see ‘Select channels’ section below). This alpha power ratio of each segment is then averaged across channels you selected and plotted on the graph. Average of those 8 values on the plot is shown in the ‘Average value’ box.

1.4) FAA

Once you select FAA in this panel, the ‘Select channels’ panel is disabled as the channels used for FAA analysis is fixed to F7, F3, FC5, FC6, F4, F8. Alpha power ratio is calculated the same way as the ‘Alpha power’ option and then the ratios of the 6 channels are put into the FAA formula (please refer to Dr. Sara Maggi’s Ph.D. thesis for the FAA formula), without taking logarithm at the end of the calculation. The next steps are the same as the ‘Alpha power’ option. 

1.5) Engagement Index

Theta power ratio, alpha power ration, and beta power ratio are calculated in the same manner as ‘Alpha power’ option, then the Engagement index is calculated using the following formula: beta/(theta+alpha). Engagement index is introduced in the following paper: “Biocybernetic system evaluates indices of operator engagement in automated task” – Pope et al., 1994

1.6) Arousal

Alpha power ratio and beta power ratio are calculated the same way as the others described before, but only for channel F3 and F4. Arousal level is then calculated by beta power ratio over alpha power ratio. 

1.7) Alpha test (not a measurement type)

This option was created for a purpose of developing a new analysis method. The output data of this option is alpha power ratio of each individual channel, without averaging across them which was done in all measurement types.

1.8) Select channels

Among Emotiv EPOC’s channel locations (AF3, F7, F3, FC5, T7, P7, O1, O2, P8, T8, FC6, F4, F8, AF4), one can select channel(s) to be included in the analysis. Multiple channels can be selected by pressing Ctrl key together with the mouse click. FAA option does not allow users to select channel(s), as it requires only predetermined 6 channel locations (F7, F3, FC5, FC6, F4, F8) for its score calculation. In a similar manner, Arousal takes only F3 and F4 channels for calculation. This is applied to all EDF files selected. 

2) User guide

1.	Start MATLAB and set path to the ‘GIVA_EEGtoolbox’ folder (in which you have the ‘GIVA_EEGtoolbox_v1_3.m’ file). 
2.	Enter GIVA_EEGtoolbox_v1_3 in the command window of MATLAB.
3.	When the toolbox pops up, select EDF files and press Start button (please refer to ‘EEG signals’ description in ‘Functionality of each panel’ section for the EDF file format).
4.	Choose your attention measurement type.
5.	Set a file name to save your result.
6.	Select channel(s) with pressing Ctrl key if you wish to include multiple channels to your analysis. ‘Select channels’ panel will be disabled if you have chosen FAA as your attention measurement type. In this case, F7, F3, FC5, FC6, F4, F8 channel locations are automatically selected internally. Same will happen for Arousal, with F3 and F4 taken internally. Then press Apply.
7.	Press Calculate score. Individual scores of all EDF files selected are recorded in a TEXT file and saved in the ‘Results’ folder under the name that you specified.

