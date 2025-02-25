USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impPolicyTraveller]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impPolicyTraveller](
	[BIRowID] [bigint] IDENTITY(0,1) NOT NULL,
	[PolicyIDKey] [nvarchar](50) NULL,
	[identifier] [nvarchar](50) NULL,
	[isPrimary] [bit] NULL,
	[title] [nvarchar](50) NULL,
	[firstName] [nvarchar](50) NULL,
	[lastName] [nvarchar](50) NULL,
	[dateOfBirth] [date] NULL,
	[age] [int] NULL,
	[chargeRate] [money] NULL,
	[personalIdentifiers] [nvarchar](255) NULL,
	[isAdult] [bit] NULL,
	[isChargeable] [bit] NULL,
	[treatAsAdult] [bit] NULL,
	[acceptedOffer] [bit] NULL,
	[isPlaceholderAge] [bit] NULL,
	[batchID] [int] NULL,
 CONSTRAINT [pk_impPolicyTraveller] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impPolicyTraveller_identifier]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impPolicyTraveller_identifier] ON [dbo].[impPolicyTraveller]
(
	[identifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impPolicyTraveller_PolicyIDKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impPolicyTraveller_PolicyIDKey] ON [dbo].[impPolicyTraveller]
(
	[PolicyIDKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
