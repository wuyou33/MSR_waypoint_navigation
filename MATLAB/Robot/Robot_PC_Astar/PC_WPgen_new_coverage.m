function [Wp, Wp_hack] = PC_WPgen_new_coverage(gs, gw, Gobs, rcg)

    Wp_hack = [2 2 2;
                   12 2 2;
                   12 4 2;
                   2 4 2;
                   2 6 2;
                   12 6 2];
               
    Row_sweep = [0;
                          2;
                          0;
                          -2;
                          0;
                          2];
    
    Gvis = zeros(gs(1),gs(2));
    for obsidx = 1:size(Gobs,1)
        Gvis(Gobs(obsidx,1), Gobs(obsidx,2)) = -1;
    end
  
    for rowidx = 1:gs(1)
        for colidx = 1:gs(2)
             GA{rowidx,colidx} = checkGridAvalibility(rowidx,colidx, gs, Gobs);
        end
    end
    
    
    
    scg = rcg;
    Wp = [];
    for idx = 1: size(Wp_hack,1)
        gcg = [ceil(Wp_hack(idx,1)) ceil(Wp_hack(idx,2))];
        Wp_s = PC_NewAlg(gs, Gobs, Wp_hack(idx,3), Row_sweep,scg, gcg, GA); %segemented Wp
        Wp_s(:, 3) = Wp_hack(idx,3);
        Wp = [Wp; Wp_s];
        scg = gcg;
    end
        
    Wp(:, 1:2) = (Wp(:, 1:2) - 0.5)*gw;
    Wp_hack = (Wp_hack-0.5)*gw;
end