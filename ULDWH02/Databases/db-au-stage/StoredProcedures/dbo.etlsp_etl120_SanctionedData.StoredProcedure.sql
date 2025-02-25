USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_etl120_SanctionedData]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--create
CREATE 
procedure [dbo].[etlsp_etl120_SanctionedData]
as

--SET NOCOUNT ON


/****************************************/
-- transform and load [db-au-cmdwh].dbo.entSanctioned
/****************************************/

--Automated saving of the table causes some problems in saving the unicode characters, so this table need to be created manually.
/*
CREATE TABLE [dbo].[etl_Sanctioned_AU](
	[Reference] [varchar](max) NULL,
	[Name of Individual or Entity] [nvarchar](max) NULL,--this column was being created as varchar and not nvarchar and was loosing unicode characters as a result
	[Type] [varchar](max) NULL,
	[Name Type] [varchar](max) NULL,
	[Date of Birth] [varchar](max) NULL,
	[Place of Birth] [varchar](max) NULL,
	[Citizenship] [varchar](max) NULL,
	[Address] [nvarchar](max) NULL,--this column was being created as flot automatically while saving pandas dataframe.
	[Additional Information] [varchar](max) NULL,
	[Listing Information] [varchar](max) NULL,
	[Committees] [varchar](max) NULL,
	[Control Date] [datetime] NULL
)

CREATE TABLE [db-au-stage].[dbo].[etl_Sanctioned_UK](--included for reference only
	[Name 6] [varchar](max) NULL,
	[Name 1] [varchar](max) NULL,
	[Name 2] [varchar](max) NULL,
	[Name 3] [varchar](max) NULL,
	[Name 4] [varchar](max) NULL,
	[Name 5] [varchar](max) NULL,
	[Title] [varchar](max) NULL,
	[DOB] [varchar](max) NULL,
	[Town of Birth] [varchar](max) NULL,
	[Country of Birth] [varchar](max) NULL,
	[Nationality] [varchar](max) NULL,
	[Passport Details] [varchar](max) NULL,
	[NI Number] [varchar](max) NULL,
	[Position] [varchar](max) NULL,
	[Address 1] [varchar](max) NULL,
	[Address 2] [varchar](max) NULL,
	[Address 3] [varchar](max) NULL,
	[Address 4] [varchar](max) NULL,
	[Address 5] [varchar](max) NULL,
	[Address 6] [varchar](max) NULL,
	[Post/Zip Code] [varchar](max) NULL,
	[Country] [varchar](max) NULL,
	[Other Information] [varchar](max) NULL,
	[Group Type] [varchar](max) NULL,
	[Alias Type] [varchar](max) NULL,
	[Regime] [varchar](max) NULL,
	[Listed On] [varchar](max) NULL,
	[Last Updated] [varchar](max) NULL,
	[Group ID] [bigint] NULL
) 
*/
					
					
if object_id('[db-au-cmdwh].dbo.entSanctioned') is null
begin
	CREATE TABLE [db-au-cmdwh].[dbo].[entSanctioned](
		[Country] [varchar](2) NOT NULL,
		[SanctionID] [varchar](50) NULL,
		[Reference] [varchar](61) NULL,
		[Name] [nvarchar](max) NULL,
		[DOBString] [nvarchar](max) NULL,
		[Control Date] [datetime] NULL
	);

    
end
else

begin
	delete dw
	from 
		[db-au-cmdwh].dbo.entSanctioned dw
		,
		(select 'AU' Country,reference SanctionID from [db-au-stage]..etl_Sanctioned_AU
		union all
		select 'UK',cast([Group ID] as varchar) from [db-au-stage]..etl_Sanctioned_UK) stg
		where dw.Country=stg.Country
		and dw.SanctionID =stg.SanctionID;

	

insert [db-au-cmdwh].dbo.entSanctioned with(tablockx)
(
		[Country],
		[SanctionID],
		[Reference] ,
		[Name],
		[DOBString],
		[Control Date]
)    			
(
select 'AU' [Country],Reference [SanctionID],Reference [Reference],[Name of Individual or Entity] [Name],[Date of Birth] [DOBString],[Control Date]
from [db-au-stage]..etl_Sanctioned_AU
union all
select 'UK' [Country],cast([Group ID] as varchar) [SanctionID],concat([Group ID],'-',ROW_NUMBER() over (order by [Group ID])) [Reference],concat([Name 1],' ',[Name 2],' ',[Name 3],' ',[Name 4],' ',[Name 5],' ',[Name 6]) [Name],
cast(DOB as varchar) [DOBString],convert(datetime,[Listed On],103) [Control Date]
--[Name 1]+' '+[Name 2]+' '+[Name 3]+' '+[Name 4]+' '+[Name 5]+' '+[Name 6],*
from [db-au-stage]..etl_Sanctioned_UK
)

end


---

if object_id('[db-au-cmdwh].dbo.entSanctionedDOB') is null
begin

CREATE TABLE [db-au-cmdwh].[dbo].[entSanctionedDOB](
	[Country] [varchar](2) NOT NULL,
	[SanctionID] [varchar](50) NULL,
	[Reference] [varchar](61) NULL,
	[DOBString] [nvarchar](max) NULL,
	[DOB] [date] NULL,
	[MOB] [int] NULL,
	[YOBStart] [bigint] NULL,
	[YOBEnd] [bigint] NULL
);
    
end
else

begin
	delete dw
	from 
		[db-au-cmdwh].dbo.entSanctionedDOB dw
		,
		(select 'AU' Country,reference SanctionID from [db-au-stage]..etl_Sanctioned_AU
		union all
		select 'UK',cast([Group ID] as varchar) from [db-au-stage]..etl_Sanctioned_UK) stg
		where dw.Country=stg.Country
		and dw.SanctionID =stg.SanctionID;

	

insert [db-au-cmdwh].dbo.entSanctionedDOB with(tablockx)
(	[Country],
	[SanctionID] ,
	[Reference] ,
	[DOBString] ,
	[DOB] ,
	[MOB] ,
	[YOBStart] ,
	[YOBEnd] 
)    			
(
select 'AU' [Country],Reference [SanctionID],Reference [Reference],[Date of Birth] [DOBString],try_cast([Date of Birth] as date) DOB,
month(try_cast([Date of Birth] as date)) MOB,year(try_cast([Date of Birth] as date)) YOBStart,year(try_cast([Date of Birth] as date)) YOBEnd
from [db-au-stage]..etl_Sanctioned_AU
union all
select 'UK' [Country],cast([Group ID] as varchar) [SanctionID],concat([Group ID],'-',ROW_NUMBER() over (order by [Group ID])) [Reference],cast(DOB as varchar) [DOBString],try_convert(date,DOB,103) DOB,
month(try_convert(date,DOB,103)) MOB,year(try_convert(date,DOB,103)) YOBStart,year(try_convert(date,DOB,103)) YOBEnd
from [db-au-stage]..etl_Sanctioned_UK
)

end
GO
