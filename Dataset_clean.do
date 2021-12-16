**** Data cleaning ****
use covariables_new.dta // all baseline vars from UKB, downloaded centrally.

**1. order and prepare covariables / generate categories
// need to generate birthdate. Use mid of month (15) for day since this var is missing
gen birthday=15
gen birthdate=mdy(birth_month, birthday, birthyear)
format birthdate %d
** create categories for covariables
gen region=0
replace region=1 if assessment==11003 | assessment==110022 | assessment==11023 //Wales: Cardiff, Swansea, Wrexham
replace region=2 if assessment==11005 | assessment==11004 //Scotland: Edinburgh, Glasgow
label var region "region of assessment"
label define regionassess 0 "England" 1 "Wales" 2 "Scottland"
label values region regionassess
gen ethnic = 1
replace ethnic=0 if ethnicity==1 | ethnicity==1001 | ethnicity==1002 | ethnicity==1003
replace ethnic = . if ethnicity==.| ethnicity==-3 | ethnicity==-1
label var ethnic "ethnic background"
drop ethnicity
gen alc = alcohol
replace alc =. if alcohol==. | alcohol==-3
recode alc (4/6=0) (2/3=1) (1=2)
label var alc "alcohol intake frequency"
label define alcoholintake 0 "less than 3 times a month" 1 "1-4 times a week" 2 "daily or almost daily" 
label values alc alcoholintake
drop alcohol
rename alc alcohol
xtile townsend_cat=townsend, n(5)
gen bmi_cat =.
replace bmi_cat=0 if bmi<18.5
replace bmi_cat=1 if bmi>=18.5 & bmi<25
replace bmi_cat=2 if bmi>=25 & bmi<30
replace bmi_cat=3 if bmi>=30
replace bmi_cat=. if bmi==.
label var bmi_cat "bmicat"
label define bmicatlabel 0 "<18.5" 1 "18.5-24.9" 2 "25-29.9" 3 ">30"
label values bmi_cat bmicatlabel
gen BMI_2=.
replace BMI_2=0 if bmi<25
replace BMI_2=1 if bmi>=25
replace BMI_2=. if bmi==.
label var BMI_2 "BMI in 2 categories, split at 25"
gen oralcontraception=0
replace oralcontraception=1 if oralpill==1 | medication_pill==1
label var oralcontraception "ever or current use of contraceptive pill"
gen hormone_RT=0
replace hormone_RT=1 if hrt==1 | medication_hrt==1
label var hormone_RT "Ever or current hormone replacement therapy"
gen age_menarche=0
replace age_menarche=0 if agemenarche<12
replace age_menarche=1 if agemenarche==12 | agemenarche==13
replace age_menarche=2 if agemenarche>=14
replace age_menarche=. if agemenarche==.
label var age_menarche "age at menarche in categories"
label define menarchelabel 0 "<12" 1 "12-13" 2 ">=14" 
label values age_menarche menarchelabel
gen births=0
replace births=0 if numberbirth==0
replace births=1 if numberbirth==1 | numberbirth==2
replace births=2 if numberbirth>=3
replace births=. if numberbirth==.
label var births "number of live births in categories"
label define birthslabel 0 "nulliparous" 1 "1-2 births" 2 "3 or more"
label values births birthslabel
replace age_birth=0 if births==0
gen agebirth_cat=0
replace agebirth_cat=0 if age_birth==0 | births==0
replace agebirth_cat=1 if age_birth>0 & age_birth<25
replace agebirth_cat=2 if age_birth>=25
replace agebirth_cat=. if age_birth==. // many missing values!
label var agebirth_cat "age at first birth in categories"
label define ageatfirstbirth 0 "nulliparous" 1 "<=25" 2 ">25"
label values agebirth_cat ageatfirstbirth
recode reason_lost_followup (3/4=1) (5=2) 
label var reason_lost_followup "reason for lost to followup"
label define reasonslost 1 " left the UK" 2 "withdrawal" 
label values reason_lost_followup reasonslost
// specific for BC: cross-tabulate variable for births and age!
gen parity=0
replace parity=0 if births==0
replace parity=1 if births==1 & agebirth_cat==1
replace parity=2 if births==1 & births <=2 & agebirth_cat==2
replace parity=3 if births==2 & agebirth_cat==1
replace parity=4 if births==2 & agebirth_cat==2
replace parity=. if births==. | agebirth_cat==. 
label var parity "cross tab variable for number of births and age at first birth"
label define paritylabel 0 "nulliparous" 1 "1-2/<25" 2 "1-2/25+" 3 "3+/<25" 4 "3+/>25"
label values parity paritylabel
gen vegraw=.
replace vegraw=0 if rawveg==-10 | rawveg==0 | rawveg==1
replace vegraw=1 if rawveg==2
replace vegraw=2 if rawveg==3
replace vegraw=3 if rawveg>=4
label var vegraw "categories of raw vegetable intake per day"
gen vegcooked=.
replace vegcooked=0 if cookedveg==-10 | rawveg==0 | rawveg==1
replace vegcooked=1 if cookedveg==2
replace vegcooked=2 if cookedveg==3
replace vegcooked=3 if cookedveg>=4
label var vegcooked "categories of cooked vegetable intake per day"
// create vegetable intake variable: raw or cooked
gen veg=.
replace veg=0 if vegraw==0 & vegcooked==0
replace veg=1 if vegraw==1 | vegcooked==1
replace veg=2 if vegraw==2 | vegcooked==2
replace veg=3 if vegraw==3 | vegcooked==3
replace veg=. if vegraw==. & vegcooked==.
label var veg "servings of total vegetable intake cooked/raw"
// replace values for "do not know" and "prefer not to say" to missing "."
replace oralpill=. if oralpill==-3 | oralpill==-1
replace hrt=. if hrt==-3 | hrt==-1
replace breast_screening_baseline=. if breast_screening_baseline==-3 | breast_screening_baseline==-1
replace agemenarche=. if agemenarche==-3 | agemenarche==-1
replace numberbirth=. if numberbirth==-3
replace smoking=. if smoking==-3
replace rawveg=. if rawveg==-3 | rawveg==-1
replace cookedveg=. if cookedveg==-3 | cookedveg==-1
replace age_birth=. if age_birth==-3 | age_birth==-4
replace country_birth=. if country_birth==-1 | country_birth==-3
replace nightshift=. if nightshift==-1 | nightshift==-3
save "Covariables_final.dta"

**2. clean death dataset**
use "K:\MSc Placements\2021\JuliaW\JuliaSept\Placement analyses\analysis\outcome\death.dta"
merge n:n eid using "K:\MSc Placements\2021\JuliaW\JuliaSept\Placement analyses\analysis\outcome\death_cause.dta"
keep eid date_of_death cause_icd10
unique eid // 35,033 unique entries for 86,725 obs. Delete duplicates
// flag C50 as first diagnosis
gen cause = 1 if substr(cause_icd10,1,3)== "C50" 
replace cause = 0 if cause!=1
tab cause // 1,580 BC deaths
unique eid if cause==1 //1,579 unique entries
duplicates drop eid if cause==0, force // 51,004 obs deleted
unique eid if cause==1
sort eid
quiet by eid: gen dup = cond(_N==1,0,_n)
tab dup // max. 3 duplicates per ID
drop if dup==1 & cause==0 // 347 observations deleted
drop if dup==2 & cause==0 // 340 obs deleted
drop if dup==3 & cause==0 // only 1 duplicate remaining.
duplicates list eid // inspect eid 5817508. Two C50 entries. Delete one.
duplicates drop eid, force
drop dup
rename cause_icd10 death_icd10
rename cause BC_death
save "death_final.dta"

**3. Merge datasets**
// use covariables set
use "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\covariables.dta"
// +accelerometer subsample
merge 1:n eid using "K:\MSc Placements\2021\JuliaW\JuliaSept\Placement analyses\analysis\exposure\exposure_new.dta"
keep if _merge==3
drop _merge
// +death outcome
merge 1:n eid using "death_final.dta"
drop if _merge==2
drop _merge
// +cancer registries outcome
merge 1:n eid using "Cancerregistry_final.dta"
drop if _merge==2
drop _merge
save "Dataset_clean.dta"

***4. APPLY exclusion criteria ***
use "Dataset_clean.dta"//103,658 participants
** 1. exclude male participants
drop if sex==1 //45,385 observations deleted. 58,273 remaining.
** 2. accelerometer QC
// make sure all participants have accelerometer data 
tab accoverallavg if accoverallavg==. // no missing data
drop if accoverallavg==0 // 2 obs deleted
// remove participants whose data could not be calibrated 
drop if qualitygoodcalibration==0 // 3 obs deleted
// remove participants with >1% of values clipped before/after calibration 
gen manyclipsafter= clipsaftercalibration/totalreads>0.01
gen manyclipsbefore= clipsbeforecalibration/totalreads>0.01
drop if clipsaftercalibration/totalreads>0.01 // 1 obs deleted
drop if clipsbeforecalibration/totalreads>0.01 // 2 obs deleted
// remove participants with unrealistically high acc values 
drop if accoverallavg >=100 // 12 obs deleted
// remove participants with poor wear time 
drop if qualitygoodweartime==0 // 3,865 obs deleted 
/// after QC, 54,388 participants remain.
** 3. exclude those with prior disease (cancer)
gen prevalent_9=0
replace prevalent_9=1 if anycancer_date < fileendtime & anycancer_9!=.
tab prevalent_9 //1,116 prevalent ICD9 cancers (all ICD9 diagnoses)
// For anycancer10, first create binary cancer variable
gen cancer_icd10=0
replace cancer_icd10=1 if substr(anycancer_10, 1, 1) == "C" & substr(anycancer_10, 1, 3) != "C44"
replace cancer_icd10=1 if substr(anycancer_10, 1, 3) >= "D00" & substr(anycancer_10, 1, 3) <= "D09"
gen prevalent_10=0
replace prevalent_10=1 if anycancer_date < fileendtime & cancer_icd10==1
tab prevalent_10
// drop all prevalent cancers
drop if prevalent_9==1 // 1,116 obs deleted. 53,272 remain.
drop if prevalent_10==1 // 5,219 obs deleted. 48,053 remain.
// drop all self-reported cancers
drop if cancer_breast_sr==1 // 127 deleted 
drop if cancer_any_sr==1 // 1,498 deleted 
drop if cancerdiag==1 // 203 deleted. 46,225 remain.
** 5. drop those with night shift work (usually, always)
drop if nightshift==3 | nightshift==4 // 531 deleted. 45,694 remain.
** 4. drop those with missing exposure data
//a. no missing data for PSD value.
//b. import clean sleep midpoint variable
merge 1:n eid using "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\average_sleepmidpoints.dta"
keep if _merge==3
drop _merge
// apply exclusion criteria: only keep P with values for at least 1 weekday AND 1 weekend day. Consider daylight savings and bank holidays. These cleanings were made in the processing of the average sleep midpoints through the cluster. Participants that do not meet these criteria, are flagged with value 0 in the dataset. Therefore, remove all with 
gen missing_midpoint=0
replace missing_midpoint=1 if weekday==0 | weekend==0
drop if missing_midpoint==1 // 988 obs deleted. 44,706 participants in final sample.
drop missing_midpoint
save "Afterexclusion.dta",replace

merge 1:n eid using "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\outcome\Cancer registry\cancerregistry_source.dta"
drop if _merge==2
drop _merge
rename v2 cancer_source

// drop variables that are not needed for better overview
drop qualitygoodcalibration qualitygoodweartime totalreads clipsbeforecalibration clipsaftercalibration fourierfrequency accoverallavg metoverallavg qualification cancer_breast_sr cancer_any_sr medication_pill medication_hrt diet_carotene diet_fat edu0 edu1 edu2 edu3 edu4 edu5 medic0 medic1 medic2 medic3 cancer_sr0 cancer_sr1 cancer_sr2 cancer_sr3 cancer_sr4 cancer_sr5 illness_mother0 illness_mother1 illness_mother2 illness_mother3 illness_mother4 illness_mother5 illness_mother6 illness_mother7 illness_mother8 illness_mother9 illness_mother10 cancerdiag chronotype getupmorning sleepduration agefulledu shiftwork totalincome sleeptueavg sleepwedavg sleepthuravg sleepsatavg sleepsunavg prevalent_9 prevalent_10

***FINAL DATASET CLEANING / PREPARE FOR ANALYSIS***

**1. Exposure / Accelerometer
// wear start and wear end need to be in date format
gen wearable_start=date(filestarttime, "YMD###")
format wearable_start %td
gen wearable_end=date(fileendtime, "YMD###")
format wearable_end %td
// PSD categories
xtile psd_cat=psd, n(4)
// Social Jetlag
gen socialjetlag=weekend_minus_weekday_diff_sec / 60 // SJ in minutes
/// values for SJ are partly negative. This is when a participant's midpoint during the week is later than the on one the weekend. Positive values are for the case when the weekend midpoint is later then during the week. However, since we are only interested in a shift of midpoint regardless of direction. Therefore, we just want the pure difference, without signs/negative values. 
gen sj=socialjetlag
replace sj=abs(sj) // 13,177 real changes made. Left are only positive values
// SJ categories in <0.5h, 0.5-<1.5h, 1.5-<3h, >=3h
gen sj_cat=0
replace sj_cat=1 if sj<30
replace sj_cat=2 if sj>=30 & sj<90
replace sj_cat=3 if sj>=90 & sj<180
replace sj_cat=4 if sj>=180
label var sj_cat "social jetlag in categories"
label define diff 1 "<0.5h" 2 "0.5-<1.5h" 3 "1.5-<3h" 4 ">=3h" 
label values sj_cat diff

**Prepare data for survival function, use age-at-risk as time variable, CR BC date and BC death date as failure variable. Censoring if lost to follow up, death, anycancer or end of follow up 31.07.2019 (31.10.2015 for Scotland).**
// create composite BC endpoint if person died or cancer registry
*1.) Cancer registry or mortality from BC - outcome
gen BC_CR=substr(BC_ICD10, 1,3)=="C50"
gen BC_all=0
replace BC_all=1 if BC_death==1 | BC_CR==1 //725 outcomes
label var BC_all "breast cancer combined CR & deaths"
//create earliest outcome date
gen date_BCdeath = date(date_of_death, "DMY") if BC_death==1
format date_BCdeath %td
gen date_BCdiag =date(BC_date, "YMD")
format date_BCdiag %td
egen date_composite_outcome = rowmin(date_BCdiag date_BCdeath)
format date_composite_outcome %d //725 outcomes
*2.) Lost to follow up if outcome did not occur
gen date_lostfollow = date(date_lost_followup, "YMD")
format date_lostfollow %td //4 lost to follow up
*3.) Any other cancer
gen cancerdiag=date(anycancer_date, "YMD")
format cancerdiag %td
*4.) Any other death (except BC death)
gen date_death = date(date_of_death, "DMY")
format date_death %td
replace date_death=. if BC_death==1 //736 other deaths
*5.) End of follow-up due to last update of cancer registries
gen date_endstudy=.
replace date_endstudy = mdy(07,31,2019)
replace date_endstudy = mdy(10,31,2015) if cancer_source=="SCOT" //120 obs
format date_endstudy %td
*6.) generate exit date with earlierst date of outcome, anycancer, death, lost to follow up, end of study
gen exit_date=.
replace exit_date=min(date_composite_outcome, cancerdiag, date_lostfollow, date_death, date_endstudy)
format exit_date %d
 
// for survival analysis age at risk, creat agein and ageout var
gen agein= (wearable_start - birthdate) / 365.25
format agein %5.0g
label var agein "age at accelerometer assessment"
sum agein, detail // median 62.3 years
// create age at exit (censoring or outcome date)
gen ageout= (exit_date - birthdate) / 365.25
format ageout %5.0g 
label var ageout "age at censoring"
// create variabel for follow up time
gen followup_time=(exit_date - wearable_end) / 365.25
format followup_time %5.0g
// create menopause var with age for those with missing values
replace menopause=1 if agein>=53
// gen age 5 year groups (for later - stratification)
gen age_5y=agein
format age_5y %4.0g
recode age_5y (43/49.999999=0) (50/54.999999=1) (55/59.999999=2) (60/64.999999=3) (65/69.999999=4) (70/74.999999=5) (75/79.999999=6)
tab age_5y // first and last group quite small. Collapse 
replace age_5y=1 if age_5y==0
replace age_5y=5 if age_5y==6
label var age_5y "age groups of 5 years"
label define 5year 1"<55" 2"55-<60" 3"60-<65" 4"65-70" 5">70"
label values age_5y 5year

save "Afterexclusion.dta", replace // dataset ready for analysis

misstable summarize 
// highest percentage of missing data: age at first birth 13%, all other vars <3%

// Descriptive summaries for final sample 
sum agein, detail
bysort psd_cat: sum agein, detail
anova agein psd_cat
tab region
bysort psd_cat: tab region
tab psd_cat region, chi2
tab ethnic
bysort psd_cat: tab ethnic
tab psd_cat ethnic, chi2
tab fam_hist
bysort psd_cat: tab fam_hist
tab psd_cat fam_hist, chi2
tab menopause
bysort psd_cat: tab menopause
tab psd_cat menopause, chi2
sum bmi, detail
bysort psd_cat: sum bmi, detail
anova bmi psd_cat
sum townsend, detail
bysort psd_cat: sum townsend, detail
anova townsend psd_cat
sum agemenarche, detail
bysort psd_cat: sum agemenarche, detail
anova agemenarche psd_cat
tab psd_cat age_menarche,chi2
regress psd agemenarche // all 3 tests give low p value
sum age_birth if age_birth!=0, detail
bysort psd_cat: sum age_birth if age_birth!=0, detail
anova age_birth psd_cat
sum numberbirth, detail
bysort psd_cat: sum numberbirth, detail
anova numberbirth psd_cat // strange. significant p.
tab breast_screening_baseline
bysort psd_cat: tab breast_screening_baseline
tab psd_cat breast_screening_baseline, chi2
tab oralcontraception
bysort psd_cat: tab oralcontraception
tab psd_cat oralcontraception, chi2
tab hormone_RT
bysort psd_cat: tab hormone_RT
tab psd_cat hormone_RT, chi2
tab alcohol 
bysort psd_cat: tab alcohol
tab psd_cat alcohol, chi2
tab smoking
bysort psd_cat: tab smoking
tab psd_cat smoking, chi2
tab veg
bysort psd_cat: tab veg
tab psd_cat veg, chi2
sum followup_time, detail
bysort psd_cat: sum followup_time, detail
anova followup_time psd_cat
tab BC_all
bysort psd_cat: tab BC_all
tab psd_cat BC_all, chi2
sum accoverallavg, detail
bysort psd_cat: sum accoverallavg, detail
anova accoverallavg psd_cat
sum psd, detail
bysort psd_cat: sum psd, detail
anova psd psd_cat
sum sj, detail
bysort psd_cat: sum sj, detail
destring m10l5, replace
sum m10l5, detail
bysort psd_cat: sum m10l5, detail
anova m10l5 psd_cat


***IMPUTATION***
*1. check if there are patterns of missingness
misstable patterns age_birth age_menarche townsend, frequency
*2. inspect if MCAR or MAR
//recode 
recode parity(.=1) (nonmiss=0), generate(miss_par)
recode age_menarche (.=1) (nonmiss=0), generate(miss_menarche)
recode townsend(.=1) (nonmiss=0), generate(miss_town)
recode bmi(.=1) (nonmiss=0), generate(miss_bmi)
recode smoking(.=1) (nonmiss=0), generate(miss_smoking)
recode breast_screening_baseline(.=1) (nonmiss=0), generate(miss_breast) 
recode ethnic(.=1) (nonmiss=0), generate(miss_ethnic)
recode alcohol(.=1) (nonmiss=0), generate(miss_alcohol)
recode menopause(.=1) (nonmiss=0), generate(miss_meno) 
recode veg(.=1) (nonmiss=0), generate(miss_veg)
// use regression to investigate dependency
logistic miss_menarche agein townsend // p not sign., missing age at menarche is not dependent on other var! MCAR/MAR
logistic miss_smoking agein // not sign
logistic miss_ethnic agein // not sign
logistic miss_alcohol agein // not sign
logistic miss_breast agein // P sign
logistic miss_town agein // p sign
logistic miss_bmi agein // p sign
logistic miss_veg agein // p sign
logistic miss_meno agein // p sign
logistic miss_par agein townsend // p sign. --> the odds of having missing data on age at first + birth is higher for each 1 unit increase in townsend deprivation index and age(p<0.001) --> missing data in parity is DEPENDENT on known data , values are either MAR or NMAR; they are not MCAR, therefore simple methods of imputing missing data are not appropriate. Thus, multiple imputation is the most effective way of imputing the missing data. 
// drop miss_var, don't need them anymore
drop miss_par miss_menarche miss_alcohol miss_bmi miss_breast miss_ethnic miss_meno miss_smoking miss_town miss_veg miss_breast miss_veg
// because of problem with MI bmi_cat (can't be solved), this variable will be imputed via simple regression
 
*3. use MICE
// for parity, townsend, menopause, veg, breast cancer screening
mi set wide 
mi register imputed parity veg townsend_cat breast_screening_baseline menopause
mi register regular eid sex birthyear dateassessment townsend cookedveg rawveg overallhealth numberbirth oralpill hrt nightshift smoking bmi age_at_recruitment fam_hist reason_lost_followup date_lost_followup country_birth age_birth breast_screening birth_month menopause assessmentcenter birthday birthdate region region_more ethnic alcohol bmi_cat oralcontraception hormone_RT age_menarche births agebirth_cat vegraw vegcooked filestarttime fileendtime psd m10l5 sleepoverallavg sleepweekdayavg sleepweekendavg date_of_death death_icd10 BC_death anycancer_date anycancer_10 anycancer_9 BC_date BC_ICD10 cancer_icd10 manyclipsafter manyclipsbefore weekend weekday mean_weekend_midpoint mean_weekday_midpoint weekend_minus_weekday_diff_sec cancer_source wearable_start wearable_end psd_cat socialjetlag sj sj_cat BC_CR BC_all date_BCdeath date_BCdiag date_composite_outcome date_lostfollow cancerdiag date_death date_endstudy exit_date agein ageout followup_time age_5y BMI_2
mi describe
mi stset, clear

mi impute chained (ologit) parity (ologit) townsend_cat (logit) veg (logit) breast_screening_baseline (logit) menopause = agein, add(5) rseed(10) dryrun
mi impute chained (ologit) parity (ologit) townsend_cat (logit) veg (logit) breast_screening_baseline (logit) menopause = agein, add(5) rseed(10) augment

// inspection of data
mi xeq: codebook parity //no missing values
mi xeq: codebook veg //no missing values
mi xeq: codebook menopause //no missing values
mi xeq: codebook townsend_cat //no missing values
mi xeq: codebook breast_screening_baseline //no missing values

*4. use single imputation 
// for agemenarche, smoking, alcohol, ethnic, bmi
// fit regression models and get predicted values
ologit age_menarche agein region // categorical variable
predict am0 am1 am2
egen agem_highest=rowmax(am0 am1 am2) 
replace agem_highest=1 if agem_highest==am1  // all am1 = category 1
gen agemenarche=age_menarche
replace agemenarche=1 if age_menarche==.
label var agemenarche "age at menarche"
label define agemenarche 0 "<12" 1 "12-13" 2">=14" 
label values agemenarche agemenarche
ologit smoking agein region // categorical dep var. 
predict s0 s1 s2 // need specify 1 var for each smoking category. gives out probabilities for each category.
egen smoke_highest=rowmax(s0 s1 s2) // highest probability
replace smoke_highest=0 if smoke_highest==s0 // all 0
gen smoking_impute=smoking
replace smoking_impute=0 if smoking==.
ologit alcohol agein region 
predict a0 a1 a2 
egen alc_highest=rowmax(a0 a1 a2)
replace alc_highest=0 if alc_highest==a0
replace alc_highest=1 if alc_highest==a1 // all 1
replace alc_highest=2 if alc_highest==a2
gen alcohol_impute=alcohol
replace alcohol_impute=1 if alcohol==.
logit ethnic agein region // binary var
predict pred_e
replace pred_e=0 if pred_e<0.5 //  all 0
gen ethnic_impute=ethnic
replace ethnic_impute=0 if ethnic==.
ologit bmi_cat agein region 
predict b0 b1 b2 b3 
egen bmicat_impute=rowmax(b0 b1 b2 b3)
replace bmicat_impute=0 if bmicat_impute==b0
replace bmicat_impute=1 if bmicat_impute==b1 // all 1
replace bmicat_impute=2 if bmicat_impute==b2
replace bmicat_impute=3 if bmicat_impute==b3
gen bmicat1 = bmi_cat
replace bmicat1=1 if bmi_cat==.
logit BMI_2 agein region
predict pred_B
replace pred_B=0 if pred_B<0.5
replace pred_B=1 if pred_B>0.5
gen bmicat2=BMI_2
replace bmicat2=pred_B if BMI_2==.
//addition: gen new alc var for interaction term needed later
gen alc_2=.
replace alc_2=0 if alcohol_impute==0
replace alc_2=1 if alcohol_impute==1 | alcohol==2
label var alc_2 "alcohol in 2 categories, less or more than 1 drink weekly"
// rename & drop to only have the imputed variable (to not get confused)
drop age_menarche
rename agemenarche age_menarche
drop smoking
rename smoking_impute smoking
drop alcohol
rename alcohol_impute alcohol
drop ethnic
rename ethnic_impute ethnic
drop bmi_cat BMI_2
rename bmicat1 bmi_cat
rename bmicat2 BMI_2
drop am0 am1 am2 agem_highest s0 s1 s2 smoke_highest a0 a1 a2 alc_highest  pred_e pred_B b0 b1 b2 b3 bmicat_impute 
save "afterimputation.dta", replace








