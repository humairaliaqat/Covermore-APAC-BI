USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_consultant_uk]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_consultant_uk](
	[ID] [int] NOT NULL,
	[NAME] [varchar](50) NULL,
	[INITIALS] [varchar](4) NULL,
	[USERNAME] [varchar](50) NOT NULL,
	[PASSWORD] [varchar](50) NOT NULL,
	[CLALPHA] [varchar](7) NOT NULL,
	[ACCESSLEVEL] [int] NOT NULL,
	[APPROVALCODE] [varchar](50) NULL,
	[ACCREDITATION_NUMBER] [varchar](50) NULL,
	[ASICNUMBER] [varchar](50) NULL,
	[AGRDATE] [datetime] NULL,
	[EMAIL] [varchar](100) NULL,
	[PAYROLLID] [varchar](50) NULL,
	[Active] [bit] NOT NULL
) ON [PRIMARY]
GO
