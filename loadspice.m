%
% LOADSPICE imports LTspice simulation results into the MATLAB workspace.
%    LOADSPICE(FILENAME) imports data into the MATLAB workspace from an 
%    LTspice simulation that has been exported as a text file FILENAME.  
%    Each column in the file is saved in a variable whose name is derived 
%    from the column heading.  If the simulation contained multiple steps, 
%    the results from each step becomes a row vector in a cell array where 
%    each successive step is an element in the cell array.  If the 
%    succession of values of the independent variable is the same for each 
%    step, the independent variable values become a single row vector and 
%    the dependent variables are transformed from a cell array into a 
%    matrix (i.e., each row vector in the cell array becomes a row of the 
%    resulting matrix).  If they are not identical for each simulation 
%    step, the different successions of values are stored in a cell array 
%    of row vectors, like the dependent variables.  The results from AC 
%    analyses are imported as complex numbers (i.e., with real and 
%    imaginary components), even if they were exported in polar form.  The 
%    succession of parameter values from each step are stored in a row 
%    vector whose name corresponds to the parameter name.
function loadspice(filename)
    file = fopen(filename, 'r');
    line = fgetl(file);
    line = strrep(line, '.', '');
    line = strrep(line, ')', '');
    line = strrep(line, 'V(', '');
    line = strrep(line, 'I(', '');
    names = split(strtrim(line));

    state = 0;
    line = fgetl(file);
    while ischar(line)
        if state == 0
            if ~contains(line, 'Step')
                for i = 1:length(names)
                    name = names{i};
                    evalin('caller', [name, ' = [];']);
                end
                values = split(strtrim(line));
                for i = 1:length(names)
                    if contains(values{i}, 'dB')
                        values{i} = strrep(values{i}, '(', '');
                        values{i} = strrep(values{i}, ')', '');
                        values{i} = strrep(values{i}, 'dB', '');
                        values{i} = strrep(values{i}, char(176), '');
                        tokens = split(values{i}, ',');
                        gain = str2double(tokens(1));
                        phase = str2double(tokens(2));
                        value = 10. ^ (gain / 20.) * (cos(phase * pi / 180.) + (0 + 1j) * sin(phase * pi / 180.));
                        evalin('caller', [names{i}, ' = [', names{i}, ', ', num2str(value), '];']);
                    elseif contains(values{i}, ',')
                        tokens = split(values{i}, ',');
                        re = str2double(tokens(1));
                        im = str2double(tokens(2));
                        value = re + (0 + 1j) * im;
                        evalin('caller', [names{i}, ' = [', names{i}, ', ', num2str(value), '];']);
                    else
                        evalin('caller', [names{i}, ' = [', names{i}, ', ', values{i}, '];']);
                    end
                end
                state = 1;
            else
                words = split(strtrim(line));
                for i = 1:length(words)
                    word = words{i};
                    if contains(word, '=')
                        tokens = split(word, '=');
                        param = tokens{1};
                        value = tokens{2};
                        value = strrep(value, char(181), 'U');
                        value = upper(value);
                        value = strrep(value, 'T', 'E12');
                        value = strrep(value, 'G', 'E9');
                        value = strrep(value, 'MEG', 'E6');
                        value = strrep(value, 'K', 'E3');
                        value = strrep(value, 'M', 'E-3');
                        value = strrep(value, 'U', 'E-6');
                        value = strrep(value, 'N', 'E-9');
                        value = strrep(value, 'P', 'E-12');
                        value = strrep(value, 'F', 'E-15');
                        evalin('caller', [param, ' = ', value, ';']);
                    end
                end
                for i = 1:length(names)
                    name = names{i};
                    evalin('caller', [name, ' = { [] };']);
                end
                state = 2;
            end
        elseif state == 1
            values = split(strtrim(line));
            for i = 1:length(names)
                if contains(values{i}, 'dB')
                    values{i} = strrep(values{i}, '(', '');
                    values{i} = strrep(values{i}, ')', '');
                    values{i} = strrep(values{i}, 'dB', '');
                    values{i} = strrep(values{i}, char(176), '');
                    tokens = split(values{i}, ',');
                    gain = str2double(tokens(1));
                    phase = str2double(tokens(2));
                    value = 10. ^ (gain / 20.) * (cos(phase * pi / 180.) + (0 + 1j) * sin(phase * pi / 180.));
                    evalin('caller', [names{i}, ' = [', names{i}, ', ', num2str(value), '];']);
                elseif contains(values{i}, ',')
                    tokens = split(values{i}, ',');
                    re = str2double(tokens(1));
                    im = str2double(tokens(2));
                    value = re + (0 + 1j) * im;
                    evalin('caller', [names{i}, ' = [', names{i}, ', ', num2str(value), '];']);
                else
                    evalin('caller', [names{i}, ' = [', names{i}, ', ', values{i}, '];']);
                end
            end
        elseif state == 2
            if ~contains(line, 'Step')
                values = split(strtrim(line));
                for i = 1:length(names)
                    if contains(values{i}, 'dB')
                        values{i} = strrep(values{i}, '(', '');
                        values{i} = strrep(values{i}, ')', '');
                        values{i} = strrep(values{i}, 'dB', '');
                        values{i} = strrep(values{i}, char(176), '');
                        tokens = split(values{i}, ',');
                        gain = str2double(tokens(1));
                        phase = str2double(tokens(2));
                        value = 10. ^ (gain / 20.) * (cos(phase * pi / 180.) + (0 + 1j) * sin(phase * pi / 180.));
                        evalin('caller', [names{i}, '{end} = [', names{i}, '{end}, ', num2str(value), '];']);
                    elseif contains(values{i}, ',')
                        tokens = split(values{i}, ',');
                        re = str2double(tokens(1));
                        im = str2double(tokens(2));
                        value = re + (0 + 1j) * im;
                        evalin('caller', [names{i}, '{end} = [', names{i}, '{end}, ', num2str(value), '];']);
                    else
                        evalin('caller', [names{i}, '{end} = [', names{i}, '{end}, ', values{i}, '];']);
                    end
                end
            else
                words = split(strtrim(line));
                for i = 1:length(words)
                    word = words{i};
                    if contains(word, '=')
                        tokens = split(word, '=');
                        param = tokens{1};
                        value = tokens{2};
                        value = strrep(value, char(181), 'U');
                        value = upper(value);
                        value = strrep(value, 'T', 'E12');
                        value = strrep(value, 'G', 'E9');
                        value = strrep(value, 'MEG', 'E6');
                        value = strrep(value, 'K', 'E3');
                        value = strrep(value, 'M', 'E-3');
                        value = strrep(value, 'U', 'E-6');
                        value = strrep(value, 'N', 'E-9');
                        value = strrep(value, 'P', 'E-12');
                        value = strrep(value, 'F', 'E-15');
                        evalin('caller', [param, ' = [', param, ', ', value, '];']);
                    end
                end
                for i = 1:length(names)
                    name = names{i};
                    evalin('caller', [name, '{end + 1} = [];']);
                end
            end
        end
        line = fgetl(file);
    end
    
    if state == 2
        rows = evalin('caller', ['length(', names{1}, ');']);
        rows_equals_first_row = [];
        for i = 1:rows
            rows_equals_first_row = [rows_equals_first_row, evalin('caller', ['isequal(', names{1}, '{1}, ', names{1}, '{', num2str(i), '});'])];
        end
        if all(rows_equals_first_row)
            evalin('caller', [names{1}, ' = ', names{1}, '{1};']);
            for i = 2:length(names)
                evalin('caller', [names{i}, ' = cell2mat(', names{i}, ''');']);
            end
        end
    end
    
    fclose(file);
