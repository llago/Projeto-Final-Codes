function dirs = getdir(folder, hidden)
%GETDIR Get all directories inside folder

fileList = dir(folder);

isBadDir = ~(cat(1,fileList.isdir));

if ~hidden
    for index=1:size(fileList,1)
        %# on OSX, hidden files start with a dot
        isBadDir(index) = strcmp(fileList(index).name(1),'.') || isBadDir(index);
        if ~isBadDir(index) && ispc
            %# check for hidden Windows files - only works on Windows
            [~,stats] = fileattrib(fullfile(folder,fileList(index).name));
            if stats.hidden
                isBadDir(index) = true;
            end
        end
    end
end

fileList(isBadDir) = [];

dirs = {fileList.name}';
end