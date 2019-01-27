# richdlg
Create and show rich input dialog in MATLAB with textboxes, checkboxes, combos and file dialogs. Supports matrices and multiline strings.

usage:
data_struct = richdlg( data_struct, title )

data_struct is structure with the following fields:
* name - technical usage. this name does not show on the dialog.
* dtype - data type: 'double' (numerical values), 'string' (strings), 'logical' (for checkboxes), 'file_in' (path string with uigetfile() dialog),'file_out' (path string with uiputfile() dialog), 'title' (highlighted string with no data input option), 'comment' (string with no data input option).
* value - default value for dialog. User selected/typed in value after dialog call. For dtype 'string' this can be also be a multiline string, and a matrix for dtype 'double'.
* values - for dtype 'string' or 'double' - combo box optional values (each must be a single line/number). For file_in / _out - a string with the file types (e.g. '".wav,*.WAV"').
* fixed - optional (default - false).
* hide - optional (default - false).

title (input variable, not a field in data_struct) should be a string for the dialog title.

***
TO DO:
nested dialogs.

