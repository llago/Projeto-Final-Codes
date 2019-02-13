function [] = createFolderIfNotExists(pathstr)
	if ~exist(pathstr, 'dir'),
		mkdir(pathstr);
	end
end