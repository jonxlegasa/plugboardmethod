using LinearAlgebra
using Symbolics
using Random

@variables n l
@variables a[0:100]  # Array of symbolic coefficients

function get_user_inputs()
  println("The Plugboard: Randomized ODE Generator")
  println("=================================")
  # Order of the ODE
  print("What order do you want your ODE to be? (e.g., 1 for first order, 2 for second order): ")
  ode_order = parse(Int, readline())

  # Highest degree of the polynomial
  print("What is the highest degree polynomial you want? (e.g., 2 for degree 2): ")
  poly_degree = parse(Int, readline())

  # Size of the dataset
  print("How many ODEs do you want solved? (e.g., 50 for 50 training examples): ")
  dataset_size = parse(Int, readline())

  return ode_order, poly_degree, dataset_size
end

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



function generate_random_alpha_matrix(ode_order, poly_degree)
  rows = ode_order
  cols = poly_degree
  α_matrix = Matrix{Any}(nothing, rows, cols)
  for i in 1:rows
    for j in 1:cols
      α_matrix[i, j] = rand(-100:100)  # Random integers from -10 to 10
    end
  end
  return α_matrix
end


function generate_random_ode_dataset()
  ode_order, poly_degree, dataset_size = get_user_inputs()
  println("\nGenerating random α matrices for:")
  println("- ODE Order: $ode_order")
  println("- Polynomial Degree: $poly_degree")

  for k in 1:dataset_size
    println("\n--- Example #$k ---")
    α_matrix = generate_random_alpha_matrix(ode_order, poly_degree)
    println("Generated α matrix:")
    display(α_matrix)

    recurrence = generate_recurrence_relation(α_matrix)
    println("Recurrence relation: ", recurrence, " = 0")
  end
end


# println("Legendre recurrence relation: ", recurrence, " = 0")
generate_random_ode_dataset()
