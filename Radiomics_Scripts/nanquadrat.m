% Function to Add in quadrature the elements of each column, for each row, 
% of a cell or mat array A taking into account NaNs

function err = quadrat(A)
    
    err = zeros(numel(A(:,1)),1);
    
    % Check if input array is cell or matrix
    if isa(A,'cell')
    
        A = cell2mat(A);
        
        for i = 1:numel(A(:,1))
            
            % Compute error from quadrature of elements in each column for
            % a single row and add to err array
            Sum = 0;
            
            % Remove NaN in row
            B = A(i,~isnan(A(i,:)));
            
            for j = 1:numel(B)
               
                Sum = Sum + B(j).^2;
                
            end
            
            err(i,1) = (1/numel(B)).*sqrt(Sum);
            
        end
    
    elseif isa(A,'double')
        
        for i = 1:numel(A(:,1))
            
            Sum = 0;

            B = A(i,~isnan(A(i,:)));

            for j = 1:numel(B)
               
                Sum = Sum + B(j).^2;
                
            end
            
            err(i,1) = (1/numel(B)).*sqrt(Sum);
            
        end
        
    else
        
        fprintf('    Input either a matrix or a cell of doubles.');
        
    end
    
end
