USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_usrNARCallTarget]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_usrNARCallTarget](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](2) NOT NULL,
	[Month] [smalldatetime] NULL,
	[BDM] [nvarchar](100) NULL,
	[AppointmentTarget] [float] NULL
) ON [PRIMARY]
GO
