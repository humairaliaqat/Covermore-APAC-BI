USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_OfficeVibesCompany]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_OfficeVibesCompany](
	[Company] [varchar](100) NULL,
	[Division] [varchar](100) NULL,
	[Department] [varchar](100) NULL,
	[Sub Department] [varchar](100) NULL,
	[Team] [varchar](100) NULL
) ON [PRIMARY]
GO
