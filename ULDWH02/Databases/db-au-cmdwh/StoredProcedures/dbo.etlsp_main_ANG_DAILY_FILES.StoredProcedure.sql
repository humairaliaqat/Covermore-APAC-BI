USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_main_ANG_DAILY_FILES]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
  
  
  
  
  
  
  
  
  
  
    
CREATE Procedure [dbo].[etlsp_main_ANG_DAILY_FILES]      
as      
      
Begin   
declare @Path varchar(2000)  
declare @ExtZip varchar(4)        
declare @ExtTxt varchar(4)   
--declare @start date = N'2023-07-13'  
select @ExtTxt = '.csv'    
select @Path = 'E:\ETL\Data\ANG\'  
declare @start date = getdate()-1  
declare @dt varchar(20)  
select @dt = @start  
  
------------------------------------ClaimData_Proc--------------------------------------  
  
  
create table [db-au-cmdwh].[dbo].[ClaimData_Proc_temp_2]  
([Policy_Number] varchar(2000),  
[Claim_Number] varchar(2000),  
[Claim_Key] varchar(2000),  
[Section_ID] varchar(2000),  
[Section_Code] varchar(2000),  
[Incident_Date] varchar(2000),  
[Reported_Date] varchar(2000),  
[Closed_Date] varchar(2000),  
[Claim_Status] varchar(2000),  
[Claim_Denial_Reasons] varchar(2000),  
[Claim_Withdrawal_Reasons] varchar(2000),  
[Claim_Benefit] varchar(2000),  
[Peril_Code] varchar(2000),  
[Peril_Description] varchar(2000),  
[Event_Description] varchar(2000),  
[Cost_Type] varchar(2000),  
[Traveller_Sequence_No] varchar(2000),  
[Luggage_Flag] varchar(2000),  
[Snow_Sports_Flag] varchar(2000),  
[PEMC_Flag] varchar(2000),  
[Covid_Flag] varchar(2000),  
[Cruise_Flag] varchar(2000),  
[Motorbike_Flag] varchar(2000),  
[Adventure_Activities_Flag] varchar(2000),  
[Incident_Country] varchar(2000),  
[Reserve_Amount] varchar(2000),  
[Paid_Amount] varchar(2000),  
[Recovery_Amount] varchar(2000),  
[Movement_Sequence] varchar(2000),  
[First_Movement_In_Day] varchar(2000),  
[Assessment_Outcome_Description] varchar(2000),  
[Excess_Amount] varchar(2000),  
[Payment_Date] varchar(2000),  
[Is_Assistance_Case] varchar(2000),  
[Loss_Description] varchar(2000),  
[Agency_Code] varchar(2000),
[Plan_Type_Name]  varchar(2000)
)  
insert into [db-au-cmdwh].[dbo].[ClaimData_Proc_temp_2]  
values(  
'[Policy_Number]',  
'[Claim_Number]',  
'[Claim_Key]',  
'[Section_ID]',  
'[Section_Code]',  
'[Incident_Date]',  
'[Reported_Date]',  
'[Closed_Date]',  
'[Claim_Status]',  
'[Claim_Denial_Reasons]',  
'[Claim_Withdrawal_Reasons]',  
'[Claim_Benefit]',  
'[Peril_Code]',  
'[Peril_Description]',  
'[Event_Description]',  
'[Cost_Type]',  
'[Traveller_Sequence_No]',  
'[Luggage_Flag]',  
'[Snow_Sports_Flag]',  
'[PEMC_Flag]',  
'[Covid_Flag]',  
'[Cruise_Flag]',  
'[Motorbike_Flag]',  
'[Adventure_Activities_Flag]',  
'[Incident_Country]',  
'[Reserve_Amount]',  
'[Paid_Amount]',  
'[Recovery_Amount]',  
'[Movement_Sequence]',  
'[First_Movement_In_Day]',  
'[Assessment_Outcome_Description]',  
'[Excess_Amount]',  
'[Payment_Date]',  
'[Is_Assistance_Case]',  
'[Loss_Description]',  
'[Agency_Code]',
'[Plan_Type_Name]'     
)  
insert into [db-au-cmdwh].[dbo].[ClaimData_Proc_temp_2]  
EXEC [db-au-cmdwh].[dbo].[ClaimData_Proc]   
@StartDate = @start  
  
declare @QueryCL varchar(8000)        
declare @SQLCL varchar(8000)        
declare @FileNameCL varchar(200)   
select @QueryCL = 'select * from [db-au-cmdwh].[dbo].[ClaimData_Proc_temp_2]'   
select @FilenameCL = 'Claims_data_'      
select @SQLCL = ' bcp "' + @QueryCL + '" queryout "' + @Path + @FileNameCL + @dt + @ExtTxt + '"' + ' -S localhost -T -w'      
print(@SQLCL)     
exec xp_cmdshell @SQLCL      
declare @newpathCL varchar(8000)  
select @newpathCL = @Path + @FilenameCL + @dt + '.csv'  
------------------------------------Quote_Data_Proc---------------------------------------   
  
create table [db-au-cmdwh].[dbo].[Quote_Data_Proc_temp_1]  
(  
[Policy_Number]  Varchar(1000),  
[Quote_Date]  Varchar(1000),  
[Lead_Number]  Varchar(1000),  
[GCLID]  Varchar(1000),  
[GA_Client_ID]  Varchar(1000),  
[Link_ID]  Varchar(1000),  
[Marketing_Opt_Out]  Varchar(1000),  
[Travel_Countries_List]  Varchar(1000),  
[Primary_Country]  Varchar(1000),  
[Number_of_Countries]  Varchar(1000),  
[Region_List]  Varchar(1000),  
[Departure_Date]  Varchar(1000),  
[Return_Date]  Varchar(1000),  
[Trip_Duration]  Varchar(1000),  
[Excess_Amount]  Varchar(1000),
[Plan_Type_Name]    Varchar(1000), 
[Cancellation_Sum_Insured]  Varchar(1000),  
[Cruise_Flag]  Varchar(1000),  
[Adventure_Activities_Flag]  Varchar(1000),  
[Motorbike_Flag]  Varchar(1000),  
[Snow_Sports_Flag]  Varchar(1000),  
[Luggage_Flag]  Varchar(1000),  
[PEMC_Flag]  Varchar(1000),  
[Covid_Flag]  Varchar(1000),  
[Quoted_Base_Premium]  Varchar(1000),  
[Quoted_Cancellation_Premium]  Varchar(1000),  
[Quoted_Snow_Sports_Premium]  Varchar(1000),  
[Quoted_Adventure_Activities_Premium]  Varchar(1000),  
[Quoted_Motorcycle_Premium]  Varchar(1000),  
[Quoted_Luggage_Premium]  Varchar(1000),  
[Quoted_PEMC_Premium]  Varchar(1000),  
[Quoted_Covid_Premium]  Varchar(1000),  
[Quoted_Cruise_Premium]  Varchar(1000),  
[Total_Quoted_Premium]  Varchar(1000),  
[Total_Quoted_Gross_Premium]  Varchar(1000),  
[NAP]  Varchar(1000),  
[Policy_Holder_Title]  Varchar(1000),  
[Policy_Holder_First_Name]  Varchar(1000),  
[Policy_Holder_Surname]  Varchar(1000),  
[Policy_Holder_Email]  Varchar(1000),  
[Policy_Holder_Mobile_Phone]  Varchar(1000),  
[Policy_Holder_Address]  Varchar(1000),  
[Policy_Holder_DOB]  Varchar(1000),  
[Policy_Holder_Age]  Varchar(1000),  
[Policy_Holder_State]  Varchar(1000),  
[Oldest_Traveller_DOB]  Varchar(1000),  
[Oldest_Traveller_Age]  Varchar(1000),  
[Agency_Code]  Varchar(1000),  
[Agency_Name]  Varchar(1000),  
[Brand]  Varchar(1000),  
[Channel_Type]  Varchar(1000),  
[Promotional_Code]  Varchar(1000),  
[Promotional_Factor]  Varchar(1000),  
[Session_Token] Varchar(1000)  
)  
insert into [db-au-cmdwh].[dbo].[Quote_Data_Proc_temp_1]  
values(  
'[Policy_Number]',  
'[Quote_Date]',  
'[Lead_Number]',  
'[GCLID]',  
'[GA_Client_ID]',  
'[Link_ID]',  
'[Marketing_Opt_Out]',  
'[Travel_Countries_List]',  
'[Primary_Country]',  
'[Number_of_Countries]',  
'[Region_List]',  
'[Departure_Date]',  
'[Return_Date]',  
'[Trip_Duration]',  
'[Excess_Amount]',
'[Plan_Type_Name]',  
'[Cancellation_Sum_Insured]',  
'[Cruise_Flag]',  
'[Adventure_Activities_Flag]',  
'[Motorbike_Flag]',  
'[Snow_Sports_Flag]',  
'[Luggage_Flag]',  
'[PEMC_Flag]',  
'[Covid_Flag]',  
'[Quoted_Base_Premium]',  
'[Quoted_Cancellation_Premium]',  
'[Quoted_Snow_Sports_Premium]',  
'[Quoted_Adventure_Activities_Premium]',  
'[Quoted_Motorcycle_Premium]',  
'[Quoted_Luggage_Premium]',  
'[Quoted_PEMC_Premium]',  
'[Quoted_Covid_Premium]',  
'[Quoted_Cruise_Premium]',  
'[Total_Quoted_Premium]',  
'[Total_Quoted_Gross_Premium]',  
'[NAP]',  
'[Policy_Holder_Title]',  
'[Policy_Holder_First_Name]',  
'[Policy_Holder_Surname]',  
'[Policy_Holder_Email]',  
'[Policy_Holder_Mobile_Phone]',  
'[Policy_Holder_Address]',  
'[Policy_Holder_DOB]',  
'[Policy_Holder_Age]',  
'[Policy_Holder_State]',  
'[Oldest_Traveller_DOB]',  
'[Oldest_Traveller_Age]',  
'[Agency_Code]',  
'[Agency_Name]',  
'[Brand]',  
'[Channel_Type]',  
'[Promotional_Code]',  
'[Promotional_Factor]',  
'[Session_Token]'   
)  
insert into [db-au-cmdwh].[dbo].[Quote_Data_Proc_temp_1]  
EXEC [db-au-cmdwh].[dbo].[Quote_Data_Proc]   
@StartDate = @start  
  
declare @QueryQD varchar(8000)        
declare @SQLQD varchar(8000)  
declare @FileNameQD varchar(200)  
select @QueryQD = 'select * from [db-au-cmdwh].[dbo].[Quote_Data_Proc_temp_1]'   
select @FilenameQD = 'Quote_data_'      
select @SQLQD = ' bcp "' + @QueryQD + '" queryout "' + @Path + @FileNameQD + @dt + @ExtTxt + '"' + ' -S localhost -T -w'      
print(@SQLQD)     
exec xp_cmdshell @SQLQD    
declare @newpathQD varchar(8000)  
select @newpathQD = @Path + @FilenameQD + @dt + '.csv'  
  
  
-------------------------Increase_Luggage_Limits_Data_Proc---------------------------------  
  
  
create table [db-au-cmdwh].[dbo].[Increase_Luggage_Limits_Data_Proc_temp_1]  
(  
[Policy_Number] varchar(5000),                                                              
[Transaction Type] Varchar(1000),                                                              
[Transaction_Sequence_Number] Varchar(1000),                                                  
[Transaction_Status] Varchar(1000),                                                              
[Transaction_Date] varchar(5000),                                                              
[Sold_Date] varchar(5000),                                                       
[Rate_Effective_Date] varchar(1000),                                        
[Traveller_Sequence_No] Varchar(1000),                                                   
[Item_Description] Varchar(1000),                                                              
[Item_Limit_Increase_Amount] Varchar(1000)    
)  
insert into [db-au-cmdwh].[dbo].[Increase_Luggage_Limits_Data_Proc_temp_1]  
values(  
'[Policy_Number]',                                                              
'[Transaction Type]',                                                              
'[Transaction_Sequence_Number]',                                                  
'[Transaction_Status]',                                                              
'[Transaction_Date]',                                                              
'[Sold_Date]',                                                       
'[Rate_Effective_Date]',                                        
'[Traveller_Sequence_No]',                                                   
'[Item_Description]',                                                              
'[Item_Limit_Increase_Amount]'   
)  
insert into [db-au-cmdwh].[dbo].[Increase_Luggage_Limits_Data_Proc_temp_1]  
EXEC [db-au-cmdwh].[dbo].[Increase_Luggage_Limits_Data_Proc]   
@StartDate = @start  
  
declare @QueryINC varchar(8000)        
declare @SQLINC varchar(8000)  
declare @FileNameINC varchar(200)   
select @QueryINC = 'select * from [db-au-cmdwh].[dbo].[Increase_Luggage_Limits_Data_Proc_temp_1]'   
select @FileNameINC = 'Increase_Luggage_Limits_Data_Proc_'      
select @SQLINC = ' bcp "' + @QueryINC + '" queryout "' + @Path + @FileNameINC + @dt + @ExtTxt + '"' + ' -S localhost -T -w'      
print(@SQLINC)     
exec xp_cmdshell @SQLINC   
declare @newpathINC varchar(8000)  
select @newpathINC = @Path + @FilenameINC + @dt + '.csv'  
  
------------------------------------Policy_Data_Insured_Level_Proc---------------------------  
  
  
create table [db-au-cmdwh].[dbo].[Policy_Data_Insured_Level_Proc_temp_1]  
(  
[Lead_Number] Varchar(1000),  
[Policy_Number] Varchar(1000),  
[Transaction_Type] Varchar(1000),  
[Transaction_Sequence_Number] Varchar(1000),  
[Transaction_Status] Varchar(1000),  
[Transaction_Date] Varchar(1000),  
[Sold_Date] Varchar(1000),  
[Rate_Effective_Date] Varchar(1000),  
[Traveller_Sequence_No] Varchar(1000),  
[Traveller_Title] Varchar(1000),  
[Policy_Holder_First_Name] Varchar(1000),  
[Policy_Holder_Surname] Varchar(1000),  
[Traveller_DOB] Varchar(1000),  
[Traveller_Age] Varchar(1000),  
[Traveller_PEMC_Flag] Varchar(1000),  
[Traveller_Medical_Risk_Score] Varchar(1000),  
[Traveller_PEMC_Assessment_Outcome] Varchar(1000),  
[Traveller_PEMC_Additional_Premium] Varchar(1000)   
)  
insert into [db-au-cmdwh].[dbo].[Policy_Data_Insured_Level_Proc_temp_1]  
values(  
'[Lead_Number]',  
'[Policy_Number]',  
'[Transaction_Type]',  
'[Transaction_Sequence_Number]',  
'[Transaction_Status]',  
'[Transaction_Date]',  
'[Sold_Date]',  
'[Rate_Effective_Date]',  
'[Traveller_Sequence_No]',  
'[Traveller_Title]',  
'[Policy_Holder_First_Name]',  
'[Policy_Holder_Surname]',  
'[Traveller_DOB]',  
'[Traveller_Age]',  
'[Traveller_PEMC_Flag]',  
'[Traveller_Medical_Risk_Score]',  
'[Traveller_PEMC_Assessment_Outcome]',  
'[Traveller_PEMC_Additional_Premium]'  
)  
insert into [db-au-cmdwh].[dbo].[Policy_Data_Insured_Level_Proc_temp_1]  
EXEC [db-au-cmdwh].[dbo].[Policy_Data_Insured_Level_Proc]   
@StartDate = @start  
declare @QueryPOLINClvl varchar(8000)        
declare @SQLPOLINClvl varchar(8000)  
declare @FileNamePOLINClvl varchar(200)   
select @QueryPOLINClvl = 'select * from [db-au-cmdwh].[dbo].[Policy_Data_Insured_Level_Proc_temp_1]'   
select @FileNamePOLINClvl = 'Policy_Data_Insured_Level_Proc_'            
select @SQLPOLINClvl = ' bcp "' + @QueryPOLINClvl + '" queryout "' + @Path + @FileNamePOLINClvl + @dt + @ExtTxt + '"' + ' -S localhost -T -w'      
print(@SQLPOLINClvl)     
exec xp_cmdshell @SQLPOLINClvl   
declare @newpathPOLINClvl varchar(8000)  
select @newpathPOLINClvl = @Path + @FilenamePOLINClvl + @dt + '.csv'  
  
-------------------------------Policy_Data_at_Policy_Level_Proc----------------------------------  
  
create table [db-au-cmdwh].[dbo].[Policy_Data_at_Policy_Level_Proc_temp_1]  
(  
Posting_Date Varchar(1000),  
Policy_Number Varchar(1000),  
Transaction_Type Varchar(1000),  
Transaction_Sequence_Number Varchar(1000),  
Transaction_Status Varchar(1000),  
Transaction_Date Varchar(1000),  
Sold_Date Varchar(1000),  
Travel_Countries_List Varchar(1000),  
Number_of_Countries Varchar(1000),  
Primary_Country Varchar(1000),  
Region_List Varchar(1000),  
Primary_Region Varchar(1000),  
Area_No Varchar(1000),  
Area_Type Varchar(1000),  
Departure_Date Varchar(1000),  
Days_To_Departure Varchar(1000),  
Return_Date Varchar(1000),  
Trip_Duration Varchar(1000),  
Trip_Type Varchar(1000),  
Plan_Code Varchar(1000),  
[Plan] Varchar(1000),  
Single_Family Varchar(1000),  
Number_of_Adults Varchar(1000),  
Number_of_Children Varchar(1000),  
Total_Number_of_Insured Varchar(1000),  
Excess_Amount Varchar(1000),  
Cancellation_Sum_Insured Varchar(1000),  
Cruise_Flag Varchar(1000),  
Covid_Flag Varchar(1000),  
Luggage_Flag Varchar(1000),  
Snow_Sports_Flag Varchar(1000),  
Adventure_Activities_Flag Varchar(1000),  
Motorbike_Flag Varchar(1000),  
PEMC_Flag Varchar(1000),  
Base_Premium Varchar(1000),  
Total_Gross_Premium Varchar(1000),  
Cruise_Premium Varchar(1000),  
Adventure_Activities_Premium Varchar(1000),  
Motorcycle_Premium Varchar(1000),  
Cancellation_Premium Varchar(1000),  
Covid_Premium Varchar(1000),  
Luggage_Premium Varchar(1000),  
Snow_Sports_Premium Varchar(1000),  
PEMC_Premium Varchar(1000),  
Total_Premium Varchar(1000),  
GST_on_Total_Premium Varchar(1000),  
Stamp_Duty_on_Total_Premium Varchar(1000),  
NAP Varchar(1000),  
Policy_Holder_Title Varchar(1000),  
Policy_Holder_First_Name Varchar(1000),  
Policy_Holder_Surname Varchar(1000),  
Policy_Holder_Email Varchar(1000),  
Policy_Holder_Mobile_Phone Varchar(1000),  
Policy_Holder_State Varchar(1000),  
Policy_Holder_DOB Varchar(1000),  
Policy_Holder_Age Varchar(1000),  
Policy_Holder_PostCode Varchar(1000),  
Policy_Holder_Address Varchar(1000),  
Policy_Holder_GNAF Varchar(1000),  
Oldest_Traveller_DOB Varchar(1000),  
Oldest_Traveller_Age Varchar(1000),  
Agency_Code Varchar(1000),  
Agency_Name Varchar(1000),  
Channel_Type Varchar(1000),  
Brand Varchar(1000),  
Promotional_Code Varchar(1000),  
Promotional_Factor Varchar(1000),  
Commission_Amount Varchar(1000),  
New_Policy_Count Varchar(1000)  
)  
insert into [db-au-cmdwh].[dbo].[Policy_Data_at_Policy_Level_Proc_temp_1]  
values(  
'[Posting_Date]',  
'[Policy_Number]',  
'[Transaction_Type]',  
'[Transaction_Sequence_Number]',  
'[Transaction_Status]',  
'[Transaction_Date]',  
'[Sold_Date]',  
'[Travel_Countries_List]',  
'[Number_of_Countries]',  
'[Primary_Country]',  
'[Region_List]',  
'[Primary_Region]',  
'[Area_No]',  
'[Area_Type]',  
'[Departure_Date]',  
'[Days_To_Departure]',  
'[Return_Date]',  
'[Trip_Duration]',  
'[Trip_Type]',  
'[Plan_Code]',  
'[Plan]',  
'[Single_Family]',  
'[Number_of_Adults]',  
'[Number_of_Children]',  
'[Total_Number_of_Insured]',  
'[Excess_Amount]',  
'[Cancellation_Sum_Insured]',  
'[Cruise_Flag]',  
'[Covid_Flag]',  
'[Luggage_Flag]',  
'[Snow_Sports_Flag]',  
'[Adventure_Activities_Flag]',  
'[Motorbike_Flag]',  
'[PEMC_Flag]',  
'[Base_Premium]',  
'[Total_Gross_Premium]',  
'[Cruise_Premium]',  
'[Adventure_Activities_Premium]',  
'[Motorcycle_Premium]',  
'[Cancellation_Premium]',  
'[Covid_Premium]',  
'[Luggage_Premium]',  
'[Snow_Sports_Premium]',  
'[PEMC_Premium]',  
'[Total_Premium]',  
'[GST_on_Total_Premium]',  
'[Stamp_Duty_on_Total_Premium]',  
'[NAP]',  
'[Policy_Holder_Title]',  
'[Policy_Holder_First_Name]',  
'[Policy_Holder_Surname]',  
'[Policy_Holder_Email]',  
'[Policy_Holder_Mobile_Phone]',  
'[Policy_Holder_State]',  
'[Policy_Holder_DOB]',  
'[Policy_Holder_Age]',  
'[Policy_Holder_PostCode]',  
'[Policy_Holder_Address]',  
'[Policy_Holder_GNAF]',  
'[Oldest_Traveller_DOB]',  
'[Oldest_Traveller_Age]',  
'[Agency_Code]',  
'[Agency_Name]',  
'[Channel_Type]',  
'[Brand]',  
'[Promotional_Code]',  
'[Promotional_Factor]',  
'[Commission_Amount]',  
'[New_Policy_Count]'  
)  
insert into [db-au-cmdwh].[dbo].[Policy_Data_at_Policy_Level_Proc_temp_1]  
EXEC [db-au-cmdwh].[dbo].[Policy_Data_at_Policy_Level_Proc]   
@StartDate = @start  
declare @QueryPollevProc varchar(8000)        
declare @SQLPollevProc varchar(8000)  
declare @FileNamePollevProc varchar(200)   
select @QueryPollevProc = 'select * from [db-au-cmdwh].[dbo].[Policy_Data_at_Policy_Level_Proc_temp_1]'        
select @FileNamePollevProc = 'Policy_Data_at_Policy_Level_Proc_'             
select @SQLPollevProc = ' bcp "' + @QueryPollevProc + '" queryout "' + @Path + @FileNamePollevProc + @dt + @ExtTxt + '"' + ' -S localhost -T -w'      
print(@SQLPollevProc)     
exec xp_cmdshell @SQLPollevProc  
declare @newpathPollevProc varchar(8000)  
select @newpathPollevProc = @Path + @FilenamePollevProc + @dt + '.csv'  
declare @subject_line varchar(8000)  
select @subject_line = 'A&G Daily files - ' + @dt  
declare @allpaths varchar(8000)  
select @allpaths = @newpathCL +';'+ @newpathQD +';'+@newpathINC +';'+@newpathPOLINClvl +';'+@newpathPollevProc  
exec msdb..sp_send_dbmail       
                @profile_name='covermorereport',      
    @recipients='ami.hart@covermore.com;ben.walters@covermore.com;BusinessIntelligence@covermore.com.au;shu.low@covermore.com;abhilash.yelmelwar@covermore.com;surya.bathula@covermore.com;',     
                @subject=@subject_line,      
                @body='',     
                @file_attachments = @allpaths;  
  
  
drop table [db-au-cmdwh].[dbo].[ClaimData_Proc_temp_2]  
drop table [db-au-cmdwh].[dbo].[Quote_Data_Proc_temp_1]  
drop table [db-au-cmdwh].[dbo].[Increase_Luggage_Limits_Data_Proc_temp_1]  
drop table [db-au-cmdwh].[dbo].[Policy_Data_Insured_Level_Proc_temp_1]  
drop table [db-au-cmdwh].[dbo].[Policy_Data_at_Policy_Level_Proc_temp_1]  
  
END    
GO
