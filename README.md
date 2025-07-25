# plugboardmethod


| Folder | What’s inside |
|--------|---------------|
| `data/` | output goes here (`.json`, `.txt`) |

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

# Generate new datasets
If you want a new dataset, just delete the arrays in "series_coefficients" in ./data/dataset.json
It should look like this

```json
{"series coefficient":[]}
```
