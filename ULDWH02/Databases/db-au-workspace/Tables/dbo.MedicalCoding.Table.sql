USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[MedicalCoding]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicalCoding](
	[ClaimKey] [varchar](40) NOT NULL,
	[ClaimNo] [int] NOT NULL,
	[LossDate] [date] NULL,
	[ClaimReceiptDate] [datetime] NULL,
	[EventCountryName] [nvarchar](45) NULL,
	[EventDescription] [nvarchar](max) NULL,
	[Claimant] [nvarchar](201) NULL,
	[Age] [int] NULL,
	[Gender] [nvarchar](1) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [date] NULL,
	[ProductCode] [nvarchar](50) NULL,
	[PlanCode] [varchar](50) NULL,
	[GroupName] [nvarchar](50) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[OutletName] [nvarchar](50) NULL,
	[MedicalAssistanceRef] [nvarchar](15) NULL,
	[UWCoverStatus] [nvarchar](100) NULL,
	[MRonFile] [varchar](8) NOT NULL,
	[EMCRef] [int] NULL,
	[ApplicationKey] [varchar](15) NULL,
	[ClaimStatus] [nvarchar](400) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
