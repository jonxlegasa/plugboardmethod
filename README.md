# Quick start (fresh machine)
```bash
# 1. grab the code
git clone https://github.com/jonxlegasa/plugboardmethod.git
cd plugboardmethod

# 2. download the dependencies once
julia --project=. -e 'using Pkg; Pkg.instantiate()'

# 3. run the script and put the ODE order and degree of the polynomial
julia main.jl
```


# Increase number of terms for Taylor Series and coefficients
Go to main.jl and adjust the last parameter in 'solve_ode_series_closed_form'
