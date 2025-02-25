USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_vClaimAssessmentOutcome]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_vClaimAssessmentOutcome](
	[ClaimKey] [varchar](40) NOT NULL,
	[ClaimNo] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[PolicyNumber] [varchar](50) NULL,
	[Paid] [money] NOT NULL,
	[EventDescription] [nvarchar](max) NULL,
	[EventLocation] [nvarchar](max) NOT NULL,
	[EventCountryName] [nvarchar](45) NULL,
	[AssessmentOutcome] [nvarchar](400) NULL,
	[Vulnerable Customer Information] [nvarchar](400) NULL,
	[Primary Denial Reason] [nvarchar](400) NULL,
	[Secondary Denial Reason] [nvarchar](400) NULL,
	[Tertiary Denial Reason] [nvarchar](400) NULL,
	[Respond Complaint Lodged] [nvarchar](400) NULL,
	[Claim Withdrawal Reason] [nvarchar](400) NULL,
	[FTG Applied] [nvarchar](400) NULL,
	[Indemnity Decision] [nvarchar](400) NULL,
	[PrimaryClaimant] [nvarchar](201) NULL,
	[e5URL] [varchar](149) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_vClaimAssessmentOutcome_ClaimKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_vClaimAssessmentOutcome_ClaimKey] ON [cng].[Tmp_vClaimAssessmentOutcome]
(
	[ClaimKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
