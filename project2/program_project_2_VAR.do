cd "/Users/guillaume/MyProjects/HECProject/CorporateFinance-msc1sem-/project2/"
import excel "Data_VAR.xlsx", sheet("analysis") firstrow clear



* choose ticker that I want 


gen log_LFCF=log(LeveredFreeCashFlow)
keep firm year growth_sale-blev_ratio log_at  intan_at_ratio sic conml
gen firm2=firm
drop firm
rename firm2 firm
sort year firm

order year firm sic growth_sale-blev_ratio log_at



*foreach var of varlist year-log_at{
*drop if `var'==.
*}

save data_gal,replace
use data_gal,clear

tsset date
gen Lroa=L.ReturnonAssets
gen Llog_LFCF=L.log_LFCF
gen L2log_LFCF=L2.log_LFCF
gen Lgross_margin=L.gross_margin
gen Lintan_at=L.intan_at

*Find the average growth of sales within sector for every year
by year sic2: egen mean_growth_sale=mean(growth_sale)
*Regression on single firm data- AR(1)
xtset date
reg log_LFCF Llog_LFCF

*Regression on all firm data- no fixed effects 
reg growth_sale Lgrowth_sale 
*Regression on all firm data AR(2)- no fixed effects
reg growth_sale Lgrowth_sale L2growth_sale 

*Regression on all firm data AR(1), panel data
xtset date
xtdpdsys growth_sale, lags(1) 
xi:xtdpdsys growth_sale i.year, lags(1) 
xi:xtdpdsys log_LFCF  i.date ,lags(1) pre(Lroa) 
xi:xtdpdsys roa, lags(1)
xi:xtdpdsys gross_margin, lags(1)
*Multilevel AR(1)
gen dev_growth=growth_sale-mean_growth_sale
by firm : gen Ldev_growth=L.dev_growth
reg dev_growth L.dev_growth
*Eliminate constant
reg dev_growth L.dev_growth, nocons
save data503,replace
*Keep the sector averages for sale growth per year
collapse  (mean) growth_sale, by(year sic2)
sort sic2 year
rename growth_sale mean_growth_sale
*Perform a panel dynamic panel regression, on sector averages

xtdpdsys mean_growth_sale, lags(1)

*Restricted Panel VAR
use data503,clear
drop company
gen company = 1
destring company, replace
xtset date company
* 1st related to other in pre() + lui même
xi:xtdpdsys growth_sale, lags(1) pre(Lroa Lgross_margin)
xi:xtdpdsys ReturnonAssets, lags(1) 
xi:xtdpdsys gross_margin, lags(1) 

xi:xtdpdsys log_LFCF, lags(1) pre(Lroa)
xi:xtdpdsys intan_at, lags(1) 
xi:xtdpdsys gross_margin, lags(1) 
