function [Wp_best, Wp, cost_best, cost, Gvis_best, Gvis] = recurse_cost(gs, ccg, gcg, GA, GSC,cost, cost_best, Wp, Wp_best, shape, closed_ncg, rows, cols, Gvis, Gvis_best, rows_init)
   
    Rgp = [0 -1; 0 1; 0 2;                         % Relative grid positions between modules
                  0 -1; 1 0; 1 -1;
                 -1 0; 0 1; 1 1;
                  -1 0; 0 1; 0 2;
                  1 0; 0 1; -1 1;
                  1 -1; 1 0; 2 0;
                  1 -1; 1 0; 2 -1];  


    rmc = ['F', 'R', 'B', 'L']; % Robot movement commands
    ncg = [];
   
    for idxrmc = 1:size(rmc,2) 
        switch(rmc(idxrmc))
            case 'F'
                ncg = ccg + [1 0];
            case 'R'
                ncg = ccg + [0 1];
            case 'B'
                ncg = ccg + [-1 0];
            case 'L'
                ncg = ccg + [0 -1];
        end
        
        if (rows(1)~=0 || rows(2) ~= 0)
            bound_row = rows;
            bound_col = [1 gs(2)];
        elseif (cols(1)~=0 || cols(2) ~= 0)
            bound_col = cols;
            bound_row = [1 gs(1)];
        end
        
        if (ncg(2) >= bound_row(1) && ncg(2) <= bound_row(2) && ...
                ncg(1) >= bound_col(1) && ncg(1) <= bound_col(2))  
            
           
           %disp(['=================================='])
           %disp(['going from (',num2str(ccg(1)), ', ', num2str(ccg(2)), ') to (', num2str(ncg(1)), ', ', num2str(ncg(2)) ,').']);
           %Wp
            
            isrepeat = false;
            for wpidx = 1:size(Wp,1)
                if ncg == Wp(wpidx, :)
                    isrepeat = true;
                end
            end
            
            if isrepeat == false && (~(ncg(1) == closed_ncg(1) && ncg(2) == closed_ncg(2)))
                ga = GA{ncg(1), ncg(2)};

                if ga(shape) == 1 
                    
                    Wp_temp = Wp;
                    ccg_temp = ccg;
                    cost_temp = cost;
                    Gvis_temp = Gvis;
                    closed_ncg = ncg;
                    
                    Wp = [Wp; ncg];
                    ccg = ncg;
                    cost = cost+1;
                    Rgp = ncg + [0 -1; 0 0; 1 0; 1 -1];
                    for rgpidx = 1:size(Rgp,1)
                        if Gvis(Rgp(rgpidx,1), Rgp(rgpidx,2)) == 1
                            cost = cost + 0.2;
                        end
                        Gvis(Rgp(rgpidx,1), Rgp(rgpidx,2)) = 1;
                    end
                    
                    if (ncg == gcg)
                        if (rows(1)~=0 || rows(2) ~= 0)
                            for rowidx =1:rows_init(2)
                                for colidx = 1:gs(2)
                                    if Gvis(colidx, rowidx) == 1
                                        cost = cost - 5;
                                    elseif Gvis(colidx, rowidx) == 0
                                        cost = cost + 0.8;
                                    end
                                end
                            end
                        end
                        if (cost < cost_best)
                            Wp_best = Wp;
                            cost_best = cost;
                            Gvis_best = Gvis;
                            return
                        else
                            return
                            %[Wp_best, Wp, cost_best, cost, Gvis_best, Gvis] = recurse_cost(gs, ccg, gcg, GA, cost, cost_best, Wp, Wp_best, shape, closed_ncg, rows, cols, Gvis, Gvis_best, rows_init);
                        end
                    else
                        [Wp_best, Wp, cost_best, cost, Gvis_best, Gvis] = recurse_cost(gs, ccg, gcg, GA, GSC, cost, cost_best, Wp, Wp_best, shape, closed_ncg, rows, cols, Gvis, Gvis_best, rows_init);
                    end
                    
                    Gvis = Gvis_temp;
                    ccg = ccg_temp;
                    Wp = Wp_temp;
                    cost = cost_temp;
                end
            end
        end
    end
end