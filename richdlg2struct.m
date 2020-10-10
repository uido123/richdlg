function [answers] = richdlg2struct(richdlg_struct)
%RICHDLG2STRUCT Translate richdlg answers to a structure for easier access
    
    if isempty(richdlg_struct)
        answers = [];
    else
        if isfield(richdlg_struct,'field_id')
            with_id = true;
        else
            with_id = false;
        end
        for i = 1:numel(richdlg_struct)
            if with_id
                answers.(richdlg_struct(i).field_id) = richdlg_struct(i).value;
            else
                answers.(richdlg_struct(i).name) = richdlg_struct(i).value;
            end
        end
    end

end

