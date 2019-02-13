function files = getTrainedFilesName(path, varargin)

    %Load trained basis spectra
    if exist([path filesep 'training.mat'], 'file') ~= 2,
        files = [];
        return;
    end
    
    filesInf = dir([path filesep '*.mat']);
    
    files = strrep(setdiff({filesInf.name}, {'training.mat'}), '.mat', '.wav');
end