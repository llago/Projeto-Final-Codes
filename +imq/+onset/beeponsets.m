function x = beeponsets(onsets,fs)

	beep=sin(2*pi*1760/fs*linspace(0,0.05*fs,0.05*fs));

	x = zeros(1,max(onsets)+length(beep));

	for i=1:length(onsets)
		start = onsets(i);
		stop = onsets(i)+length(beep)-1;
		x(start:stop)=0.15*beep;
	end

end