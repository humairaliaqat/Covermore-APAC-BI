USE [db-au-atlas]
GO
/****** Object:  StoredProcedure [atlas].[WTP_Customer_Feedback_c_Proc]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
          
   
  
  
CREATE PROCEDURE [atlas].[WTP_Customer_Feedback_c_Proc]          
AS          
BEGIN           
 SET NOCOUNT ON;          
          
  
 MERGE atlas.[WTP_Customer_Feedback_c] DST          
 USING (  
 SELECT           
[Carebase_Case_Number_C],  
[Case_C],  
[WTP_Comment_C],  
[Complaints_ID_C],  
[Complaint_Management_C],  
[CreatedById],  
[CurrencyISOCode],  
[WTP_Email_C],  
[Name],  
[Feedback_Category_C],  
[WTP_Feedback_Date_C],  
[Feedback_Method_C],  
[Feedback_Outcome_Notes_C],  
[Feedback_Source_C],  
[Feedback_Outcome_C],  
[Feedback_Sub_type_C],  
[Feedback_type_c],  
[LastModifiedByid],  
[OwnerId],  
[Policy_No_C],  
[WTP_Provider_name],  
[RecordTypeId],  
[Severity_c],  
[id]     
   FROM [RDSLnk].[STG_RDS].[dbo].[STG_WTP_Customer_Feedback_c] stgc                 
  ) SRC          
 ON DST.Id = SRC.Id          
          
 WHEN NOT MATCHED THEN          
 INSERT (          
  [Carebase_Case_Number_C],  
[Case_C],  
[WTP_Comment_C],  
[Complaints_ID_C],  
[Complaint_Management_C],  
[CreatedById],  
[CurrencyISOCode],  
[WTP_Email_C],  
[Name],  
[Feedback_Category_C],  
[WTP_Feedback_Date_C],  
[Feedback_Method_C],  
[Feedback_Outcome_Notes_C],  
[Feedback_Source_C],  
[Feedback_Outcome_C],  
[Feedback_Sub_type_C],  
[Feedback_type_c],  
[LastModifiedByid],  
[OwnerId],  
[Policy_No_C],  
[WTP_Provider_name],  
[RecordTypeId],  
[Severity_c],  
[id]             
  )          
 VALUES (          
SRC.[Carebase_Case_Number_C],  
SRC.[Case_C],  
SRC.[WTP_Comment_C],  
SRC.[Complaints_ID_C],  
SRC.[Complaint_Management_C],  
SRC.[CreatedById],  
SRC.[CurrencyISOCode],  
SRC.[WTP_Email_C],  
SRC.[Name],  
SRC.[Feedback_Category_C],  
SRC.[WTP_Feedback_Date_C],  
SRC.[Feedback_Method_C],  
SRC.[Feedback_Outcome_Notes_C],  
SRC.[Feedback_Source_C],  
SRC.[Feedback_Outcome_C],  
SRC.[Feedback_Sub_type_C],  
SRC.[Feedback_type_c],  
SRC.[LastModifiedByid],  
SRC.[OwnerId],  
SRC.[Policy_No_C],  
SRC.[WTP_Provider_name],  
SRC.[RecordTypeId],  
SRC.[Severity_c],  
SRC.[id]          
  )          
 WHEN MATCHED AND (          
  ISNULL(DST.[Carebase_Case_Number_C],'') <> ISNULL(SRC.[Carebase_Case_Number_C],'') OR          
  ISNULL(DST.[Case_C],'') <> ISNULL(SRC.[Case_C],'') OR  
  ISNULL(DST.[WTP_Comment_C],'') <> ISNULL(SRC.[WTP_Comment_C],'') OR  
  ISNULL(DST.[Complaints_ID_C],'') <> ISNULL(SRC.[Complaints_ID_C],'') OR  
  ISNULL(DST.[Complaint_Management_C],'') <> ISNULL(SRC.[Complaint_Management_C],'') OR  
  ISNULL(DST.[CreatedById],'') <> ISNULL(SRC.[CreatedById],'') OR  
  ISNULL(DST.[CurrencyISOCode],'') <> ISNULL(SRC.[CurrencyISOCode],'') OR  
  ISNULL(DST.[WTP_Email_C],'') <> ISNULL(SRC.[WTP_Email_C],'') OR  
  ISNULL(DST.[Name],'') <> ISNULL(SRC.[Name],'') OR  
  ISNULL(DST.[Feedback_Category_C],'') <> ISNULL(SRC.[Feedback_Category_C],'') OR  
  ISNULL(DST.[WTP_Feedback_Date_C],'') <> ISNULL(SRC.[WTP_Feedback_Date_C],'') OR  
  ISNULL(DST.[Feedback_Method_C],'') <> ISNULL(SRC.[Feedback_Method_C],'') OR  
  ISNULL(DST.[Feedback_Outcome_Notes_C],'') <> ISNULL(SRC.[Feedback_Outcome_Notes_C],'') OR  
  ISNULL(DST.[Feedback_Source_C],'') <> ISNULL(SRC.[Feedback_Source_C],'') OR  
  ISNULL(DST.[Feedback_Outcome_C],'') <> ISNULL(SRC.[Feedback_Outcome_C],'') OR  
  ISNULL(DST.[Feedback_Sub_type_C],'') <> ISNULL(SRC.[Feedback_Sub_type_C],'') OR  
  ISNULL(DST.[Feedback_type_c],'') <> ISNULL(SRC.[Feedback_type_c],'') OR  
  ISNULL(DST.[LastModifiedByid],'') <> ISNULL(SRC.[LastModifiedByid],'') OR  
  ISNULL(DST.[OwnerId],'') <> ISNULL(SRC.[OwnerId],'') OR  
  ISNULL(DST.[Policy_No_C],'') <> ISNULL(SRC.[Policy_No_C],'') OR  
  ISNULL(DST.[WTP_Provider_name],'') <> ISNULL(SRC.[WTP_Provider_name],'') OR  
  ISNULL(DST.[RecordTypeId],'') <> ISNULL(SRC.[RecordTypeId],'') OR  
  ISNULL(DST.[Severity_c],'') <> ISNULL(SRC.[Severity_c],'') OR  
  ISNULL(DST.[id],'') <> ISNULL(SRC.[id],'')       
 ) THEN           
 UPDATE SET          
  DST.[Carebase_Case_Number_C]= SRC.[Carebase_Case_Number_C],  
  DST.[Case_C]                = SRC.[Case_C],  
DST.[WTP_Comment_C]         = SRC.[WTP_Comment_C],  
DST.[Complaints_ID_C]       = SRC.[Complaints_ID_C],  
DST.[Complaint_Management_C]= SRC.[Complaint_Management_C],  
DST.[CreatedById]           = SRC.[CreatedById],  
DST.[CurrencyISOCode]       = SRC.[CurrencyISOCode],  
DST.[WTP_Email_C]           = SRC.[WTP_Email_C],  
DST.[Name]                  = SRC.[Name],  
DST.[Feedback_Category_C]   = SRC.[Feedback_Category_C],  
DST.[WTP_Feedback_Date_C]   = SRC.[WTP_Feedback_Date_C],  
DST.[Feedback_Method_C]     = SRC.[Feedback_Method_C],  
DST.[Feedback_Outcome_Notes_C]= SRC.[Feedback_Outcome_Notes_C],  
DST.[Feedback_Source_C]     = SRC.[Feedback_Source_C],  
DST.[Feedback_Outcome_C]    = SRC.[Feedback_Outcome_C],  
DST.[Feedback_Sub_type_C]   = SRC.[Feedback_Sub_type_C],  
DST.[Feedback_type_c]       = SRC.[Feedback_type_c],  
DST.[LastModifiedByid]      = SRC.[LastModifiedByid],  
DST.[OwnerId]               = SRC.[OwnerId],  
DST.[Policy_No_C]           = SRC.[Policy_No_C],  
DST.[WTP_Provider_name]     = SRC.[WTP_Provider_name],  
DST.[RecordTypeId]          = SRC.[RecordTypeId],  
DST.[Severity_c]            = SRC.[Severity_c],  
DST.[id]                    = SRC.[id];      
         
END; 
GO
