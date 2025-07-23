using LinearAlgebra
using TaylorSeries
using Random

# Get user inputs - unchanged
function get_user_inputs()
  println("The Plugboard: Randomized ODE Generator")
  println("=================================")
  print("What order do you want your ODE to be? (e.g., 1 for first order, 2 for second order): ")
  ode_order = parse(Int, readline())
  print("What is the highest degree polynomial you want? (e.g., 2 for degree 2): ")
  poly_degree = parse(Int, readline())
  print("How many ODEs do you want solved? (e.g., 50 for 50 training examples): ")
  dataset_size = parse(Int, readline())
  return ode_order, poly_degree, dataset_size
end

# Generate random alpha matrix - unchanged
function generate_random_alpha_matrix(ode_order, poly_degree)
  rows = ode_order + 1
  cols = poly_degree + 1
  α_matrix = Matrix{Int}(undef, rows, cols)
  for i in 1:rows
    for j in 1:cols
      α_matrix[i, j] = rand(Bool) ? rand(-10:-1) : rand(1:10)
    end
  end
  return α_matrix
end

# Factorial product - keep the same
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

# New closed-form implementation
function solve_ode_series_closed_form(α_matrix, initial_conditions, num_terms)
  rows, cols = size(α_matrix)
  m = rows - 1  # ODE order

  # Initialize series with initial conditions
  series_coeffs = Float64.(initial_conditions)

  println("Starting with initial conditions: ", series_coeffs)
  println("ODE order (m): ", m)

  # Compute coefficients using closed form
  for n in 0:(num_terms-length(initial_conditions)-1)
    # Check if c_{m,0} is zero (would make equation singular)
    c_m_0 = α_matrix[m+1, 1]  # c_{m,0} is at position [m+1, 1]
    if c_m_0 == 0
      println("Error: c_{m,0} = 0, cannot solve")
      break
    end

    # Compute the sum term
    sum_term = 0.0

    for k in 0:m
      for j in 0:(cols-1)
        c_kj = α_matrix[k+1, j+1]  # c_{k,j} at position [k+1, j+1]

        if c_kj != 0
          coeff_index = n - j + k

          # Check if we have this coefficient available
          if coeff_index >= 0 && coeff_index < length(series_coeffs)
            factorial_term = factorial_product_numeric(n - j, k, 0)
            term_value = c_kj * factorial_term * series_coeffs[coeff_index+1]
            sum_term += term_value
          end
        end
      end
    end

    # Apply the closed form formula: a_{n+m} = -(1/(c_{m,0} * (n+m)!)) * sum
    factorial_nm = factorial(big(n + m))  # Use big integer for large factorials
    denominator = c_m_0 * factorial_nm

    new_coeff = -sum_term / denominator
    push!(series_coeffs, new_coeff)
  end

  return Taylor1(series_coeffs), series_coeffs
end

# Updated dataset generation function
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

    # Generate exactly ode_order initial conditions
    initial_conditions = Float64[]
    for i in 0:(ode_order-1)
      if i == 0
        push!(initial_conditions, rand(1:5))  # y(0) = a_0
        println("y(0) = ", initial_conditions[end])
      elseif i == 1
        push!(initial_conditions, rand(1:5))  # y'(0) = a_1
        println("y'(0) = ", initial_conditions[end])
      end
    end

    try
      taylor_series, series_coeffs = solve_ode_series_closed_form(α_matrix, initial_conditions, 10)
      println("Truncated Taylor series: ", taylor_series)
      println("Truncated series coefficients: ", series_coeffs)
    catch e
      println("Failed to solve this ODE: ", e)
    end
  end
end

generate_random_ode_dataset()
