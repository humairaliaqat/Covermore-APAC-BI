USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrFLConsultantNumber]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrFLConsultantNumber](
	[CountryKey] [varchar](2) NOT NULL,
	[AgencyCode] [varchar](7) NOT NULL,
	[OptimalConsultantNumber] [float] NULL
) ON [PRIMARY]
GO
