function varargout = GIVA_EEGtoolbox_v3_2(varargin)
% giva_eegtoolbox_v3_2 MATLAB code for GIVA_EEGtoolbox_v3_2.fig
%      giva_eegtoolbox_v3_2, by itself, creates a new giva_eegtoolbox_v3_2 or raises the existing
%      singleton*.
%
%      H = giva_eegtoolbox_v3_2 returns the handle to a new giva_eegtoolbox_v3_2 or the handle to
%      the existing singleton*.
%
%      giva_eegtoolbox_v3_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in giva_eegtoolbox_v3_2.M with the given input arguments.
%
%      giva_eegtoolbox_v3_2('Property','Value',...) creates a new giva_eegtoolbox_v3_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GIVA_EEGtoolbox_v3_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GIVA_EEGtoolbox_v3_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Edit the above text to modify the response to help GIVA_EEGtoolbox_v3_2
%
% Last Modified by GUIDE v2.5 07-Dec-2020 18:54:45
%
% Author: Jihyun Lee (jihyun.lee@geo.uzh.ch)
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GIVA_EEGtoolbox_v3_2_OpeningFcn, ...
    'gui_OutputFcn',  @GIVA_EEGtoolbox_v3_2_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GIVA_EEGtoolbox_v3_2 is made visible.
function GIVA_EEGtoolbox_v3_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GIVA_EEGtoolbox_v3_2 (see VARARGIN)

% Choose default command line output for GIVA_EEGtoolbox_v3_2
handles.output = hObject;

% clear all global variables
clear global

global measure_type file_list file_path_list

% addpath functions folder which contains .m files needed to run this GUI
addpath(strcat(pwd, '\functions'))

% Make a folder to save analysis results if it doesn't exist yet
if ~exist('Results','file')
    mkdir Results
end

% default Attention measure type is alpha power (top on the radio button list)
measure_type = 1;

% Set the variable 'file_list' and 'file_path_list' as cell type. List of chosen EDF files for
% analysis will be saved in these variables.
file_list = cell(0);
file_path_list = cell(0);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GIVA_EEGtoolbox_v3_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = GIVA_EEGtoolbox_v3_2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_file.
function load_file_Callback(hObject, eventdata, handles)
% hObject    handle to load_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global eeg_epoched file_list file_path_list

% filepath = uigetfile_n_dir(pwd,'Select an EDF file to analyze');
filepath = uigetfile_n_dir('C:\Users\jihyu\switchdrive\GeoViSenseLitAndNotes\analysisAndData\EEGLAB output\EEG_RawData_MatlabFiles');

for count = 1:size(filepath,2)
    [~,filename,ext] = fileparts(filepath{count});
    
    if ~strcmp(ext,'.edf')
        error('ERROR: The file you selected is not an EDF file.')
    end
    
    file_list = [file_list; [filename ext]]; % file names
    file_path_list = [file_path_list; filepath(count)]; % full file path
end

% Remove duplicates from the selected file list if any
file_list = uniquecell(file_list);
file_path_list = uniquecell(file_path_list);

% Display the list of chosen files on the GUI
set(handles.loaded_file,'String',file_list);

% Define a variable to save each file's information such as number of
% epochs, baseline EEG segment, stimulation EEG segment
eeg_epoched = cell(size(file_path_list,1),1);

for file_count = 1:size(file_path_list,1)
    
    [~,recorded] = edfread(file_path_list{file_count});
    eeg_data = recorded(1:14,:);
    
    n_epoch = size(eeg_data,2)/(128*4.5); % number of epochs
    
    % Check if the epochs have the same segment length
    if rem(n_epoch,1)
        %         error('ERROR: The length of each epoch is not uniform. Check your epoch segmentation step in EEGLAB')
        
        % Sometimes NaNs, which are converted to some random values whiling exporting to EDF, are concatenated at the end of the EEG data from EEGLAG side
        % It happens quite frequently when a few of the epochs are rejected in EEGLAB toolbox
        eeg_data_without_NaN = eeg_data(:,1:end-64);   % remove the last 0.5 second which contains no information   
        n_epoch = size(eeg_data_without_NaN,2)/(128*4.5); % number of epochs
    end
    
    baseline_eeg = cell(n_epoch,1);
    stim_eeg = cell(n_epoch,1);
    
    for epoch = 1:n_epoch
        % -0.5 sec until 0 sec with respect to the simulus onset (baseline)
        baseline_eeg{epoch,1} = eeg_data(:,(epoch-1)*576+1:(epoch-1)*576+64);  % 576 data points (128 samples/sec for 4.5 sec) per epoch
        % 0 sec until 4 sec with respect to the stimulus onset (during visual stimulation)
        stim_eeg{epoch,1} =  eeg_data(:,(epoch-1)*576+65:epoch*576);
    end
    
    eeg_epoched{file_count}.file = file_list{file_count};
    eeg_epoched{file_count}.n_epoch = n_epoch;
    eeg_epoched{file_count}.baseline_eeg = baseline_eeg;
    eeg_epoched{file_count}.stim_eeg = stim_eeg;
    
    disp(['EEG data is loaded from the file ''' file_list{file_count} ''' and segmented into ' num2str(n_epoch) ' epochs.'])
end



% --- Executes on button press in FFT.
function FFT_Callback(hObject, eventdata, handles)
% hObject    handle to FFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global eeg_epoched eeg_spectrum

eeg_spectrum = cell(size(eeg_epoched,1),1);

for count = 1:size(eeg_epoched,1)
    eeg_spectrum{count}.file = eeg_epoched{count}.file;
    eeg_spectrum{count}.n_epoch = eeg_epoched{count}.n_epoch;
    eeg_spectrum{count}.baseline_spectrum = cell(size(eeg_epoched{count}.baseline_eeg));
    eeg_spectrum{count}.stim_spectrum = cell(size(eeg_epoched{count}.stim_eeg));
    
    for epoch = 1:eeg_epoched{count}.n_epoch
        for ch=1:14
            filter = hamming(size(eeg_epoched{count}.baseline_eeg{epoch,1}(ch,:),2))'; % hamming window
            filtered_base = filter.*eeg_epoched{count}.baseline_eeg{epoch,1}(ch,:); % filter with hamming window
            eeg_spectrum{count}.baseline_spectrum{epoch,1}(ch,:) = abs(fft(filtered_base));
            
            % segmentize the stimulation period every 0.5 second (to make the length equal to the baseline length)
            for seg = 1:size(eeg_epoched{count}.stim_eeg{epoch,1},2)/64
                filtered_stim = filter.*eeg_epoched{count}.stim_eeg{epoch,1}(ch,(seg-1)*64+1:seg*64);
                eeg_spectrum{count}.stim_spectrum{epoch,1}{ch,seg} = abs(fft(filtered_stim));
            end
        end
    end
end

disp('Fourier Transform completed!')


% --- Executes during object creation, after setting all properties.
function measure_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in alpha_power.
function alpha_power_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global measure_type

% Hint: get(hObject,'Value') returns toggle state of alpha_power
measure_type = get(hObject,'Value');

% let the user choose channels which will be used for analysis
set(handles.channel_list,'Enable','on');



% --- Executes on button press in FAA.
function FAA_Callback(hObject, eventdata, handles)
% hObject    handle to FAA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global measure_type

% Hint: get(hObject,'Value') returns toggle state of FAA
measure_type = 2*get(hObject,'Value');

% If FAA is chosen as measure type, disable channel selection list box as
% the channels used for this analysis is already fixed.
set(handles.channel_list,'Enable','off');


% --- Executes on button press in engagement.
function engagement_Callback(hObject, eventdata, handles)
% hObject    handle to engagement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of engagement

global measure_type

measure_type = 3*get(hObject,'Value');
% let the user choose channels which will be used for analysis
set(handles.channel_list,'Enable','on');

% --- Executes on button press in arousal.
function arousal_Callback(hObject, eventdata, handles)
% hObject    handle to arousal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of arousal
global measure_type

measure_type = 4*get(hObject,'Value');
% let the user choose channels which will be used for analysis
set(handles.channel_list,'Enable','off');

% --- Executes on button press in alpha_all.
function alpha_all_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alpha_all

global measure_type

measure_type = 5*get(hObject,'Value');
% let the user choose channels which will be used for analysis
set(handles.channel_list,'Enable','on');

% --- Executes on selection change in channel_list.
function channel_list_Callback(hObject, eventdata, handles)
% hObject    handle to channel_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel_list

global ch_id contents
contents = cellstr(get(hObject,'String'));
selected_ch = contents(get(hObject,'Value'));
[~,ch_id,~] = intersect(contents, selected_ch);


% --- Executes during object creation, after setting all properties.
function channel_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function save_file_Callback(hObject, eventdata, handles)
% hObject    handle to save_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_file as text
%        str2double(get(hObject,'String')) returns contents of save_file as a double

global file_name

file_name = get(hObject,'String');



% --- Executes during object creation, after setting all properties.
function save_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in channel_apply.
function channel_apply_Callback(hObject, eventdata, handles)
% hObject    handle to channel_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ch_id selected_ch_id contents measure_type

disp('Channels for attention analysis are selected.')

switch measure_type
    case 1
        str_measure_type = 'Alpha power';
        
        if isempty(contents)
            % if no channels are selected, abort and show error message
            error('Select channels from the list for analysis.')
        end
        
        % Sort the channel indices to increasing order
        selected_ch_id = sort(ch_id);
        
        disp(contents(selected_ch_id)')
        
    case 2
        str_measure_type = 'FAA';
        
        disp({'F7', 'F3', 'FC5', 'FC6', 'F4', 'F8'})
        
    case 3
        str_measure_type = 'Engagement Index';
        
        if isempty(contents)
            % if no channels are selected, abort and show error message
            error('Select channels from the list for analysis.')
        end
        % Sort the channel indices to increasing order
        selected_ch_id = sort(ch_id);
        disp(contents(selected_ch_id)')

    case 4
        str_measure_type = 'Arousal';
        
        disp({'F3', 'F4'})
        
    case 5
        str_measure_type = 'Alpha all';
        
        if isempty(contents)
            % if no channels are selected, abort and show error message
            error('Select channels from the list for analysis.')
        end
        % Sort the channel indices to increasing order
        selected_ch_id = sort(ch_id);
        disp(contents(selected_ch_id)')
        
end


disp(['Measure type: ' str_measure_type])


% --- Executes on button press in calc_score.
function calc_score_Callback(hObject, eventdata, handles)
% hObject    handle to calc_score (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global eeg_spectrum measure_type selected_ch_id file_name

% Define a variable to save scores of each measurement
scores = cell(size(eeg_spectrum,1),1);
file = cell(size(eeg_spectrum,1),1);

switch measure_type
    case 1 % alpha power
        mean_alpha = cell(size(eeg_spectrum,1),1);
        for count = 1:size(eeg_spectrum,1)
            file{count} = eeg_spectrum{count}.file;
            scores{count}.mean_alpha_across_channels = alpha_power(eeg_spectrum{count}.n_epoch, eeg_spectrum{count}.stim_spectrum, eeg_spectrum{count}.baseline_spectrum,selected_ch_id);
            mean_alpha{count} = mean(scores{count}.mean_alpha_across_channels,2)';
        end
        
        % Make a table
        T = table(mean_alpha,'RowNames',file);
        result_filename = [file_name '.txt'];
        writetable(T,['Results\[Alpha power] ' result_filename],'Delimiter','\t','WriteRowNames',true)
        disp(['Analysis result is saved in the folder ''Results'' under a file name ''[Alpha power] ' result_filename ''''])
        

    case 2 % FAA
        mean_FAA = cell(size(eeg_spectrum,1),1);
        for count = 1:size(eeg_spectrum,1)
            file{count} = eeg_spectrum{count}.file;
            scores{count}.FAA = FAA_calculation(eeg_spectrum{count}.n_epoch, eeg_spectrum{count}.stim_spectrum,eeg_spectrum{count}.baseline_spectrum);
            mean_FAA{count} = scores{count}.FAA';
        end
        
        % Make a table
        T = table(mean_FAA,'RowNames',file);
        result_filename = [file_name '.txt'];
        writetable(T,['Results\[FAA] ' result_filename],'Delimiter','\t','WriteRowNames',true)
        disp(['Analysis result is saved in the folder ''Results'' under a file name ''[FAA] ' result_filename ''''])
                
        
    case 3 % Engagement index
        mean_engage = cell(size(eeg_spectrum,1),1);
        for count = 1:size(eeg_spectrum,1)
            file{count} = eeg_spectrum{count}.file;
            scores{count}.mean_engage_across_channels = engage_level(eeg_spectrum{count}.n_epoch, eeg_spectrum{count}.stim_spectrum, eeg_spectrum{count}.baseline_spectrum,selected_ch_id);
            mean_engage{count} = mean(scores{count}.mean_engage_across_channels,2)';
        end
        
        % Make a table
        T = table(mean_engage,'RowNames',file);
        result_filename = [file_name '.txt'];
        writetable(T,['Results\[Engagement level] ' result_filename],'Delimiter','\t','WriteRowNames',true)
        disp(['Analysis result is saved in the folder ''Results'' under a file name ''[Engagement level] ' result_filename ''''])
        
    case 4 % Arousal
        mean_arousal = cell(size(eeg_spectrum,1),1);
        for count = 1:size(eeg_spectrum,1)
            file{count} = eeg_spectrum{count}.file;
            mean_arousal{count} = Arousal(eeg_spectrum{count}.n_epoch, eeg_spectrum{count}.stim_spectrum, eeg_spectrum{count}.baseline_spectrum)';
        end
        
        % Make a table
        T = table(mean_arousal,'RowNames',file);
        result_filename = [file_name '.txt'];
        writetable(T,['Results\[Arousal] ' result_filename],'Delimiter','\t','WriteRowNames',true)
        disp(['Analysis result is saved in the folder ''Results'' under a file name ''[Arousal] ' result_filename ''''])
        
    case 5 % Alpha power all (without averaging across channels)
        mean_alpha = zeros(size(eeg_spectrum,1),size(selected_ch_id,1)); % a matrix with size of: number of selected files by number of channels
        for count = 1:size(eeg_spectrum,1)
            file{count} = eeg_spectrum{count}.file;
            scores{count}.alpha_of_each_channel = alpha_power_all(eeg_spectrum{count}.n_epoch, eeg_spectrum{count}.stim_spectrum, eeg_spectrum{count}.baseline_spectrum,selected_ch_id);
            mean_alpha(count,:) = scores{count}.alpha_of_each_channel;
        end
        
        % Make a table
        T = table(mean_alpha,'RowNames',file);
        result_filename = [file_name '.txt'];
        writetable(T,['Results\[Alpha all]' result_filename],'Delimiter','\t','WriteRowNames',true)
        disp(['Analysis result is saved in the folder ''Results'' under a file name ''[Alpha all] ' result_filename ''''])
                
end
