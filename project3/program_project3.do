clear

import excel "/Users/guillaume/MyProjects/HECProject/CorporateFinance-msc1sem-/project3/data_return.xlsx", sheet("Sheet1") firstrow

ssc install winsor2

gen ri_rf = NVDA - TNX
gen rm_rf = MSCI - TNX

//winsor2 ri_rf rm_rf, suffix(_f) cuts(1 99)

reg ri_rf rm_rf, robust
