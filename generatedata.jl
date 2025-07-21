using LinearAlgebra
using Symbolics

@variables n l
@variables a[0:100]  # Array of symbolic coefficients

function create_symbolic_coefficients(max_index)
    coeffs = Dict()
    for i in 0:max_index 
        coeffs[i] = only(@variables $(Symbol("a_$i")))
    end
    return coeffs
end

function factorial_product(n, k, i)
    if k == 0
        return 1
    end
    product = 1
    for j in 1:k
        product *= (n + j - i)
    end
    return product
end

function matrix_element(n, k, i)
    # From the pattern: row k, column i
    # Element is: ∏(n + j - i) for j = 1 to k, times a_{n + k - i}
    
    # Create the coefficient symbol a_{n + k - i}
    offset = k - i
    if offset == 0
        coeff_symbol = only(@variables a_n)
    elseif offset > 0
        coeff_symbol = only(@variables $(Symbol("a_n+$offset")))
    else  # offset < 0
        coeff_symbol = only(@variables $(Symbol("a_n$offset")))  # negative already included
    end
    
    return factorial_product(n, k, i) * coeff_symbol
end


function construct_recurrence_matrix(n_symbolic, matrix_size)
    # coeffs = create_symbolic_coefficients(matrix_size)
    recurrence_matrix = Matrix{Any}(nothing, matrix_size, matrix_size)
    
    for k in 0:(matrix_size-1)
        for i in 0:(matrix_size-1)
            # recurrence_matrix[k+1, i+1] = matrix_element(n_symbolic, k, i, coeffs)
            recurrence_matrix[k+1, i+1] = matrix_element(n_symbolic, k, i)
        end
    end
    
    return recurrence_matrix
end


function generate_recurrence_relation(α_matrix)
    matrix_size = size(α_matrix, 1)
    println("α_matrix size: ", size(α_matrix))
    
    recurrence_matrix = construct_recurrence_matrix(n, matrix_size)
    println("Recurrence matrix size: ", size(recurrence_matrix))
    
    return dot(recurrence_matrix, α_matrix)
end

α_legendre = [l*(l+1)  0   0;
              0       -2   0;
              1        0  -1]

recurrence = generate_recurrence_relation(α_legendre)
println("Legendre recurrence relation: ", recurrence, " = 0")
