function makeConfluenceTables(root)
outputFile = {};
[files, ~] = dir_list_gen(root, 'txt',1);
groups = {'base_summary.txt', 'overview.txt', 'material_loss.txt', 'port_signals.txt'};
for hes = 1:length(groups)
    fileSubSet =find_position_in_cell_lst(strfind(files,groups{hes}));
    if hes == 1
        fileSubSet = fileSubSet(1);
    end %if
    outputTable = writeTableSet(root, files(fileSubSet), groups{hes});
    tableName = regexprep(groups{hes}(1:end-4), '_', ' ');
    outputFile = cat(1, outputFile, ['h3. ' tableName]);
    outputFile = cat(1, outputFile, outputTable);
end %for
write_out_data(outputFile, fullfile(root, 'confluenceTables.txt'))
end %function

function outputTable = writeTableSet(root, filesIn, groupName)
outputTable = {};
[~, baseName] = fileparts(root);
for sei = 1:length(filesIn)
    fileData = read_file_full_line(fullfile(root, filesIn{sei}));
    if sei == 1
        header = ['|', fileData{1}, '|'];
        header = regexprep(header, '\|', '\|\|');
        header = regexprep(header, '\|Row\|', '\| \|');
        header = regexprep(header, '_', ' ');
        
        outputTable = cat(1, outputTable, header);
    end %if
    for lse = 2:length(fileData)
        fileData{lse} = ['||', fileData{lse}, '|'];
    end %for
    
    if strcmp(groupName, 'base_summary.txt')
        outputTable = cat(1, outputTable, fileData{2}(2:end));
    else
        name = regexprep(filesIn{sei}, baseName, '');
        name = regexprep(name, groupName, '');
        name = regexprep(name, '_', ' ');
        tableCollumns = length(strfind(header, '|')) /2;
        name = ['||', name, '|'];
        for hwn = 1:tableCollumns -2
            name = [name, ' |'];
        end %for
        outputTable = cat(1, outputTable, name, fileData{2:end});
    end %if
end %for
outputTable = cat(1, outputTable, ' ');
end %function
