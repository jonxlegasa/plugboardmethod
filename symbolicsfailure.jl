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

function create_coefficient_variables(polynomial_degree)
  indices = collect(0:polynomial_degree)  # Start from 0, go up to n+degree
  
  coeff_vars = Symbolics.variables(:a_n, indices)
  println(coeff_vars)
  
  return coeff_vars
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


function matrix_element(n, k, i, coeff_vars)
  offset = k - i
  coeff_symbol = coeff_vars[n + offset]
  return factorial_product(n, k, i) * coeff_symbol
  
end



# Then clean up the final result's display
function clean_recurrence_display(recurrence)
  clean_str = replace(string(recurrence), r"Symbol\(([^)]+)\)" => s"\1")
  return clean_str
end

function construct_recurrence_matrix(n_symbolic, matrix_size, polynomial_degree)
  coeff_vars = create_coefficient_variables(polynomial_degree)
  recurrence_matrix = Matrix{Any}(nothing, matrix_size, matrix_size)
  
  for k in 0:(matrix_size-1)
    for i in 0:(matrix_size-1)
        recurrence_matrix[k+1, i+1] = matrix_element(n_symbolic, k, i, coeff_vars)
    end
  end
  
  return recurrence_matrix
end


function generate_recurrence_relation(α_matrix, polynomial_degree)
  matrix_size = size(α_matrix, 1)
  println("α_matrix size: ", size(α_matrix))

  recurrence_matrix = construct_recurrence_matrix(n, matrix_size, polynomial_degree)
  println("Recurrence matrix size: ", size(recurrence_matrix))

  return dot(recurrence_matrix, α_matrix)
end



function generate_random_alpha_matrix(ode_order, poly_degree)
  rows = ode_order + 1
  cols = poly_degree + 1
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

    recurrence = generate_recurrence_relation(α_matrix, poly_degree)
    remove_this_symbol_already = clean_recurrence_display(recurrence)
    println("Recurrence relation: ", remove_this_symbol_already, " = 0")
  end
end


# println("Legendre recurrence relation: ", recurrence, " = 0")
generate_random_ode_dataset()
