USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[MedicalCoding_Section]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicalCoding_Section](
	[ClaimKey] [varchar](40) NOT NULL,
	[SectionKey] [varchar](40) NOT NULL,
	[OperationalBenefitGroup] [varchar](12) NOT NULL,
	[BenefitCategory] [varchar](35) NOT NULL,
	[Estimate] [decimal](38, 6) NULL
) ON [PRIMARY]
GO
