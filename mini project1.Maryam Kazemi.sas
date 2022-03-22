data telecom_company;
infile "E:\Data science course\course 4.  fundamentals of SAS programming\New_Wireless_Fixed.txt" missover;
label Acctno="Account number"
      Deactdt="Account activation date"
      Deactdt=" account deactivation date"
      DeactReason=" reason for deactivation"
      GoodCredit="customer’s credit is good or not"
      RatePlan= "rate plan for the customer"
      DealerType= "dealer type"
      Age= "customer age"
      Province= "province"
      Sales= "the amount of sales to a customer"
	  ;
input
	Acctno $ 1-13
	@15 Actdt mmddyy10.
	@26 Deactdt mmddyy10.
	DeactReason $ 41-44
	@53 GoodCredit $
	@62 RatePlan $
	DealerType $ 65-66
	Age 74-76
	Province $ 80-81
	sales comma10.2;
format Actdt mmddyy10. Deactdt mmddyy10. sales dollar12.2 ;
run;
title "Displaying the Descriptor Portion of a telecom company Data Set";
proc contents data=telecom_company;run;
* BROWSING THE Data PORTION ;
*Head;
proc print data=telecom_company (obs=10);run;
*Tail;
proc print data=telecom_company (obs=102255  firstobs=102244);run;
title "computing descriptive statistics for charachter variables";
proc freq data=telecom_company;
table DeactReason GoodCredit RatePlan DealerType Province  ;run;
title;
title "computing descriptive statistics for numerical variables";
proc means data=telecom_company N NMISS min Q1 median Q3 qrange mean std cv  lclm uclm maxdec=2;
var Age Sales;
run; 
*is the acctno unique?;
proc freq data = telecom_company nlevels;
tables Acctno ;
run;
data telecom_company;
set telecom_company;
if missing(Acctno) then delete;run;
proc freq data=telecom_company noprint;
table Acctno/ out=freq(drop=percent);
run;
data freq;
set freq;
if count=1 then delete;run;
*using proc sql;
proc sql;
create table freq as
select Acctno, count(*) as c
from telecom_company
group by Acctno
order by c desc;quit;
*What is the number of accounts activated and deactivated?; 

data telecom_company;
set telecom_company; 
length activation_status $8;
if missing (Deactdt) then activation_status="active";
else activation_status="deactive";run;
proc freq data=telecom_company ;
table activation_status/nocum ;run;
*When is the earliest and
latest activation/deactivation dates available?;
 proc sql;
 create table dates as
 select min(Actdt) as min_active format=date9.,
 min(Deactdt) as min_deactive format=date9.,
 max(actdt) as max_active format=date9.,
 max(Deactdt) as max_deactive format=date9.
 from telecom_company
 ;
quit;
*1.2  What is the age and province distributions of active and deactivated customers?;
title "the distribution of different age in activation status";
proc freq data=telecom_company;
table  age * activation_status /norow nopercent nocum nocol missing;run;

title "the distribution of different province in activation status";
proc freq data=telecom_company;
table  province *activation_status/norow nopercent nocum nocol missing;run;

*1.3 Segment the customers based on age, province and sales amount:
Sales segment: < $100, $100---500, $500-$800, $800 and above.
Age segments: < 20, 21-40, 41-60, 60 and above.
Create analysis report by using the attached Excel template.;
title "sales and age segmentation";
data telecom_company;
set telecom_company; 
length age_segment $5. sales_segment  $8.;
if sales <100 then sales_segment="<$100";
else if  100<=sales<500 then sales_segment="$100-500";
else if 500<=sales<800 then sales_segment="$500-800"; 
else sales_segment=">=$800"; 
if age <20 then age_segment="<20";
else if  20<=age<40 then age_segment="20-40";
else if 40<=age<60 then age_segment="40-60"; 
else age_segment=">=60";
run;
*1.4.Statistical Analysis:
1) Calculate the tenure in days for each account and give its simple statistics.;
data telecom_company;
set telecom_company;
if missing (Deactdt) then days_diff = intck('day',Actdt,today()); 
else days_diff = intck('day',Actdt,Deactdt);
run;
proc means data=telecom_company;
var days_diff;run;
*2) Calculate the number of accounts deactivated for each month.;
title;
data telecom_company;
set telecom_company;
if not missing (Deactdt) then month_deactive = month(Deactdt); run;
proc freq data=telecom_company;
table month_deactive/nopercent nocum;
run;
*3) Segment the account, first by account status “Active” and “Deactivated”, then by
Tenure: < 30 days, 31---60 days, 61 days--- one year, over one year. Report the
number of accounts of percent of all for each segment.;

data telecom_company;
set telecom_company;
length days_diff_segment $16.;
if not missing (Deactdt) then do;
if days_diff <30 then days_diff_segment="<30";
else if  30<=days_diff<60 then days_diff_segment="30-60";
else if 60<=days_diff<365 then days_diff_segment="60 days-one year"; 
else days_diff_segment=">=365";
end;run;

proc freq data=telecom_company;
table days_diff_segment*activation_status ;run;
*4) Test the general association between the tenure segments and “Good Credit”
“RatePlan ” and “DealerType.”;
 proc freq data=telecom_company;
table days_diff_segment*(GoodCredit RatePlan DealerType)/chisq;run;
*5) Is there any association between the account status and the tenure segments?
Could you find out a better tenure segmentation strategy that is more associated
with the account status?;

proc freq data=telecom_company;
table days_diff_segment*activation_status/chisq ;

run;


*6) Does Sales amount differ among different account status, GoodCredit, and
customer age segments?;
proc glm data=telecom_company;
class age_segment;
model sales=age_segment;
run;
proc ttest data=telecom_company;
class GoodCredit;
var sales;run;

proc ttest data=telecom_company;
class activation_status;
var sales;run;
*Part Two:  SAS Macro Programing 
2 -1:
Write a macro that accepts a state code as a parameter and creates a table containing 
employees from that state. Display a maximum of 10 rows from the table.;
%let prv="BC";
data employee_&prv;
set telecom_company (obs=10);
where Province=&prv;
run;
*in this method we defined province or state code as a macro variable and use 
it for creating list of ten employees in that state code.;
proc sql;
select distinct province into :p_code separated by " " 
from telecom_company;
quit;
%macro emp(n=);
%do i=1 %to &n;
%let code=%scan(&p_code,&i," ");
data employee_&code;
set telecom_company (obs=10);
where Province="&code";
run;
%end;
%mend emp;
%emp(n=5);





















