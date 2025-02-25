USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[MedicalCoding_Payment]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicalCoding_Payment](
	[ClaimKey] [varchar](40) NOT NULL,
	[SectionKey] [varchar](40) NOT NULL,
	[Provider] [nvarchar](201) NULL,
	[Paid] [money] NULL,
	[Recovered] [money] NULL
) ON [PRIMARY]
GO
