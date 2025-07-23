using LinearAlgebra
using TaylorSeries
using Random

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

function generate_random_alpha_matrix(ode_order, poly_degree)
  rows = ode_order + 1
  cols = poly_degree + 1
  α_matrix = Matrix{Int}(undef, rows, cols)
  for i in 1:rows
    for j in 1:cols
      α_matrix[i, j] = rand(-10:10)  # Random integers from -10 to 10
    end
  end
  return α_matrix
end

function factorial_product_numeric(n_val, k, i)
  if k == 0
    return 1.0
  end
  product = 1.0
  for j in 1:k
    product *= (n_val + j - i)
  end
  return product
end

function generate_recurrence_coefficients(α_matrix)
  rows, cols = size(α_matrix)

  return function (n_val)
    coeffs = Dict{Int,Float64}()

    # Handle k=0 case: Σ α_{0,i} * a_{n-i}
    for i in 0:(cols-1)
      if α_matrix[1, i+1] != 0
        offset = -i
        coeffs[offset] = get(coeffs, offset, 0.0) + α_matrix[1, i+1]
      end
    end

    # Handle k≥1 cases: Σ α_{k,i} * ∏(n+j-i) * a_{n+k-i}
    for k in 1:(rows-1)
      for i in 0:(cols-1)
        if α_matrix[k+1, i+1] != 0
          offset = k - i
          factorial_prod = factorial_product_numeric(n_val, k, i)
          coefficient = α_matrix[k+1, i+1] * factorial_prod
          coeffs[offset] = get(coeffs, offset, 0.0) + coefficient
        end
      end
    end

    return coeffs
  end
end

function solve_ode_series(α_matrix, initial_conditions, num_terms)
  coeff_func = generate_recurrence_coefficients(α_matrix)
  series_coeffs = Float64.(initial_conditions)

  println(series_coeffs)
  for n_val in length(initial_conditions):(num_terms-1)
    coeffs = coeff_func(n_val)
    # Find highest offset (what we're solving for)
    max_offset = maximum(keys(coeffs))
    # Calculate sum of known terms
    total = 0.0
    for (offset, coeff) in coeffs
      if offset != max_offset
        index = n_val + offset
        if index >= 0 && index < length(series_coeffs)
          total += coeff * series_coeffs[index+1]
        end
      end
    end
    # Solve for next coefficient
    next_coeff = -total / coeffs[max_offset]
    push!(series_coeffs, next_coeff)
  end
  return Taylor1(series_coeffs)
end

function generate_random_ode_dataset()
  ode_order, poly_degree, dataset_size = get_user_inputs()
  println("\nGenerating random α matrices for:")
  println("- ODE Order: $ode_order")
  println("- Polynomial Degree: $poly_degree")

  for k in 1:dataset_size
    α_matrix = generate_random_alpha_matrix(ode_order, poly_degree)
    println("\n--- Example #$k ---")
    println("α matrix:")
    display(α_matrix)
    # Generate random initial conditions based on ODE order
    # Generate initial conditions: y(0), y'(0), y''(0), etc.
    initial_conditions = Float64[]
    for i in 0:(ode_order-1)
      if i == 0
        push!(initial_conditions, rand(1:5))  # y(0) = a_0
        println("y(0) = ", initial_conditions[end])
      else
        push!(initial_conditions, rand(1:5))  # y'(0) = a_1
        println("y'(0) = ", initial_conditions[end])
      end
    end

    try
      taylor_series = solve_ode_series(α_matrix, initial_conditions, 40)
      println("Taylor series: ", taylor_series)
    catch e
      println("Failed to solve this ODE (possibly singular): ", e)
    end
  end
end

generate_random_ode_dataset()
