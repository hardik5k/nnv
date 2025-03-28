function result = verify_values(R, A, epsilon)
% Output: (should we change this to sat, unsat or unknown?)
%   - result: 0 ->  property failed
%             1 ->  property satisfied
%             2 ->  unknown

    result = 1;

    S = R.intersectEpsilonBound(A, epsilon); 
    if isempty(S)
        result = 0; 
    end

end % close function

