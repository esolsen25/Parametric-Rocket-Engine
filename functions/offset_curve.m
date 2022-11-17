
function [joinedx, joinedy] = offset_curve(x, y, offset, haxes, intersectremove)
    % Offset a curve by a given distance
    % Inputs:
    %       x, y: input x and y coordinates
    %       offset: offset amount in arbitrary units or in points if haxes
    %           is provided
    %       haxes: handle to parent axis if offset is determined in points
    %       intersectremove: remove self-intersecting portions (default is
    %           true)
    %
    % J. Duchateau, - IHU LIRYC, Bordeaux, France - 2015. 
    %
    % You are free to distribute/modify as you please.
    
    
    % First check for colinear points and remove them
    if nargin < 5, intersectremove = 1; end
    iPt=2;
    eps = 10^-10;
    xprod = @(x1, y1, x2, y2) x1*y2 - x2*y1;
    
    while iPt < length(x)
        if abs(xprod(x(iPt)-x(iPt-1), y(iPt)-y(iPt-1), x(iPt+1)-x(iPt), y(iPt+1)-y(iPt))) < eps
            y(iPt) = [];
            x(iPt) = [];
        else
            iPt = iPt+1;
        end
    end
    
    % Now offset...
    % 1) Get unit vector size in points
    if nargin < 4 || isempty(haxes), dirvect = [1 1];
    else
        dirvect = vectorToPoints([1 1], haxes);
    end
    
    % 2) Convert vector directions in points
    compvect = dirvect(1) .* diff(x) + 1i*dirvect(2) .* diff(y);
    directions = angle(compvect);
    
    % 3) Rotate by 90°
    directions = directions + pi/2;
    
    % 4) Offset by input offset value
    offsetvect = offset * exp(1i*directions);
    
    % 5) Convert back to axes units
    offx = real(offsetvect) ./ dirvect(1);
    offy = imag(offsetvect) ./ dirvect(2);
    
    % Now that we have all our offsets, compute intersections between lines
    % 1) Create new segment list
    sx = offx + x(1:end-1);
    sy = offy + y(1:end-1);
    ex = offx + x(2:end);
    ey = offy + y(2:end);
    
    % 2) Join neighboring segments
    iSeg = 1;
    joinedx = sx(1);
    joinedy = sy(1);
    while iSeg < length(sx)
        % Find intersection with next
        [xi, yi, flag] = intersectSeg(sx(iSeg), sy(iSeg), ex(iSeg), ey(iSeg), sx(iSeg+1), sy(iSeg+1), ex(iSeg+1), ey(iSeg+1));
        if ~flag % Remove the next segment which is colinear
            sx(iSeg+1) = []; sy(iSeg+1) = []; ex(iSeg+1) = []; ey(iSeg+1) = [];
        else % Add the intersection to the point list
            joinedx = [joinedx xi];
            joinedy = [joinedy yi];
            iSeg = iSeg+1;
        end
    end
    joinedx = [joinedx ex(end)];
    joinedy = [joinedy ey(end)];
    
    if ~intersectremove, return; end
    % 3) Remove self-intersections
    iPt = 2;
    while iPt < length(joinedx) - 1
        
        % Find candidates for self intersection
        xbnds = sort(joinedx([iPt-1 iPt]));
        ybnds = sort(joinedy([iPt-1 iPt]));
        
        rside = xbnds(2) < joinedx(iPt+1:end); % Fast scan of candidates
        lside = xbnds(1) > joinedx(iPt+1:end);
        above = ybnds(2) < joinedy(iPt+1:end);
        below = ybnds(1) > joinedy(iPt+1:end);
        
        rside = rside(1:end-1) & rside(2:end); % Both on right side
        lside = lside(1:end-1) & lside(2:end);
        above = above(1:end-1) & above(2:end);
        below = below(1:end-1) & below(2:end);
        
        cands = find(~(rside | lside | above | below));
        if ~isempty(cands)
            [xi, yi, flag] = arrayfun(@(x,y) ...
                intersectSeg(joinedx(iPt-1), joinedy(iPt-1), joinedx(iPt), joinedy(iPt), ...
                joinedx(x), joinedy(x), joinedx(x+1), joinedy(x+1)), (iPt+cands));
            iflag = find(flag == 1, 1, 'last');
            if ~isempty(iflag)
                joinedx(iPt) = xi(iflag);
                joinedy(iPt) = yi(iflag);
                joinedx(iPt+1:iPt+cands(iflag)) = [];
                joinedy(iPt+1:iPt+cands(iflag)) = [];
            end
        end
        iPt = iPt+1;
    end
end


function [xi, yi, flag] = intersectSeg(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2)
    eps = 10^-10;
    adx = ax2-ax1; ady = ay2-ay1;
    bdx = bx2-bx1; bdy = by2-by1;
    
    xprod = @(x1, y1, x2, y2) x1*y2 - x2*y1;
    rxs = xprod(adx, ady, bdx, bdy);
    
    if abs(rxs) < eps % Parallel segments
        xi = NaN; yi = NaN; flag = 0;
    else
        t = xprod(bx1-ax1, by1-ay1, bdx, bdy) / rxs;
        u = xprod(bx1-ax1, by1-ay1, adx, ady) / rxs;

        xi = ax1 + t*adx;
        yi = ay1 + t*ady;
        if t>=0 && t <= 1 && u >= 0 && u <= 1
            flag = 1;
        else
            flag = 2;
        end
    end
end


function vect = vectorToPoints(vect,hparent)
    % First step: data units to relative inside axis
    if strcmpi(get(hparent, 'Type'), 'axes')
        xspan = diff(get(hparent, 'XLim'));
        yspan = diff(get(hparent, 'YLim'));
        try 
            vect = vect./[xspan yspan];
        catch
            vect = vect./[xspan;yspan];
        end
    end
    
    % Second step: go up to figure
    while(~strcmpi(get(hparent, 'Type'), 'figure'))
        punit = get(hparent, 'Units');
        ppos = get(hparent, 'Position');
        if strcmpi(punit, 'normalized')
            %Multiply to go to parent
            try
                vect = vect.*ppos([3 4]);
            catch
                vect = vect.*ppos([3;4]);
            end
        else
            % Convert units to points and add up
            error('Please use only normalized units');
        end
        hparent = get(hparent, 'Parent');
    end
    
    % Third step: Convert from relative to figure to paper point
    figunit = get(hparent, 'PaperUnits');
    figsize = get(hparent, 'PaperPosition');
    figsize = convertToPoint(figsize([3 4]), figunit);
    try
        vect = vect.*figsize;
    catch
        vect = vect.*figsize';
    end
end


function outdim = convertToPoint(indim, unit)
% Convert to point from input unit
    switch(lower(unit))
        case 'normalized'
            error('Normalized units are not supported');
        case 'inches'
            outdim = 72*indim;
        case 'centimeters'
            outdim = 72*0.393700787*indim;
        case 'points'
            outdim = indim;
        case 'pixels'
            error('Pixel units are not supported');
        otherwise
            error('Unrecognized input unit');
    end
end
