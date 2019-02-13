function x = suavizacao(x,fs,t)

tp = 1/(t*fs);

suav = ones(size(x,1),1);
suav(1:t*fs) = 0:tp:1-tp;
suav(size(x,1)-(t*fs-1):end) = 1:-tp:tp; 

x = x.*suav;
