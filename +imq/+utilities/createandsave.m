function [] = createandsave( filename, varargin )
	%CREATEANDSAVE Creates folder and subfolders and save the desired file
	% 
	[pathstr, ~, ~] = fileparts(filename);
	
	imq.utilities.createFolderIfNotExists(pathstr);
	
% 	cfg = struct();
% 	
% 	fieldNames = fieldnames(records.cfg);
% 	
% 	for i=1:length(fieldNames),
% 		cfg.(fieldNames{i}) = records.cfg.(fieldNames{i});
% 	end
% 	
% 	records.cfg = cfg;

	names = {};
	for k=2:nargin
		names{k-1} = inputname(k);
		eval([inputname(k) '= varargin{' num2str(k) '-1};']);
	end
	
	save(filename, names{:});
	
end

