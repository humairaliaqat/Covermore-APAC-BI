USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_fltConsultant]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_fltConsultant](
	[DimConsultantId] [varchar](255) NULL,
	[Consultant_FirstName] [varchar](255) NULL,
	[Consultant_Last_Name] [varchar](255) NULL,
	[Consultant_JobTitle] [varchar](255) NULL,
	[Consultant_Login] [varchar](255) NULL,
	[Is_Current] [varchar](255) NULL,
	[Brand_Name] [varchar](255) NULL,
	[Business_Name] [varchar](255) NULL,
	[BusinessType] [varchar](255) NULL,
	[Division_Name] [varchar](255) NULL,
	[Nation_Name] [varchar](255) NULL,
	[Pseudo_Code] [varchar](255) NULL
) ON [PRIMARY]
GO
