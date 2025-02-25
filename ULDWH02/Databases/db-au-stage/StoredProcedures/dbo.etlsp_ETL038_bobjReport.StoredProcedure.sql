USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL038_bobjReport]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL038_bobjReport]
as

SET NOCOUNT ON

if object_id('[db-au-cmdwh].dbo.bobjReport') is null
begin
		create table [db-au-cmdwh].dbo.bobjReport
		(
			[ReportID] [float] NULL,
			[No] [float] NULL,
			[ReportNo] [nvarchar](255) NULL,
			[ReportTitle] [nvarchar](255) NULL,
			[ReportType] [nvarchar](255) NULL,
			[Path] [nvarchar](255) NULL,
			[Author] [nvarchar](255) NULL,
			[CreateDate] [datetime] NULL,
			[UpdateDate] [datetime] NULL,
			[Universe] [nvarchar](255) NULL
		) 
end	
else
	truncate table [db-au-cmdwh].dbo.bobjReport


insert [db-au-cmdwh].dbo.bobjReport with(tablock)
(
	ReportID,
	[No],
	ReportNo,
	ReportTitle,
	ReportType,
	[Path],
	Author,
	CreateDate,
	UpdateDate,
	Universe
)
select
	ReportID,
	[No],
	ReportNo,
	ReportTitle,
	ReportType,
	[Path],
	Author,
	CreateDate,
	UpdateDate,
	Universe
from
	[db-au-stage].dbo.etl_usrBIReportObjects
GO
