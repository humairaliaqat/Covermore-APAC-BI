USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[claimassessments]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claimassessments](
	[ClaimNo] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[LossCountry] [nvarchar](45) NOT NULL,
	[FirstEstimate] [decimal](38, 6) NOT NULL,
	[InvestigationCost] [money] NOT NULL,
	[LegalCost] [money] NOT NULL,
	[FPPayments] [money] NOT NULL,
	[TPPayments] [money] NOT NULL,
	[PreAssessmentIncurred] [decimal](38, 6) NOT NULL,
	[PreInvestigationIncurred] [decimal](38, 6) NOT NULL,
	[PreDisputeIncurred] [decimal](38, 6) NOT NULL,
	[Incurred] [decimal](38, 6) NOT NULL,
	[Investigated] [int] NOT NULL,
	[Disputed] [int] NOT NULL,
	[AssessmentOutcome] [nvarchar](400) NULL
) ON [PRIMARY]
GO
