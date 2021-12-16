**** NEW Cancer Registry data cleaning ****

**First orrder variables. For some reason, they are not in the right order**
order eid
order v36, last
order v47 v23 v35 v13 v2 v41 v50 v14 v24 v22 v49 v37 v32 v12 v34 v1 v20, after(eid) //dates
order v26 v3 v45 v9 v10 v16 v28 v17 v44 v27 v25 v7 v19 v15 v39 v5 v11, after(v20) //icd-10
order v4 v33 v18 v43 v29 v6 v42 v31 v46 v48 v38 v40 v8 v30 v36, after(v11) //icd-9
**2. rename variables for better overview**
rename (v47 v23 v35 v13 v2 v41 v50 v14 v24 v22 v49 v37 v32 v12 v34 v1 v20) ( cancer_date0 cancer_date1 cancer_date2 cancer_date3 cancer_date4 cancer_date5 cancer_date6 cancer_date7 cancer_date8 cancer_date9 cancer_date10 cancer_date11 cancer_date12 cancer_date13 cancer_date14 cancer_date15 cancer_date16)
rename (v26 v3 v45 v9 v10 v16 v28 v17 v44 v27 v25 v7 v19 v15 v39 v5 v11) (cancer_10_0 cancer_10_1 cancer_10_2 cancer_10_3 cancer_10_4 cancer_10_5 cancer_10_6 cancer_10_7 cancer_10_8 cancer_10_9 cancer_10_10 cancer_10_11 cancer_10_12 cancer_10_13 cancer_10_14 cancer_10_15 cancer_10_16)
rename (v4 v33 v18 v43 v29 v6 v42 v31 v46 v48 v38 v40 v8 v30 v36) (cancer_9_0 cancer_9_1 cancer_9_2 cancer_9_3 cancer_9_4 cancer_9_5 cancer_9_6 cancer_9_7 cancer_9_8 cancer_9_9 cancer_9_10 cancer_9_11 cancer_9_12 cancer_9_13 cancer_9_14)
save cancer_register_new.dta, replace
merge 1:n eid using "cancerregistry_source.dta" // need source for censoring date
drop _merge 
***Clean Cancer Registry Data***

**A. flag breast cancer**
sum cancer_9_* // instances 0-8, 10-12, 14 contain data
// after tab command for cancer_10: instances 0-11, 13, 15, 16 contain data
// generate var to flag Breast cancer cases from ICD9 and ICD10
// ICD-9 code for breast cancer: 174 (0-9)
gen BC9=0
forval i=0/14{
replace BC9=1 if cancer_9_`i' >= 1740 & cancer_9_`i' <= 1749
}
// ICD-10 code for breast cancer: C50 (0-9)
gen BC10=0
forval i=0/11{
replace BC10=1 if substr(cancer_10_`i',1,3)=="C50"
}	// for instances 0-11
replace BC10=1 if substr(cancer_10_13,1,3)=="C50" 
// for instance 13
forval i=15/16 {
replace BC10=1 if substr(cancer_10_`i',1,3)=="C50"
}  // for instances 15,16

tab BC9 // 1,766 ICD-9 BC diagnoses
tab BC10 // 17,527 ICD-10 BC diagnoses
tab BC10 if BC9==1 // 863 BC diagnoses with both ICD9 and ICD10 classification

**B. flag any cancer for exclusion criteria / censoring**
**1. Define malignant and benign neoplasms reported as ICD9 and ICD10 (prevalent and incident)**
	*ICD 9
	**Malignant and benign neoplasms reported as ICD9 neoplasms go from 140-239:
	* 1: ICD 9 from 140 (Malignant neoplasm of lip) to 209 (Neuroendocrine tumors)
	* 2: ICD 9 230-234: Carcinoma in situ
	* 3: ICD 9 from 210 to 229: Benign neoplasms
	* 4: ICD 9 = 173 Non melanoma skin or NSB
	* http://www.icd9data.com/2012/Volume1/140-239/179-189/185/185.htm 
	// only exclude prevalent group 1 & 2.
	* comands: 
		*substr: string variable; the position of the start of the substring; and the length of the substring to be copied
	
gen anycancer_9=0
// code: malignant diagnosis has to overweigh a benign diagnosis if both are present. Therefore, code group 3/4 first, then 1/2.
forvalues i=0/14 {  
			replace anycancer_9=4 if cancer_9_`i'>= 1730 & cancer_9_`i' <= 1739 // only Nmskin
			replace anycancer_9=3 if cancer_9_`i'>= 2100 & cancer_9_`i' <= 2299 // only Benign
			replace anycancer_9=2 if cancer_9_`i'>= 2300 & cancer_9_`i' <= 2349 // in situ
			replace anycancer_9=1 if cancer_9_`i'>= 1400 & cancer_9_`i' <= 2096  & cancer_9_`i' != 1730 & cancer_9_`i' != 1731 & cancer_9_`i' != 1732 & cancer_9_`i' != 1733 & cancer_9_`i' != 1734 & cancer_9_`i' != 1735 & cancer_9_`i' != 1736 & cancer_9_`i' != 1737 & cancer_9_`i' != 1738 & cancer_9_`i' != 1739
} 
	label define cancer_9label 0 "0:no ICD 9" 1"1:ICD9 140-209 Malignant" 2"2:ICD9 230-234 In situ" 3"3:ICD9 210-229 Benign" 4"4: ICD9 173 NMskin" 
	label values anycancer_9 cancer_9label

tab anycancer_9 //    anycancer_9 |      Freq.     Percent        Cum.
-------------------------+-----------------------------------
              0:no ICD 9 |    491,886       97.90       97.90
1:ICD9 140-209 Malignant |      4,754        0.95       98.85
  2:ICD9 230-234 In situ |      4,234        0.84       99.69
   3:ICD9 210-229 Benign |        215        0.04       99.74
      4: ICD9 173 NMskin |      1,326        0.26      100.00
-------------------------+-----------------------------------
                   Total |    502,415      100.00

	*ICD 10
	**Malignant and benign neoplasms reported as ICD10 (prevalent and incident):
	* 1: "C" (Malignant neoplasm) and not equal to C44 (Other and unspec malignant neoplasm of skin): C00-C96
	* 2: "D00-D09" in situ 
	* 3: "D10-D36" Benign neoplasms
	* 4: "C44" Non melanoma skin or NSB
	* 5: "D37-D48" Neoplasms of uncertain/unknown behaviour
	// only exclude prevalent group 1 & 2.
	
gen anycancer_10=0
// for instances 0-11:
forvalues i=0/11 {
		replace anycancer_10=5 if substr(cancer_10_`i', 1, 3) >= "D37" & substr(cancer_10_`i', 1, 3) <= "D48" 
		replace anycancer_10=4 if substr(cancer_10_`i', 1, 3) == "C44"
		replace anycancer_10=3 if substr(cancer_10_`i', 1, 3) >= "D10" & substr(cancer_10_`i', 1, 3) <= "D36" 
		replace anycancer_10=2 if substr(cancer_10_`i', 1, 3) >= "D00" & substr(cancer_10_`i', 1, 3) <= "D09" 
		replace anycancer_10=1 if substr(cancer_10_`i', 1, 1) == "C" & substr(cancer_10_`i', 1, 3) != "C44"	
}
// for instance 13:
replace anycancer_10=5 if substr(cancer_10_13, 1, 3) >= "D37" & substr(cancer_10_13, 1, 3) <= "D48" 
		replace anycancer_10=4 if substr(cancer_10_13, 1, 3) == "C44"
		replace anycancer_10=3 if substr(cancer_10_13, 1, 3) >= "D10" & substr(cancer_10_13, 1, 3) <= "D36" 
		replace anycancer_10=2 if substr(cancer_10_13, 1, 3) >= "D00" & substr(cancer_10_13, 1, 3) <= "D09" 
		replace anycancer_10=1 if substr(cancer_10_13, 1, 1) == "C" & substr(cancer_10_13, 1, 3) != "C44"
// for instances 15-16:
gen anycancer_10=0
forvalues i=15/16 {
		replace anycancer_10=5 if substr(cancer_10_`i', 1, 3) >= "D37" & substr(cancer_10_`i', 1, 3) <= "D48" 
		replace anycancer_10=4 if substr(cancer_10_`i', 1, 3) == "C44"
		replace anycancer_10=3 if substr(cancer_10_`i', 1, 3) >= "D10" & substr(cancer_10_`i', 1, 3) <= "D36" 
		replace anycancer_10=2 if substr(cancer_10_`i', 1, 3) >= "D00" & substr(cancer_10_`i', 1, 3) <= "D09" 
		replace anycancer_10=1 if substr(cancer_10_`i', 1, 1) == "C" & substr(cancer_10_`i', 1, 3) != "C44"	
}

	label define cancer_10label 0 "0:no ICD 10" 1"1:ICD10 C Malignant" 2"2:ICD10 D0-D09 In situ" 3"3:ICD10 D10-D36 Benign" 4"4: ICD10 C44 NMskin" 5"5: ICD10 D37-D48 Unknown neoplasms"
	label values anycancer_10 cancer_10label

tab anycancer_10 //  anycancer_10 |      Freq.     Percent        Cum.
-----------------------------------+-----------------------------------
                       0:no ICD 10 |    396,011       78.82       78.82
               1:ICD10 C Malignant |     64,481       12.83       91.66
            2:ICD10 D0-D09 In situ |     10,760        2.14       93.80
            3:ICD10 D10-D36 Benign |      1,238        0.25       94.04
               4: ICD10 C44 NMskin |     27,224        5.42       99.46
5: ICD10 D37-D48 Unknown neoplasms |      2,701        0.54      100.00
-----------------------------------+-----------------------------------
                             Total |    502,415      100.00

	
**2. indicator variable for any malignant cancer
gen anycancer=0
replace anycancer=1 if anycancer_10==1 | anycancer_10==2 anycancer_9==1 anycancer_9==2

save "Cancer_registry.dta", replace

/// For future (survival) analyses, we will need the earliest date for BC diagnosis *outcome* AND earliest date of any malignant cancer *censoring*
// Problem: long format of CR with multiple dates and diagnoses, no clear identification of dates. 
// Solution: Will do 2 datasets, one with BC==1 and earliest BC date, another one with anycancer==1 and earliest anycancer date

***1. BC diagnosis & first date***
**1.1 need to reshape dataset to long // problem: mismatch due to empty instances
drop cancer_10_12 cancer_10_14 
// manually reshape: data - change data - other transformation - reshape // i(eid) and j(number), xij variables: cancer_date cancer_10_ cancer_9_ 
// results in very long dataset with 0-16 rows for every ID. Need to just keep one row per ID with BC==1
gen BC=0
replace BC=1 if substr(cancer_10_,1,3)=="C50"
replace BC=1 if cancer_9_>= 1740 & cancer_9_<= 1749
keep if BC==1 
unique eid // 18430 unique BC entries, total n of records is 21724. Need to identify earliest BC date and drop later duplicates
bysort eid (cancer_date): gen n=_n
keep if n==1 // 3,294 obs deleted. 18,430 unique BC diagnoses with earliest date.
keep eid cancer_date cancer_10_ 
rename cancer_date BC_date 
rename cancer_10 BC_ICD10
save "Cancer_registry_BC_firstdate.dta"

***2. Any cancer diagnosis & first date***
use "K:\MSc Placements\2021\JuliaW\Paper_CR\analyses\Cancer_registry.dta"
// same as for BC dates
drop BC9 BC10 cancer_10_12 cancer_10_14 // not needed. 
// reshape to long. Need to recreate anycancer vars
drop anycancer_10 anycancer_9 
gen anycancer_10=0
replace anycancer_10=1 if substr(cancer_10_, 1, 3) >= "D00" & substr(cancer_10_, 1, 3) <= "D09" // in situ
replace anycancer_10=1 if substr(cancer_10_, 1, 1) == "C" & substr(cancer_10_, 1, 3) != "C44" // malignant exc NMskin
gen anycancer_9=0
replace anycancer_9=1 if cancer_9_>= 2300 & cancer_9_<= 2349 // in situ
replace anycancer_9=1 if cancer_9_>= 1400 & cancer_9_<= 2096  & cancer_9_ != 1730 & cancer_9_ != 1731 & cancer_9_ != 1732 & cancer_9_ != 1733 & cancer_9_ != 1734 & cancer_9_ != 1735 & cancer_9_ != 1736 & cancer_9_ != 1737 & cancer_9_ != 1738 & cancer_9_ != 1739 // malignant exc NMskin
keep if anycancer_9==1 | anycancer_10==1
unique eid // 83,808 unique Ids with cancer diagnosis. 107,091 total records
// need to identify earliest cancer date and drop later duplicates
bysort eid (cancer_date): gen n=_n
keep if n==1 // 23,283 obs deleted. 83,808 unique cancer diagnoses with earliest date.
keep eid cancer_date cancer_10_ cancer_9_
rename cancer_date anycancer_date
rename cancer_10 anycancer_10 
rename cancer_9 anycancer_9
save "Cancerregistry_cancer_firstdate.dta", replace

***3. merge both datasets
use "Cancerregistry_cancer_firstdate.dta"
merge 1:n eid using "Cancer_registry_BC_firstdate.dta"
drop _merge
save "Cancerregistry_final.dta"



