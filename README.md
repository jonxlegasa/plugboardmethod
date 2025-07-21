# Quick start (fresh machine)

```bash
# 1. grab the code
git clone https://github.com/jonxlegasa/plugboardmethod.git
cd plugboardmethod

# 2. download the dependencies once
julia --project=. -e 'using Pkg; Pkg.instantiate()'

# 3. run the demo simulation (saves data & figs to ./data)
julia generatedata.jl
```
