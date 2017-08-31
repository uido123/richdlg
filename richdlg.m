function [ data ] = richdlg( data, title )
%RICHDLG Create and show rich input dialog, with textboxes, checkboxes and
%combos
%
%   DATA should be a structure with fields: 
%   name
%   value 
%   dtype ('double','string','logical','vector','matrix','file')
%   gtype ('single','choice','checkbox','file','matrix','title')
%   values (for gtype choice its the choice values and for file its  a cell
%   array of the form {"in"/"out",".wav,*.WAV" etc}
%   fixed (true/false, default = false)
%   hide  (true/false, default = false)
%
%   Note that logical, file and matrix dtypes automatically go into 
%   checkbox, file and matrix file gtypes (respectively)
%
%   See also RICHDLGP, QUESTDLG, INPUTDLG.

    % build popup
    [data,fig] = richdlg_build(data,title);
    % wait for user command
    uiwait(fig);
    % process user command
    data = richdlg_post(data,fig);
    % finalize
    delete(fig);

end


% BUILD DIALOG
function [data,fig] = richdlg_build(data,title)
    
    fw = 100;   % figure width
    bw = 30;    % button width
    sw = 40;    % string width
    cbh = 1.1;  % checkbox height
    txh = 1.6;  % textbox height
    sth = 1.3;  % string height
    fig = dialog('Units','character','Position',[0,0,0,0],'Visible','off','Name',title);
    
    % dialog is built from bottom up
    % buttons
    okButton = uicontrol(fig,'Style','pushbutton','Units','character','Position',[2,0.6,bw,1.8],'String','OK','Callback',@(~,~)richdlg_onClick(fig,true));
    uicontrol(fig,'Style','pushbutton','Units','character','Position',[fw-2-bw,0.6,bw,1.8],'String','Cancel','Callback',@(~,~)richdlg_onClick(fig,false));    
    h = 3;      % height of next block
    
    N = length(data);
    for l = -N:-1
        i = -l;
        
        % dont create hidden fields + force 'hide' field
        if isfield(data(i),'hide') 
            if isempty(data(i).hide)
                data(i).hide = false;
            else
                if data(i).hide
                    continue;
                end
            end
        else
            data(i).hide = false;
        end
        
        % some dtypes and gtypes go together:
        if strcmp(data(i).dtype,'logical')
            data(i).gtype = 'checkbox';
        elseif strcmp(data(i).dtype,'file')
            data(i).gtype = 'file';
        elseif strcmp(data(i).dtype,'matrix')
            data(i).gtype = 'matrix';
        end
        
        % create ui controls
        switch data(i).gtype
            case 'single'
                [H,h] = richdlg_build_single(fig,data(i),h,fw,sw,cbh,txh,sth);
            case 'matrix'
                [H,h] = richdlg_build_matrix(fig,data(i),h,fw,sw,cbh,txh,sth);
            case 'choice'
                [H,h] = richdlg_build_choice(fig,data(i),h,fw,sw,cbh,txh,sth);
            case 'checkbox'
                [H,h] = richdlg_build_checkbox(fig,data(i),h,fw,sw,cbh,txh,sth);
            case 'file'
                [H,h] = richdlg_build_file(fig,data(i),h,fw,sw,cbh,txh,sth);
            case 'title'
                [H,h] = richdlg_build_title(fig,data(i),h,fw,sw,cbh,txh,sth);
        end
        data(i).uihandle = H;
       
        % handle unchangable values
        if isfield(data(i),'fixed') 
            if ~isempty(data(i).fixed) && data(i).fixed
                set(data(i).uihandle,'Enable','off','BackgroundColor','white');
            end
        end
    end

    % set figure height and location on screen
    pos = get(fig,'Position');
    pos(4) = h;
    pos(3) = fw;
    spos = uiPosition(0,'characters');
    pos(1) = (spos(3)-pos(3))/2;
    pos(2) = (spos(4)-pos(4))/2;
    set(fig,'Position',pos,'Visible','on');
    drawnow;
    uicontrol(okButton);
end

% ON CLICK
function richdlg_onClick(fig,ok)
    fig.UserData = ok;
    uiresume(fig);
end

% BUILD CHECKBOX
function [H,h] = richdlg_build_checkbox(fig,data,h,fw,~,cbh,~,~)
    pos = [2,h,fw-4,cbh];
    H = uicontrol(fig,'Style','checkbox','Units','character','Position',pos,'String',data.name,'Value',data.value);
    h = h + cbh + 0.5;
end

% BUILD TITLE
function [H,h] = richdlg_build_title(fig,data,h,fw,~,cbh,~,~)
    pos = [2,h,fw-4,cbh];
    H = uicontrol(fig,'Style','text','Units','character','Position',pos,'String',data.name,'FontWeight','bold','FontSize',12);
    h = h + cbh + 0.5;
end

% BUILD SINGLE
function [H,h] = richdlg_build_single(fig,data,h,fw,sw,~,txh,sth)
    % param name
    nameHandle = richdlg_build_name(fig,data.name,h,sw,sth);
    % param value
    switch data.dtype
        case 'string'
            val = data.value;
        case {'double','integer','vector','matrix'}
            val = num2str(data.value);
    end
    % create ui handle
    bpos = [4+sw,h,fw-6-sw,txh];
    H = uicontrol(fig,'Style','edit','Units','character','Position',bpos,'String',val);
    h = h + txh + 0.5;
end

% BUILD CHOICE
function [H,h] = richdlg_build_choice(fig,data,h,fw,sw,~,txh,sth)
    % param name
    nameHandle = richdlg_build_name(fig,data.name,h,sw,sth); %#ok<*NASGU>
    % param value
    S = data.values;
    val = find(strcmp(S,data.value),1);
    if isempty(val)
        val = 1;
    end
    % create ui handle
    bpos = [4+sw,h,fw-6-sw,txh];
    H = uicontrol(fig,'Style','popupmenu','Units','character','Position',bpos,'String',S,'Value',val);
    h = h + txh + 0.5;
end

% BUILD MATRIX
function [H,h] = richdlg_build_matrix(fig,data,h,fw,sw,~,txh,sth)
    % number of lines
    N = size(data.value,1);
    % param name
    nameHandle = richdlg_build_name(fig,data.name,h+txh*(N-1),sw,sth);
    % param value
    val = num2str(data.value);
    % create ui handle
    bpos = [4+sw,h,fw-6-sw,txh*N];
    H = uicontrol(fig,'Style','edit','Units','character','Position',bpos,'String',val,'Min',0,'Max',2);
    h = h + txh*N + 0.5;
end

% BUILD FILE
function [H,h] = richdlg_build_file(fig,data,h,fw,sw,~,txh,sth)
    bw = 5;
    % param name
    nameHandle = richdlg_build_name(fig,data.name,h,sw,sth);
    % param value
    val = data.value;
    % create ui handle
    bpos = [4+sw,h,fw-6-sw-(3+bw),txh];
    H = uicontrol(fig,'Style','edit','Units','character','Position',bpos,'String',val);
    % create button
    buttonHandle = uicontrol(fig,'Style','pushbutton','Units','character','Position',[fw-2-bw,h,bw,txh],'String','->','Callback',@(~,~)richdlg_set_filePath(H,data.name,data.values));
    if data.fixed
        set(buttonHandle,'Enable','off');
    end
    h = h + txh + 0.5;
end

% BUILD NAME STRING
function H = richdlg_build_name(fig,str,h,sw,sth)
    spos = [2,h,sw,sth];
    H = uicontrol(fig,'Style','text','Units','character','Position',spos,'String',str,'HorizontalAlignment','left');
end

% SET FILE PATH BUTTON
function richdlg_set_filePath(uiHandle,title,params)
    currPath = get(uiHandle,'String');
    switch params{1}
        case 'in'
            [fName,fPath] = uigetfile(params(2),title,currPath);
        case 'out'
            [fName,fPath] = uiputfile(params(2),title,currPath);
    end
    if fName
        % chenge value
        val = strcat(fPath,fName);
        set(uiHandle,'String',val);
    end
end

% POST
function [data] = richdlg_post(data,fig)
    if ishandle(fig)
        if fig.UserData
            N = length(data);
            for i = 1:N
                if ~data(i).hide
                    switch data(i).dtype
                        case 'logical'
                            data(i).value = data(i).uihandle.Value;
                        case 'string'
                            if strcmp(data(i).gtype,'single')
                                data(i).value = data(i).uihandle.String;
                            else
                                S = data(i).uihandle.String;
                                v = data(i).uihandle.Value;
                                data(i).value = S{v};
                            end
                        case {'double','integer'}
                            data(i).value = str2double(data(i).uihandle.String);
                        case {'vector','matrix'}
                            data(i).value =str2num(data(i).uihandle.String); %#ok<ST2NM>
                        case 'file'
                            data(i).value = data(i).uihandle.String;
                    end
                end
            end
        else
            data = [];
        end
    else
        data = [];
    end
end