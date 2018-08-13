function [ data ] = richdlg( data, title )
%RICHDLG Create and show rich input dialog, with textboxes, checkboxes,
%combos, file dialogs. Supports matrices and multiline strings.
%
%   DATA should be a structure with fields: 
%   * name (this is not visible for dtype comment and title)
%   * dtype ('double','string','logical','file_in','file_out','title',
%   'comment')
%   * value (can be multiline for dtype string and double) 
%   * values (for dtype string or double: a cell array with drop down 
%   option. must be single line string or single number. for file_in/out: 
%   a string with the file types, ".wav,*.WAV" etc.) 
%   * fixed - optional (true/false, default = false)
%   * hide - optional (true/false, default = false)
%
%   Note that logical, file and matrix dtypes automatically go into 
%   checkbox, file and matrix file gtypes (respectively)
%
%   See also QUESTDLG, INPUTDLG.

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
        
        if ~isfield(data(i),'fixed')
            data(i).fixed = false;
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
        switch data(i).dtype
            case 'string'
                if isfield(data(i),'values') && ~isempty(data(i).values)
                    [H,h] = richdlg_build_choice(fig,data(i),h,fw,sw,cbh,txh,sth);
                else
                    [H,h] = richdlg_build_matrix(fig,data(i),h,fw,sw,cbh,txh,sth);
                end
            case {'double','integer'}
                if isfield(data(i),'values') && ~isempty(data(i).values)
                    [H,h] = richdlg_build_choice(fig,data(i),h,fw,sw,cbh,txh,sth);
                else
                    [H,h] = richdlg_build_matrix(fig,data(i),h,fw,sw,cbh,txh,sth);
                end
            case 'logical'
                [H,h] = richdlg_build_checkbox(fig,data(i),h,fw,sw,cbh,txh,sth);
            case 'file_in'
                [H,h] = richdlg_build_file(fig,data(i),h,fw,sw,cbh,txh,sth,'in');
            case 'file_out'
                [H,h] = richdlg_build_file(fig,data(i),h,fw,sw,cbh,txh,sth,'out');
            case 'title'
                [H,h] = richdlg_build_title(fig,data(i),h,fw,sw,cbh,txh,sth);
            case 'comment'
                [H,h] = richdlg_build_comment(fig,data(i),h,fw,sw,cbh,txh,sth);
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
function [H,h] = richdlg_build_checkbox(fig,data,h,fw,sw,cbh,~,sth)
    % param name
    nameHandle = richdlg_build_name(fig,data.name,h,sw,sth); %#ok<*NASGU>
    pos = [4+sw,h,fw-4,cbh];
    H = uicontrol(fig,'Style','checkbox','Units','character','Position',pos,'String','','Value',data.value);
    h = h + cbh + 0.5;
end

% BUILD TITLE
function [H,h] = richdlg_build_title(fig,data,h,fw,~,cbh,~,~)
    pos = [2,h,fw-4,cbh];
    H = uicontrol(fig,'Style','text','Units','character','Position',pos,'String',data.value,'FontWeight','bold','FontSize',12);
    h = h + cbh + 0.5;
end

% BUILD COMMENT
function [H,h] = richdlg_build_comment(fig,data,h,fw,sw,cbh,txh,sth)
    if isempty(which('splitlines'))
        S = my_splitlines(data.value);
    else
        S = splitlines(data.value);
    end
    for i = -size(S,1):-1
        h = richdlg_build_comment_line(fig,S{-i},h,fw,sw,cbh,txh,sth);
    end
    % add space above
    h = h + 0.5;
    % return H for uniformity of interface
    H = [];
end
function [h] = richdlg_build_comment_line(fig,str,h,fw,~,cbh,~,~)
    spos = [10,h,fw-4,cbh];
    uicontrol(fig,'Style','text','Units','character','Position',spos,'String',str,'HorizontalAlignment','left');
    h = h + cbh + 0.5;
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
    % handle text
    switch data.dtype
        case {'double','integer'}
            str = num2str(data.value);
        case 'string'
            if isempty(which('splitlines'))
                str = my_splitlines(data.value);
            else
                str = splitlines(data.value);
            end
%            str = splitlines(data.value);
    end
    % number of lines
    N = size(str,1);
    box_height = (txh-1)+N;
    % param name
    nameHandle = richdlg_build_name(fig,data.name,h+box_height-1,sw,sth);
    % create ui handle
    bpos = [4+sw,h,fw-6-sw,box_height];
    H = uicontrol(fig,'Style','edit','Units','character','Position',bpos,'String',str);
    h = h + box_height + 0.5;
    if N > 1
        set(H,'Min',0,'Max',2);
    end
end

% BUILD FILE
function [H,h] = richdlg_build_file(fig,data,h,fw,sw,~,txh,sth,in_out)
    bw = 5;
    % param name
    nameHandle = richdlg_build_name(fig,data.name,h,sw,sth);
    % param value
    val = data.value;
    % create ui handle
    bpos = [4+sw,h,fw-6-sw-(3+bw),txh];
    H = uicontrol(fig,'Style','edit','Units','character','Position',bpos,'String',val);
    % create button
    buttonHandle = uicontrol(fig,'Style','pushbutton','Units','character','Position',[fw-2-bw,h,bw,txh],'String','->','Callback',@(~,~)richdlg_set_filePath(H,data.name,data.values,in_out));
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
function richdlg_set_filePath(uiHandle,title,values,in_out)
    currPath = get(uiHandle,'String');
    switch in_out
        case 'in'
            [fName,fPath] = uigetfile(values,title,currPath);
        case 'out'
            [fName,fPath] = uiputfile(values,title,currPath);
    end
    if fName
        % change value
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
                            if isfield(data(i),'values') && ~isempty(data(i).values)
                                S = data(i).uihandle.String;
                                v = data(i).uihandle.Value;
                                data(i).value = S{v};                            
                            else
                                data(i).value = data(i).uihandle.String;
								if iscell(data(i).value)
									data(i).value = data(i).value{1};
								end
                            end
                        case {'double','integer'}
                            if isfield(data(i),'values') && ~isempty(data(i).values)
                                S = data(i).uihandle.String;
                                v = data(i).uihandle.Value;
                                data(i).value = str2num(S{v}); %#ok<ST2NM>
                            else
                                data(i).value = str2num(data(i).uihandle.String); %#ok<ST2NM>
                            end
                        case {'file_in','file_out'}
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

% POSITION
function [ position ] = uiPosition( h, units )
%UIPOSITION get the UI control position in the specified units

    uni = get(h,'Units');
    set(h,'Units',units);
    if h == 0
        position = get(0,'ScreenSize');
    else
        position = get(h,'Position');
    end
    set(h,'Units',uni);

end

function C = my_splitlines(S)
    I = find(S==char(10));
    if isempty(I)
        C{1} = S;
    else
        I = [0,I];
        C = cell(numel(I),1);
        for i = 1:numel(I)-1 
            C{i} = S(I(i)+1:I(i+1)-1);
        end
        C{i+1} = S(I(i+1)+1:end);
    end
end