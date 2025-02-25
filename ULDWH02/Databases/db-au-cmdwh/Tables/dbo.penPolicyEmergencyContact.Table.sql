USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyEmergencyContact]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyEmergencyContact](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[SurName] [nvarchar](100) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[MobilePhone] [varchar](50) NULL,
	[WorkPhone] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedDateUTC] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicEmergencyContact_PolicyTransactionKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicEmergencyContact_PolicyTransactionKey] ON [dbo].[penPolicyEmergencyContact]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyEmergencyContact_PolicyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyEmergencyContact_PolicyKey] ON [dbo].[penPolicyEmergencyContact]
(
	[PolicyKey] ASC,
	[PolicyNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
