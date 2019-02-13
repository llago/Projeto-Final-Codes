function [] = displayNMF(V, W, H, varargin)
	
	parser = inputParser;
	
	addRequired(parser, 'V');
	addRequired(parser, 'W');
	addRequired(parser, 'H');
	addOptional(parser, 'reset', false);
	
	parse(parser, V, W, H, varargin{:})
	
	args = parser.Results;
	
	persistent fig;
	
	if isempty(fig) || args.reset || ~isvalid(fig) 
		fig = figure;
	end
	
	figure(fig);

	[m,k] = size(W);
	[~, n] = size(H);
    
    %Normalizing all data
    auxV = 1 - V ./ (max(V(:))+eps);
    W = 1 - W ./ (max(W(:))+eps);
    H = 1 - H ./ (max(H(:))+eps);
     
    ratio = 8;
    gaps = k - 1;
    frames = ratio*k + gaps;
    
    if k > 5
        auxW = zeros(m, frames); 
        auxH = zeros(frames, n);
    else
        auxW = ones(m, frames); 
        auxH = ones(frames, n);
    end
    
    index = 0;
    for m=1:k
        
        for r = 1:ratio
            auxW(:, index + r) = W(:, m);
            auxH(index + r, :) = H(m, :);
        end
        
        index = index + ratio + 1;
    end
    
    sub = subplot(3, 4, [2 4]);
    imagesc(auxH);
    colormap(gray);
    axis xy;
    ylabel('Fonte');
    sub.YTick = (ratio + 1)/2:ratio+1:frames;
    sub.YTickLabel = 1:k;
    for m=ratio+1:ratio+1:frames,
        line([0 n],[m+0.5 m+0.5],'LineStyle','-', 'Color', 'black')
        line([0 n],[m-0.5 m-0.5],'LineStyle','-', 'Color', 'black')
    end
    
    sub = subplot(3, 4, [5 9]);
    imagesc(auxW);
    colormap(gray);
    axis xy;
    ylabel('Frequência');
    xlabel('Fonte');
    
    sub.XTick = (ratio + 1)/2:ratio+1:frames;
    sub.XTickLabel = 1:k;
    for m=ratio+1:ratio+1:frames,
        line([m+0.5 m+0.5], [0 m],'LineStyle','-', 'Color', 'black')
        line([m-0.5 m-0.5], [0 m],'LineStyle','-', 'Color', 'black')
    end
    
    subplot(3, 4, [6 8 10 12]);
    imagesc(auxV);
    colormap(gray);
    axis xy;
    xlabel('Amostras');
    
    pause(0.01);
end