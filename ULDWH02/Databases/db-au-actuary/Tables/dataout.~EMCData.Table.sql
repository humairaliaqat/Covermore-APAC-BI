USE [db-au-actuary]
GO
/****** Object:  Table [dataout].[~EMCData]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dataout].[~EMCData](
	[Domain] [varchar](2) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[TransactionNumber] [varchar](50) NULL,
	[TransactionType] [varchar](50) NULL,
	[TransactionStatus] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [datetime] NULL,
	[ApplicationID] [int] NOT NULL,
	[ApplicationType] [varchar](25) NULL,
	[MedicalRisk] [decimal](18, 2) NOT NULL,
	[Condition] [varchar](50) NULL,
	[ConditionStatus] [varchar](19) NULL,
	[MedicalScore] [numeric](18, 2) NULL,
	[GroupID] [int] NULL,
	[GroupStatus] [varchar](20) NULL,
	[GroupScore] [decimal](18, 2) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_EMCData_PolicyKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_EMCData_PolicyKey] ON [dataout].[~EMCData]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
