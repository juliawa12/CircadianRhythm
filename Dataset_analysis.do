**** DATA ANALYSIS ***
/// with imputed data
use "afterimputation.dta"

**1. descriptive
//BC per quartile
bysort psd_cat: tab BC_all

**2. simple association analyses

**3. survival analysis
mi stset exit_date, id(eid) failure(BC_all) origin(birthdate) enter(wearable_start) scale(365.25)
stsum

		| Time at risk       rate      subjects       
---------+------------------------------------------
   Total |  206,609.555     .00348         44703


***Cox regression***
**1.PSD
mi estimate, hr: stcox i.psd_cat // Model 1
mi test 1.psd_cat 2.psd_cat 3.psd_cat 4.psd_cat // overall p 
 // F=1.40, p=0.24 
mi estimate, hr: stcox i.psd_cat i.fam_hist i.ethnic // Model 2
mi test 1.ethnic 1.fam_hist // F=6.46, p=0.002 --> improves fit
mi test 1.psd_cat 2.psd_cat 3.psd_cat 4.psd_cat // overall p=0.25
mi estimate, hr: stcox i.psd_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) // Model 3
mi test 1.psd_cat 2.psd_cat 3.psd_cat 4.psd_cat // overall p=0.32

**2.SJ
mi estimate, hr: stcox i.sj_cat // Model 1 // cat 2 is significant!
mi test 1.sj_cat 2.sj_cat 3.sj_cat 4.sj_cat //  F=2.56, overall p=0.05
mi estimate, hr: stcox i.sj_cat i.fam_hist i.ethnic // Model 2
mi test 1.ethnic 1.fam_hist // F=6.52, p=0.002 --> improves fit
mi test 1.sj_cat 2.sj_cat 3.sj_cat 4.sj_cat // overall p=0.05
mi estimate, hr: stcox i.sj_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) // Model 3
// in all models, the results are very robust. Category 2 shows a significant risk increase with higher jetlag!
mi test 1.sj_cat 2.sj_cat 3.sj_cat 4.sj_cat // overall p=0.06
save "Dataset_analysis.dta", replace

***Interactions***

***Sensitivity analyses***
**1.Complete case analysis
use "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\Afterexclusion.dta"
misstable sum // need to remove those with missing data for covariables agemenarche, parity, menopause, alcohol, smoking, bmi, ethnicity, veg, townsend, breast screening, oralpill, hrt
drop if townsend==.| age_menarche==. | parity==. | alcohol==. | ethnic==. | breast_screening_baseline==. | bmi==. | smoking==. | oralpill==. | hrt==.|menopause==. // 7,500 obs. deleted. 37,206 remain.
drop psd_cat 
xtile psd_cat=psd,n(4) // generate new categories, since n has changed
tab psd_cat //9302, 9301, 9302, 9301 in PSD quartiles
stset exit_date, id(eid) failure(BC_all) origin(birthdate) enter(wearable_start) scale(365.25)
stsum // 171,819.54 time at risk, incidence rate 0.0035211
// Cox regression PSD
stcox i.psd_cat //crude, HR 4: 0.92 not significant
stcox i.psd_cat i.ethnic i.fam_hist // Model 2, HR 4:0.93 not sign.
/// overall p=0.5
stcox i.psd_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) // Model 3, HR 0.96 not sign.
/// overall p=0.7
// Cox regression SJ
stcox i.sj_cat // Model 1, cat 2 is significant!
stcox sj_cat // overall p=0.03
stcox i.sj_cat i.fam_hist i.ethnic // Model 2
stcox sj_cat i.fam_hist i.ethnic // overall p=0.03
stcox i.sj_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) 
stcox sj_cat i.fam_hist i.ethnic // overall p=0.03
stcox sj_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) //p=0.02
save "SA_completecase.dta", replace

**2.Reverse causality
use "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\Dataset_analysis.dta"
gen after2y=wearable_end + 730.5 // 2 years after wearable assessment
format after2y %d
gen after2y_BC=0
replace after2y_BC=1 if date_composite_outcome <= after2y 
// 306 P experienced BC within 2 y of follow up. 
drop if after2y_BC==1 // 306 obs deleted. 44,400 remain.
drop psd_cat 
xtile psd_cat=psd,n(4) // generate new categories, since n has changed
save "SA_reversecausality.dta", replace
// Cox regression PSD
mi estimate, hr: stcox i.psd_cat //HR 4: 0.90, not sign.
mi test 1.psd_cat 2.psd_cat 3.psd_cat 4.psd_cat // overall p=0.2
mi estimate, hr: stcox i.psd_cat i.fam_hist i.ethnic // Model 2
mi test 1.ethnic 1.fam_hist // F=6.46, p=0.002 --> improves fit
mi test 1.psd_cat 2.psd_cat 3.psd_cat 4.psd_cat // overall p=0.2
mi estimate, hr: stcox i.psd_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) // Model 3
mi test 1.psd_cat 2.psd_cat 3.psd_cat 4.psd_cat // overall p=0.2
// Cox regression SJ
mi estimate, hr: stcox i.sj_cat // HR3 1.69, p=0.01
mi test 1.sj_cat 2.sj_cat 3.sj_cat 4.sj_cat // overall p=0.01
mi estimate, hr: stcox i.sj_cat i.fam_hist i.ethnic // Model 2
mi test 1.ethnic 1.fam_hist // F=6.52, p=0.002 
mi test 1.sj_cat 2.sj_cat 3.sj_cat 4.sj_cat // overall p=0.01
mi estimate, hr: stcox i.sj_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) // Model 3
// in all models, the results are very robust. Category 2 shows a significant risk increase with higher jetlag!
mi test 1.sj_cat 2.sj_cat 3.sj_cat 4.sj_cat

**3.m10l5
use "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\Dataset_analysis.dta"
// drop IDs with missing values for this exposure
destring m10l5
drop if m10l5==. // 37 obs deleted. 44,669 remain.
// generate categories and run cox regression
xtile m10l5_cat=m10l5, n(4)
mi estimate, hr: stcox i.m10l5_cat // crude Model 1, 4: 0.77, p=0.02
mi test 1.m10l5_cat 2.m10l5_cat 3.m10l5_cat 4.m10l5_cat  // overall p=0.11
mi estimate, hr: stcox i.m10l5_cat i.fam_hist i.ethnic // Model 2, same
mi test 1.m10l5_cat 2.m10l5_cat 3.m10l5_cat 4.m10l5_cat // overall p=0.11
mi estimate, hr: stcox i.m10l5_cat i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) // Model 4 HR=0.79, p=0.04!
mi test 1.m10l5_cat 2.m10l5_cat 3.m10l5_cat 4.m10l5_cat // overall p=0.2

save "SA_m10l5.dta", replace


**** EXPLORATORY: try out new categories for social jetlag
//A
xtile sj_cat_q=sj,n(4) // in quarters
//B
gen sj_cat_3=sj
replace sj_cat_3=1 if sj<30
replace sj_cat_3=2 if sj>=30 & sj<=90
replace sj_cat_3=3 if sj>90 // only 3 groups to avoid minuscule 4th group
label var sj_cat_3 "social jetlag in 3 groups"
label define sjcat3 1 "<0.5h" 2 "0.5-1.5h" 3">1.5"
label values sj_cat_3 sjcat3
save "analysis_new_sj_cat", replace
tab sj_cat_q
tab sj_cat_3
//C
gen sj_catnew=sj
replace sj_catnew=1 if sj<60
replace sj_catnew=2 if sj>=60 & sj<=120
replace sj_catnew=3 if sj>120 // new 3 groups based on literature
label var sj_catnew "social jetlag in 3 new groups"
label define sjcatnew 1 "<1h" 2 "1-2h" 3">2h"
label values sj_catnew sjcat3new
tab sj_catnew
//D use median as cut off
sum sj, detail // median 34.5
gen sj_median=sj
replace sj_median=1 if sj<34.5
replace sj_median=2 if sj>=34.5
/// Cox analysis
**1.with SJ in quarters
mi estimate, hr: stcox i.sj_cat_q // Model 1, not significant
mi test 1.sj_cat_q 2.sj_cat_q 3.sj_cat_q 4.sj_cat_q // overall p=0.35
mi estimate, hr: stcox i.sj_cat_q i.fam_hist i.ethnic // Model 2
mi estimate, hr: stcox i.sj_cat_q i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) // Model 3
mi test 1.sj_cat_q 2.sj_cat_q 3.sj_cat_q 4.sj_cat_q // overall p=0.31
**2.with SJ in 3 groups
mi estimate, hr: stcox i.sj_cat_3 // Model 1, group 3 HR 1.34, p=0.01
mi test 1.sj_cat_3 2.sj_cat_3 3.sj_cat_3 // overall p=0.04
mi estimate, hr: stcox i.sj_cat_3 i.fam_hist i.ethnic // Model 2
mi estimate, hr: stcox i.sj_cat_3 i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) // Model 3
mi test 1.sj_cat_3 2.sj_cat_3 3.sj_cat_3 // overall p=0.04
**3. with 3 new groups
mi estimate, hr: stcox i.sj_catnew //last group significant
mi estimate, hr: stcox i.sj_catnew i.fam_hist i.ethnic
mi estimate, hr: stcox i.sj_catnew i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) // 3 HR 1.49, p=0.01
**4. with median cut off, 2 groups
mi estimate, hr: stcox i.sj_median //NS
mi estimate, hr: stcox i.sj_median i.fam_hist i.ethnic
mi estimate, hr: stcox i.sj_median i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) //NS

/// Sensitivity analyses with new categories
***A. Complete Case Analysis
use "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\SA_completecase.dta", clear
**1.SJQ
xtile sj_cat_q=sj,n(4)
stcox i.sj_cat_q // not significant (NS)
stcox sj_cat_q // overall p=0.09
stcox i.sj_cat_q i.fam_hist i.ethnic 
stcox i.sj_cat_q i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) //NS
stcox sj_cat_q i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) // overall p=0.07
**2.SJ3
gen sj_cat_3=sj
replace sj_cat_3=1 if sj<30
replace sj_cat_3=2 if sj>=30 & sj<=90
replace sj_cat_3=3 if sj>90
stcox i.sj_cat_3 // group 3 HR 1.39
stcox sj_cat_3 // overall p=0.02
stcox i.sj_cat_3 i.fam_hist i.ethnic 
stcox i.sj_cat_3 i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) 
stcox sj_cat_3 i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) // overall p=0.02
***B. Reverse causality
use "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\analysis_new_sj_cat", clear
**1.SJQ
gen after2y=wearable_end + 730.5 // 2 years after wearable assessment
format after2y %d
gen after2y_BC=0
replace after2y_BC=1 if date_composite_outcome <= after2y 
// 306 P experienced BC within 2 y of follow up. 
drop if after2y_BC==1 // 306 obs deleted. 44,400 remain.
drop sj_cat_q 
xtile sj_cat_q=sj,n(4) // since distribution changed, need to redo quarters
tab sj_cat_q
mi estimate, hr: stcox i.sj_cat_q // Group 3&4 significant!
mi test 1.sj_cat_q 2.sj_cat_q 3.sj_cat_q 4.sj_cat_q // overall p=0.08
mi estimate, hr: stcox i.sj_cat_q i.fam_hist i.ethnic 
mi estimate, hr: stcox i.sj_cat_q i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) 
mi test 1.sj_cat_q 2.sj_cat_q 3.sj_cat_q 4.sj_cat_q // overall p=0.1
**2.SJ3
mi estimate, hr: stcox i.sj_cat_3 // group 3 HR 1.62, p=0.001
mi test 1.sj_cat_3 2.sj_cat_3 3.sj_cat_3 // overall p<0.01
mi estimate, hr: stcox i.sj_cat_3 i.fam_hist i.ethnic 
mi estimate, hr: stcox i.sj_cat_3 i.fam_hist i.ethnic i.age_menarche i.menopause i.parity i.oralcontraception i.hormone_RT i.smoking i.alcohol i.bmi_cat i.veg i.breast_screening_baseline, strata(age_5y region_more townsend_cat) 
mi test 1.sj_cat_3 2.sj_cat_3 3.sj_cat_3 // overall p=0.01

