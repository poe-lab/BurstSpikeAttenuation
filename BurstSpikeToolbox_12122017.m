function varargout = BurstSpikeToolbox_12122017(varargin)
% BURSTSPIKETOOLBOX_12122017 M-file for BurstSpikeToolbox_12122017.fig
%      BURSTSPIKETOOLBOX_12122017, by itself, creates a new BURSTSPIKETOOLBOX_12122017 or raises the existing
%      singleton*.
%
%      H = BURSTSPIKETOOLBOX_12122017 returns the handle to a new BURSTSPIKETOOLBOX_12122017 or the handle to
%      the existing singleton*.
%
%      BURSTSPIKETOOLBOX_12122017('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BURSTSPIKETOOLBOX_12122017.M with the given input arguments.
%
%      BURSTSPIKETOOLBOX_12122017('Property','Value',...) creates a new BURSTSPIKETOOLBOX_12122017 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bsa_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BurstSpikeToolbox_12122017_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BurstSpikeToolbox_12122017

% Last Modified by GUIDE v2.5 12-Dec-2017 10:58:11


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BurstSpikeToolbox_12122017_OpeningFcn, ...
                   'gui_OutputFcn',  @BurstSpikeToolbox_12122017_OutputFcn, ...
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

% --- Executes just before BurstSpikeToolbox_12122017 is made visible.
function BurstSpikeToolbox_12122017_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes BurstSpikeToolbox_12122017 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function varargout = BurstSpikeToolbox_12122017_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function cell_num_edit_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function BSIntervalEditBox_Callback(hObject, eventdata, handles)


function processFile_Callback(hObject, eventdata, handles)
%% Initiates burst identification option selected in the GUI:
global figuresEnabled BSInterval

BSInterval = str2double(get(handles.BSIntervalEditBox,'String'));   % returns the burst spike interval (default = 0.01)
if isnan(BSInterval)
    errordlg('Input must be a number','Error');
end


% execution by option
switch option
    case 1
        burstSpikeOption1(figuresEnabled, BSInterval);    
    case 2
        burstSpikeOption2(figuresEnabled);   
    case 3
        burstSpikeOption3(figuresEnabled);
end


function reset_pushbutton_Callback(hObject, eventdata, handles)
%% --- Executes on button press in reset_pushbutton.
% Reset analysis option
set(handles.option1_radiobutton,'value',1);
set(handles.option2_radiobutton,'value',0);
set(handles.option3_radiobutton,'value',0);
% Reset cell number
set(handles.cell_num_edit,'String','');

% --- Executes on button press in enableFigures.
function enableFigures_Callback(hObject, eventdata, handles)
global figuresEnabled
if (get(hObject,'Value') == get(hObject,'Max')) % then checkbox is checked-take approriate action
    figuresEnabled = 1;
else    % checkbox is not checked-take approriate action
    figuresEnabled = 0;
end

function ratNumBox_Callback(hObject, eventdata, handles)
global ratNumber
rat1 = str2double(get(hObject,'String'));   % returns contents of stop2 as a double
if isnan(rat1)
    errordlg('Input must be a number','Error');
end
ratNumber = rat1;

% --- Executes during object creation, after setting all properties.
function ratNumBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tetrodeNumBox_Callback(hObject, eventdata, handles)
global tetrodeNumber
tet1 = str2double(get(hObject,'String'));   % returns contents of stop2 as a double
if isnan(tet1)
    errordlg('Input must be a number','Error');
end
tetrodeNumber = tet1;

% --- Executes during object creation, after setting all properties.
function tetrodeNumBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dateBox_Callback(hObject, eventdata, handles)
global expDate
date1 = str2double(get(hObject,'String'));   % returns contents of stop2 as a double
if isnan(date1)
    errordlg('Input must be a number','Error');
end
expDate = date1;

% --- Executes during object creation, after setting all properties.
function dateBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function start1_Callback(hObject, eventdata, handles)
global startInterval
startInt1 = str2double(get(hObject,'String'));   % returns contents of start1 as a double
if isnan(startInt1)
    errordlg('Input must be a number','Error');
end
startInterval(1) = startInt1; 

% --- Executes during object creation, after setting all properties.
function start1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function stop1_Callback(hObject, eventdata, handles)
global stopInterval
stopInt1 = str2double(get(hObject,'String'));   % returns contents of stop1 as a double
if isnan(stopInt1)
    errordlg('Input must be a number','Error');
end
stopInterval(1) = stopInt1; 


% --- Executes during object creation, after setting all properties.
function stop1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function file1Box_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function file1Box_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function start2_Callback(hObject, eventdata, handles)
global startInterval
startInt2 = str2double(get(hObject,'String'));   % returns contents of start2 as a double
if isnan(startInt2)
    errordlg('Input must be a number','Error');
end
startInterval(2) = startInt2; 

% --- Executes during object creation, after setting all properties.
function start2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function stop2_Callback(hObject, eventdata, handles)
global stopInterval
stopInt2 = str2double(get(hObject,'String'));   % returns contents of stop2 as a double
if isnan(stopInt2)
    errordlg('Input must be a number','Error');
end
stopInterval(2) = stopInt2; 


% --- Executes during object creation, after setting all properties.
function stop2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function file2Box_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function file2Box_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AttenuationButton.
function AttenuationButton_Callback(hObject, eventdata, handles) %#ok<*INUSD>
global filename numberOfCells startInterval stopInterval ratNumber tetrodeNumber expDate sleepFileName
isolateChecked = get(handles.IsolateStatecheckbox,'Value');
if isequal(isolateChecked,0) % Does not isolate states for analysis
%     sleepFileName = '';
    isolatedStates = zeros(1,8);
    attenuationAnalysis(filename, numberOfCells, startInterval, stopInterval,...
    ratNumber, tetrodeNumber, expDate, isolateChecked, isolatedStates, sleepFileName);
    msgbox('Attenuation analysis complete.','Pop-up');
else    % Isolate states for analysis
    isolatedStates(1) = get(handles.AWcheckbox,'Value');
    isolatedStates(4) = get(handles.QWcheckbox,'Value');
    isolatedStates(2) = get(handles.QScheckbox,'Value');
    isolatedStates(6) = get(handles.TRcheckbox,'Value');
    isolatedStates(3) = get(handles.REcheckbox,'Value');
    isolatedStates(5) = get(handles.UHcheckbox,'Value');
    isolatedStates(7) = get(handles.U1checkbox,'Value');
    isolatedStates(8) = get(handles.U2checkbox,'Value');
    if isequal(zeros(1,8), isolatedStates)  %Makes sure at least one state is selected for analysis
       uiwait(errordlg('Please select at least one state and press "Analyze" button again.',...
        'ERROR','modal')); 
    else
        attenuationAnalysis(filename, numberOfCells, startInterval, stopInterval,...
            ratNumber, tetrodeNumber, expDate, isolateChecked, isolatedStates,sleepFileName);
        msgbox('Attenuation analysis complete.','Pop-up');
    end
end




% -------------------------------------------------------------------------
function file1Menu_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
global filename
working_dir=pwd;
current_dir='C:\SleepData';
cd(current_dir);
[filename1, pathname1] = uigetfile('*.xls', 'Pick the first burst spike file.');
if isequal(filename1,0) || isequal(pathname1,0)
    uiwait(errordlg('You need to select a file. Please press the button again',...
        'ERROR','modal'));
    cd(working_dir);
else
    cd(working_dir);
    filename{1}= fullfile(pathname1, filename1);
    set(handles.file1Box,'string',filename1);
    set(handles.file1Box,'Tooltipstring',filename{1});
end

% -------------------------------------------------------------------------
function file2Menu_Callback(hObject, eventdata, handles)
global filename
working_dir=pwd;
current_dir='C:\SleepData';
cd(current_dir);
[filename2, pathname2] = uigetfile('*.xls', 'Pick the second burst spike file.');
if isequal(filename2,0) || isequal(pathname2,0)
    uiwait(errordlg('You need to select a file. Please press the button again',...
        'ERROR','modal'));
    cd(working_dir);
else
    cd(working_dir);
    filename{2}= fullfile(pathname2, filename2);
    set(handles.file2Box,'string',filename2);
    set(handles.file2Box,'Tooltipstring',filename{2});
end
% -------------------------------------------------------------------------
function sleepFile_Callback(hObject, eventdata, handles)
global sleepFileName
working_dir=pwd;
current_dir='C:\SleepData\Results';
cd(current_dir);
[filename3, pathname3] = uigetfile('*.xls', 'Pick the Sleep Scorer file.');
if isequal(filename3,0) || isequal(pathname3,0)
    uiwait(errordlg('You need to select a file. Please press the button again',...
        'ERROR','modal'));
    cd(working_dir);
else
    cd(working_dir);
    sleepFileName = fullfile(pathname3, filename3);
    set(handles.sleepFileTxtBox,'string',filename3);
    set(handles.sleepFileTxtBox,'Tooltipstring',sleepFileName);
end
%--------------------------------------------------------------------------
function cellNumBox_Callback(hObject, eventdata, handles)
global numberOfCells
cellNum = str2double(get(hObject,'String'));   % returns contents of stop2 as a double
if isnan(cellNum)
    errordlg('Input must be a number','Error');
end
numberOfCells = cellNum; 


function cellNumBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function IsolateStatecheckbox_Callback(hObject, eventdata, handles)
% global isolatedStatesChkBox
% if (get(hObject,'Value') == get(hObject,'Max')) % then checkbox is checked-take approriate action
%     isolatedStatesChkBox = 1;
% else    % checkbox is not checked-take approriate action
%     isolatedStatesChkBox = 0;
% end

function sleepFileTxtBox_Callback(hObject, eventdata, handles)
function sleepFileTxtBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AWcheckbox_Callback(hObject, eventdata, handles)


function QWcheckbox_Callback(hObject, eventdata, handles)


function QScheckbox_Callback(hObject, eventdata, handles)


function TRcheckbox_Callback(hObject, eventdata, handles)


function REcheckbox_Callback(hObject, eventdata, handles)


function UHcheckbox_Callback(hObject, eventdata, handles)


function U1checkbox_Callback(hObject, eventdata, handles)


function U2checkbox_Callback(hObject, eventdata, handles)





% --- Executes during object creation, after setting all properties.
function BSIntervalEditBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
