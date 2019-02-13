annotation_file = 'C:\Projeto Final\Dataset\Gururani\annotation.csv';
suspect_dir = 'C:\Projeto Final\Dataset\Gururani\Copied\';
sample_dir = 'C:\Projeto Final\Dataset\Gururani\Originals\';

annotation = csvread(annotation_file);

tic
for i = 1:80
%     i=28;
   if(annotation(i,2) < 10)
       filenum2 = ['0',num2str(annotation(i,2))];
   else
       filenum2 = num2str(annotation(i,2));
   end
   if(annotation(i,1) < 10)
       filenum1 = ['0',num2str(annotation(i,1))];
   else
       filenum1 = num2str(annotation(i,1));
   end
   files1(i) = str2num([filenum1 filenum2]);
%    [suspect, fs2] = audioread([suspect_dir, filenum2,'.mp3']);
%    fs2_mat(i) = fs2;
%    a = find(suspect~=0);
%    suspect = suspect(a(1):end,:);
%    [~,fs1] = audioread([sample_dir, filenum1,'.mp3'], [1,2]);
%       fs1_mat(i) = fs1;

end