function [im,n,m,M] = threshold(varargin)
%      GUI for thresholding images
%    
% INPUT:
% images - array to threshold images (can be a single image as well)
% 'N' - image to display 
%
% to run:
%
%   threshold(images,'1')
%
% if want output:
% 
%   im_thr=threshold(images,'1');
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @threshold_OpeningFcn, ...
                   'gui_OutputFcn',  @threshold_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [im,n,m,M] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before threshold is made visible.
function threshold_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to threshold (see VARARGIN)

% Choose default command line output for threshold
handles.output = hObject;

% Update handles structure
axes(handles.axes1);
data= varargin{1};
n=varargin{2};
n=str2double(n);
iptsetpref('ImshowAxesVisible', 'on')
imagesc(data(:,:,n)),colormap(gray)
handles.data=data;
[~,~,q]=size(data);
set(handles.im1,'string',1);
set(handles.imN,'string',q);
set(handles.imi,'string',n);
handles.n=n;
handles.Min=0;
handles.Max=400;
global_max_value = 400;
slider_step(1) = 1/400;
slider_step(2) = 10/400;
set(handles.slider_max,'sliderstep',slider_step,'max',400,'min',0,'Value',global_max_value);

global_min_value = 0;
set(handles.slider_min,'sliderstep',slider_step,'max',400,'min',0,'Value',global_min_value);

set(handles.edit_max,'string',global_max_value);
set(handles.edit_min,'string',global_min_value);

guidata(hObject, handles);



% UIWAIT makes threshold wait for user response (see UIRESUME)
% uiwait(handles.figure1);

uiwait(handles.figure1);

% --- Executes during object creation, after setting all properties.
function slice_num_CreateFcn(hObject, ~, ~)
% hObject    handle to slice_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on slider movement.
function slice_num_Callback(hObject, ~, handles)
% hObject    handle to slice_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data=handles.data;
[~,~,q]=size(data);
step=1/q;
set(handles.im1,'string',1);
set(handles.imN,'string',q);
slider_step(1)=step;
slider_step(2)=step;
set(handles.slice_num, 'SliderStep', slider_step, 'Max', q, 'Min',0)
i=get(hObject,'Value');
n=round(i);
    if n==0
        n=1;
    elseif n>=q
        n=q;
    else n=n;
    end
    set(handles.imi,'string',n);
    axes(handles.axes1);
iptsetpref('ImshowAxesVisible', 'on')
imagesc(data(:,:,n)),colormap(gray)
handles.n=n;
handles.Min=0;
handles.Max=400;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function slider_max_CreateFcn(hObject, ~, ~)
% hObject    handle to slider_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_max_Callback(hObject, ~, handles)
% hObject    handle to slider_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider



i=get(hObject,'Value');
Max=round(i);
handles.Max=Max;
image=handles.data;
n=handles.n;
data=image(:,:,n);
Min=handles.Min;
image_thr = threshold_grayscale_image(data,Min,Max);
axes(handles.axes2);
iptsetpref('ImshowAxesVisible', 'on')
imagesc(image_thr),colormap(gray)
handles.image_thr=image_thr;
set(handles.edit_max,'String', Max)
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function slider_min_CreateFcn(hObject, ~, ~)
% hObject    handle to slider_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_min_Callback(hObject, ~, handles)
% hObject    handle to slider_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


i=get(hObject,'Value');
Min=round(i);
handles.Min=Min;
image=handles.data;
n=handles.n;
data=image(:,:,n);
Max=handles.Max;
axes(handles.axes2);
image_thr = threshold_grayscale_image(data,Min,Max);
iptsetpref('ImshowAxesVisible', 'on')
imagesc(image_thr), colormap(gray)
handles.image_thr=image_thr;
set(handles.edit_min,'String', Min)
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit_max_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_max_Callback(hObject, ~, handles)
% hObject    handle to edit_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_max as text
%        str2double(get(hObject,'String')) returns contents of edit_max as a double

Max= str2double(get(handles.edit_max,'string'));
handles.Max=Max;
image=handles.data;
n=handles.n;
data=image(:,:,n);
Min=handles.Min;
image_thr = threshold_grayscale_image(data,Min,Max);
axes(handles.axes2);
iptsetpref('ImshowAxesVisible', 'on')
imagesc(image_thr), colormap(gray)
handles.image_thr=image_thr;
guidata(hObject,handles)




% --- Executes during object creation, after setting all properties.
function edit_min_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_min_Callback(hObject, ~, handles)
% hObject    handle to edit_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_min as text
%        str2double(get(hObject,'String')) returns contents of edit_min as a double

Min= str2double(get(handles.edit_min,'string'));
handles.Min=Min;
image=handles.data;
n=handles.n;
data=image(:,:,n);
Max=handles.Max;
axes(handles.axes2);
image_thr = threshold_grayscale_image(data,Min,Max);
iptsetpref('ImshowAxesVisible', 'on')
imagesc(image_thr), colormap(gray)
handles.image_thr=image_thr;
guidata(hObject,handles)

% --- Executes on button press in save_thresholded.
function save_thresholded_Callback(hObject, ~, handles)
% hObject    handle to save_thresholded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=handles.data;
n=handles.n;
data(:,:,n)=handles.image_thr;
handles.data=data(:,:,n);
guidata(hObject,handles)
uiresume(handles.figure1);


% --- Executes on button press in threhold_all.
function threholded_all_Callback(hObject, ~, handles)
% hObject    handle to threhold_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data=handles.data;
Max=handles.Max;
Min=handles.Min;
[~,~,p]=size(data);
for i=1:p
    image_thr(:,:,i) = threshold_grayscale_image(data(:,:,i),Min,Max);
    handles.data(:,:,i)=image_thr(:,:,i);
end
guidata(hObject,handles)
uiresume(handles.figure1);



% --- Executes on button press in cancel.
function cancel_Callback(~, ~, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = threshold_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
data=handles.data;
handles.output=data;
varargout{1} = handles.output;
varargout{2} = handles.n;
varargout{3} = handles.Min;
varargout{4} = handles.Max;
close



