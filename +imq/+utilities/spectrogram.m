function [out ] = spectrogram( Yw, L, S, NFFT, F, varargin)

	parser = inputParser;
	
	addRequired(parser, 'Yw');
	addRequired(parser, 'L');
	addRequired(parser, 'S');
	addRequired(parser, 'NFFT');
	addRequired(parser, 'F');
	addParamValue(parser, 'scale', 'linear');
	addParamValue(parser, 'colormap', 'gray');
	
	parse(parser, Yw, L, S, NFFT, F, varargin{:});
	
	args = parser.Results;
	
    M = size(Yw,2);
    n = (M-1)*S + L;
    K = round((NFFT+1)/2);
    Y = zeros(K, M);
    
    %Only real part
    for m=1:size(Yw,2)
        Y(:, m) = abs(Yw(1:K, m));
	end
    
	f = linspace(0, 1, K)*F/2;
    t = [S/2:S:n-S/2]/F;
    
    figure;
	if ~strcmp(args.colormap, 'default') && isstr(args.colormap)
		colormap(flipud(colormap(args.colormap)))
	end
	if strcmp(args.scale, 'log')
		Y = 20*log10(Y);
	end
	
    h = imagesc(t, f, Y);
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
	
    set(gca,'YDir', 'normal'); % flip the Y Axis so lower frequencies are at the bottom
	if nargout
		out = h;
	end
end