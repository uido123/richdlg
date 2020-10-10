function p = richdlgAddElement(p,name,dtype,value,values,fixed,hide,field_id)
%ADDELEMENT Add element to richdlg data structure
%   ADDELEMENT(P,NAME,DTYPE,VALUE)
%   ADDELEMENT(P,NAME,DTYPE,VALUE,VALUES)
%   ADDELEMENT(P,NAME,DTYPE,VALUE,VALUES,FIXED,HIDE)
%   ADDELEMENT(P,NAME,DTYPE,VALUE,VALUES,FIXED,HIDE,FIELD_ID)

    i = numel(p) + 1;
    p(i).name = name;
    p(i).dtype = dtype;
    p(i).value = value;
    if exist('values','var')
        p(i).values = values;
    else
        p(i).values = {};
    end

    if exist('fixed','var')
        p(i).fixed = fixed;
    end

    if exist('hide','var')
        p(i).hide = hide;
    end
    
    if exist('field_id','var')
        p(i).field_id = field_id;
    end
        
end

