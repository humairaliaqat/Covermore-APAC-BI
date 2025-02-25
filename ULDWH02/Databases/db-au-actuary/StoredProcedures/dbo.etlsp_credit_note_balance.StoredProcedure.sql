USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_credit_note_balance]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

     
      
      
CREATE procedure [dbo].[etlsp_credit_note_balance]      
as      
begin      
      
/*      
*/      
      
    set nocount on      
      
      
    if object_id('[cng].[UW_Premiums]') is null      
    begin      
      
    CREATE TABLE [cng].[UW_Premiums](
	[Rank] [bigint] NULL,
	[UW_Month] [date] NULL,
	[PolicyKey] [nvarchar](50) NULL,
	[UW_Policy_Status] [nvarchar](50) NULL,
	[UW_Premium] [float] NULL,
	[UW_Premium_COVID19] [float] NULL,
	[Previous_Policy_Status] [nvarchar](50) NULL,
	[Previous_UW_Premium] [float] NULL,
	[Previous_UW_Premium_COVID19] [float] NULL,
	[Movement] [float] NULL,
	[Movement_COVID19] [float] NULL,
	[Total_Movement] [float] NULL,
	[Total_Movement_COVID19] [float] NULL,
	[Domain_Country] [nvarchar](50) NULL,
	[Issue_Mth] [datetime2](7) NULL,
	[Rating_Group] [nvarchar](50) NULL,
	[JV_Description_Orig] [nvarchar](50) NULL,
	[JV_Group] [nvarchar](50) NULL,
	[Product_Code] [nvarchar](50) NULL,
	[UW_Premium_Current] [float] NULL
    )    
      CREATE CLUSTERED INDEX [idx_UW_Premiums_test_PolicyKeyProductCode_test] ON [cng].[UW_Premiums_20240509] ([PolicyKey],[Product_Code])
      CREATE NONCLUSTERED INDEX [idx_UW_Premiums_test_Movement_test] ON [cng].[UW_Premiums_20240509] ([Movement])
            
    end      
      
    if object_id('[cng].[UW_Premiums_20240509]') is not null      
        drop table [cng].[UW_Premiums_20240509]
        
    select * into [cng].[UW_Premiums_20240509]
    from [BHDWH03].[cng].[UW_Premiums]      
      
      
end 
GO
