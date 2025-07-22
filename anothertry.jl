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

function generate_recurrence_relation_general(α_matrix, n, max_terms=10)
  rows, cols = size(α_matrix)

  # Dictionary to collect coefficients for each a_{n+offset}
  recurrence_coeffs = Dict{Int,Any}()

  # Handle k=0 case: Σ α_{0,i} * a_{n-i}
  for i in 0:(cols-1)
    if i < cols && α_matrix[1, i+1] != 0  # α_{0,i}
      offset = -i  # coefficient of a_{n-i}

      if haskey(recurrence_coeffs, offset)
        recurrence_coeffs[offset] += α_matrix[1, i+1]
      else
        recurrence_coeffs[offset] = α_matrix[1, i+1]
      end
    end
  end

  # Handle k≥1 cases: Σ α_{k,i} * ∏(n+j-i) * a_{n+k-i}
  for k in 1:(rows-1)
    for i in 0:(cols-1)
      if i < cols && α_matrix[k+1, i+1] != 0  # α_{k,i}
        offset = k - i  # coefficient of a_{n+k-i}
        factorial_prod = factorial_product(n, k, i)

        coefficient = α_matrix[k+1, i+1] * factorial_prod

        if haskey(recurrence_coeffs, offset)
          recurrence_coeffs[offset] += coefficient
        else
          recurrence_coeffs[offset] = coefficient
        end
      end
    end
  end

  return recurrence_coeffs
end

function display_recurrence_relation(recurrence_coeffs)
  println("Recurrence relation (= 0):")
  for (offset, coeff) in sort(collect(recurrence_coeffs), by=x -> x[1], rev=true)
    if offset == 0
      println("+ ($coeff) * a_n")
    elseif offset > 0
      println("+ ($coeff) * a_{n+$offset}")
    else
      println("+ ($coeff) * a_{n$offset}")  # negative offset
    end
  end
end


function generate_random_ode_dataset()
  ode_order, poly_degree, dataset_size = get_user_inputs()
  println("\nGenerating random α matrices for:")
  println("- ODE Order: $ode_order")
  println("- Polynomial Degree: $poly_degree")

  for k in 1:dataset_size
    # α_matrix = generate_random_alpha_matrix(ode_order, poly_degree)
    α_matrix = [1 0;
               1 0
              1 0 ]
    println("\n--- Example #$k ---")
    n = 1
    recurrence_coeffs = generate_recurrence_relation_general(α_matrix, n)
    display_recurrence_relation(recurrence_coeffs)
  end
end

generate_random_ode_dataset()
