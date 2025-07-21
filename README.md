# Quick start (fresh machine)
```bash
# 1. grab the code
git clone https://github.com/jonxlegasa/plugboardmethod.git
cd plugboardmethod

# 2. download the dependencies once
julia --project=. -e 'using Pkg; Pkg.instantiate()'

# 3. run the script and put the polynomial degree.
julia generatedata.jl
```
