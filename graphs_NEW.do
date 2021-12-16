//Graphs
***1. plot for shape PSD, plotted against mean PSD**
//EXCEL 1. get mean PSD for every PSD category 
bysort psd_cat: sum psd
//get adjusted HR and CI for PSD groups
mi estimate, hr: stcox i.psd_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat)
//get SE of beta
mi estimate: stcox i.psd_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) 
// calculate weight as: 1/((SE of beta)^2) // insert in excel
qui import excel using "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\graphs\plot_mean_psd.xlsx", firstrow clear
twoway (rspike lci uci meanpsd, lcolor(black) yscale(log)) ///
(scatter hr meanpsd [w=weight], msymbol(s) msize(medium) mcolor(cranberry) yscale(log) yscale(log range(0.7 1.3)) ylabel(0.8(0.1)1.3) xscale(range(0.1 0.4)) xlabel(0.1(0.05)0.4) graphregion(color(white)) legend(label(1 "95% CI") label(2 "Hazard ratio")) title("PSD-level risk for Breast Cancer") xtitle("Mean PSD (W/Hz)") ytitle("Hazard Ratio (95%CI)"))

***2. plot for shape social jetlag, plotted against mean sleep midpoint difference
// get median sleep difference per group and insert in excel (non-normal distribution)
bysort sj_cat: sum sj,detail
//get HR and CI for SJ groups
mi estimate, hr: stcox i.sj_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata (townsend_cat region_more age_5y)
// get SE of beta
mi estimate: stcox i.sj_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata (townsend_cat region_more age_5y) // get beta SE
// calculate weight as: 1/((SE of beta)^2) // insert in excel
qui import excel using "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\graphs\plot_mean_sj.xlsx", firstrow clear
twoway (rspike lci uci meansj, lcolor(black) yscale(log)) ///
(scatter hr meansj [w=weight], msymbol(s) msize(small) mcolor(cranberry) yscale(log) yscale(log range(0.8 1.5)) ylabel(0.8(0.2)1.5) xscale(range(0 350)) xlabel(0(45)320) graphregion(color(white)) legend(label(1 "95% CI") label(2 "Hazard ratio")) title("Social Jetlag-level risk for Breast Cancer") xtitle("Mean social jetlag (minutes)") ytitle("Hazard Ratio (95%CI)"))


***3.forest plot with sequential adjustment of HR***
// PSD 
qui import excel using "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\graphs\FP_modelling_psd.xlsx", firstrow clear
* declare effect sizes and standard errors *
qui meta set RR SE, studylabel(model) 
* meta forestplot with subgroups *
meta summarize, subgroup(cat)
meta forestplot _id _plot _esci _weight, cibind(brackets)
* fine tune * 
meta forestplot _id cases total _plot _esci, cibind(brackets) subgroup(cat) markeropts(mcolor(black) msymbol(square)) columnopts(_id, title("BREAST CANCER INCIDENCE")) columnopts(_esci, supertitle("") title("HR [95%CI]")) xtitle("Hazard Ratio [95% CI]", margin(medium)) xscale(log range(0.6 1.4)) xlabel(0.6(0.2)1.4, format(%8.1f)) noohetstats noohomtest noosigtest nonotes nogwhomtests nogbhomtests nogmarkers xline(1, lcolor(black))

graph export FP_modelling_PSD.png, width(4000) replace
///further design adjustment in graph editor  

// Social Jetlag sequential adjustment
qui import excel using "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\graphs\FP_modelling_sj.xlsx", firstrow clear
* declare effect sizes and standard errors *
qui meta set RR SE, studylabel(model) 
* meta forestplot with subgroups *
meta summarize, subgroup(cat)
meta forestplot _id _plot _esci _weight, cibind(brackets)
* fine tune * 
meta forestplot _id cases total _plot _esci, cibind(brackets) subgroup(cat) markeropts(mcolor(black) msymbol(square)) columnopts(_id, title("BREAST CANCER INCIDENCE")) columnopts(_esci, supertitle("") title("HR [95%CI]")) xtitle("Hazard Ratio [95% CI]", margin(medium)) xscale(log range(0.6 1.4)) xlabel(0.6(0.2)1.4, format(%8.1f)) noohetstats noohomtest noosigtest nonotes nogwhomtests nogbhomtests nogmarkers xline(1, lcolor(black))


// Social Jetlag plot with subgroup BMI
import excel "J:\analysis\results\graphs\FP_modelling_SJ_subgroupBMI.xlsx", firstrow clear
* declare effect sizes and standard errors *
qui meta set RR FSE, studylabel(model) 
* meta forestplot with subgroups *
meta summarize, subgroup(subcat)
meta forestplot _id _plot _esci _weight, cibind(brackets)
* fine tune * 
meta forestplot _id _plot _esci, cibind(brackets) subgroup(subcat) markeropts(mcolor(black) msymbol(square)) columnopts(_id, title("BREAST CANCER INCIDENCE")) columnopts(_esci, supertitle("") title("HR [95%CI]")) columnopts(_weight, supertitle("") title("Weight (%)")) xtitle("Hazard Ratio [95% CI]", margin(medium)) xscale(log range(0.6 1.4)) xlabel(0.6(0.2)1.4, format(%8.1f))


*** Sensitivity analysis: complete case analysis, forestplot with FARs ***
use "J:\analysis\complete_case_analysis.dta", clear
// PSD 
stcox ib1.psd_cat // crude, Model 1
fvfar, floatvar(psd_cat) nofreq	
stcox ib1.psd_cat i.fam_hist i.ethnic // Model 2
fvfar, floatvar(psd_cat) nofreq	
stcox ib1.psd_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT // Model 3
fvfar, floatvar(psd_cat) nofreq	
stcox ib1.psd_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) // Model 4
fvfar, floatvar(psd_cat) nofreq	
// Social jetlag
stcox ib0.sleepdiff_cat //crude, Model 1
fvfar, floatvar(sleepdiff_cat) nofreq	
stcox ib0.sleepdiff_cat i.ethnic i.fam_hist // Model 2
fvfar, floatvar(sleepdiff_cat) nofreq	
lrtest A B // (only family hist) improves fit!
stcox ib0.sleepdiff_cat i.ethnic i.fam_hist i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT // Model 3
fvfar, floatvar(sleepdiff_cat) nofreq	
stcox ib0.sleepdiff_cat i.ethnic i.fam_hist i.age_menarche i.parity i.oralcontraception i.hormone_RT i.alcohol i.breast_screening_baseline, strata(BMI_2 age_5y region_more townsend_cat) // Model 4
fvfar, floatvar(sleepdiff_cat) nofreq