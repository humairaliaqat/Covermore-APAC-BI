USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrRPT1078_InvalidMember]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrRPT1078_InvalidMember](
	[CountryKey] [varchar](2) NULL,
	[PolicyKey] [varchar](50) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [datetime] NULL,
	[MemberNumber] [varchar](20) NULL,
	[NumericBody] [varchar](8) NULL,
	[CheckDigit] [varchar](1) NULL,
	[isValidMember] [int] NULL,
	[isPrimary] [int] NULL,
	[LastName] [varchar](100) NULL,
	[FirstName] [varchar](100) NULL,
	[GrossPremium] [money] NULL,
	[Timestamp] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrRPT1078_InvalidMember_PolicyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrRPT1078_InvalidMember_PolicyKey] ON [dbo].[usrRPT1078_InvalidMember]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrRPT1078_InvalidMember_IssueDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT1078_InvalidMember_IssueDate] ON [dbo].[usrRPT1078_InvalidMember]
(
	[IssueDate] ASC,
	[isValidMember] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
