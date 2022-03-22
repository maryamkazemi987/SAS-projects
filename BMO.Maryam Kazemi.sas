
*BMO.Activity_checking dataset:
Obs Client_ID Account_ID Open_Date Assets Status 
1 1001 20032 02NOV19 7744 Active 
2 1002 20056 12DEC20 -12451 Inactive 
3 1003 20032 12JAN19 1274 Active 
4 1003 20074 19JAN19 7683 Active 
5 1002 20793 17SEP17 -591 Active 
6 1004 20142 16FEB17 14144 Active 
7 1005 21943 24OCT16 13981 Active 
8 1006 29371 09JUN08 14049 Inactive 
9 1002 29081 05APR18 2092 Active 


BMO.Activity_creditcard dataset:

Obs Client_ID Account_ID Open_Date credit_status Assets 
1 1003 313058 17DEC15 Active -4059 
2 1004 339524 16JAN19 Active -4327 
3 1002 330572 26SEP19 Active 15392 
4 1003 396821 07FEB20 Inactive -1359 
5 1004 375271 15MAR18 Active -1601 
6 1003 373859 09SEP20 Active 16515 
7 1006 383733 08NOV17 Inactive 5226 
8 1006 353413 16MAR18 Inactive 13741 
9 1005 365605 25JUN17 Active -4110;

data  Activity_checking;
length Status $9;
input Client_ID $4. Account_ID $6. Open_Date date9. Assets  Status $;
format Open_Date date7.;
datalines;
1001 20032 02NOV19  7744   Active 
1002 20056 12DEC20 -12451  Inactive 
1003 20032 12JAN19  1274   Active 
1003 20074 19JAN19  7683   Active 
1002 20793 17SEP17 -591    Active 
1004 20142 16FEB17  14144  Active 
1005 21943 24OCT16  13981  Active 
1006 29371 09JUN08  14049  Inactive 
1002 29081 05APR18  2092   Active 
;
run;


data Activity_creditcard;
length credit_status $9;
input @1 Client_ID $4. @6 Account_ID $5. @13 Open_Date date9. @21 credit_status $ Assets;
format Open_Date date7.;
datalines;
1003 313058 17DEC15 Active   -4059 
1004 339524 16JAN19 Active   -4327 
1002 330572 26SEP19 Active    15392 
1003 396821 07FEB20 Inactive -1359 
1004 375271 15MAR18 Active   -1601 
1003 373859 09SEP20 Active    16515 
1006 383733 08NOV17 Inactive  5226 
1006 353413 16MAR18 Inactive  13741 
1005 365605 25JUN17 Active   -4110
;
run;

/*Create a summary report tracking the below KPI metrics for all active clients
1.BMO_Since_Date: the first date when the customer started relationship with BMO
2.Product1_Since_Date: The first date when customer joined Product1(checking)
3.Product2_Since_Date: The first date when customer joined Product2(credit)
4.Total_Actives: Total active accounts under customer
5.Total_Assests: Total assests for each customer
*/
data Activity_checking;
set Activity_checking;
type="CH";run;
data Activity_creditcard;
set Activity_creditcard;
type="CR";run;
data BMO;
set Activity_checking  Activity_creditcard (rename=(credit_status=Status));
run;
proc sort data=BMO;
by Client_ID Open_Date;run;
*1.BMO_Since_Date: the first date when the customer started relationship with BMO;
proc sql;
select Client_ID, min(Open_Date) as first_date format=Date7.
from BMO
group by Client_ID
;quit;
*2.Product1_Since_Date: The first date when customer joined Product1(checking);
proc sql;
select Client_ID, min(Open_Date) as first_date format=Date7.
from BMO
where type="CH"
group by Client_ID
;quit;
*3.Product2_Since_Date: The first date when customer joined Product2(credit);
proc sql;
select Client_ID, min(Open_Date) as first_date format=Date7.
from BMO
where type="CR"
group by Client_ID
;quit;
*4.Total_Actives: Total active accounts under customer;
proc sql;
select Client_ID, count (*) as total_active 
from BMO
where lowcase(Status)="active"
group by Client_ID
;quit;
/*5.Total_Assests: Total assests for each customer
*/
proc sql;
select Client_ID, sum (assets) as total_assests 
from BMO
group by Client_ID
;quit;
