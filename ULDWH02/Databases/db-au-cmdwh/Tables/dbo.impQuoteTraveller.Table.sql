USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impQuoteTraveller]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impQuoteTraveller](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[QuoteIDKey] [nvarchar](50) NULL,
	[identifier] [nvarchar](50) NULL,
	[isPrimary] [bit] NULL,
	[age] [int] NULL,
	[gender] [nvarchar](50) NULL,
	[isAdult] [bit] NULL,
	[lastName] [nvarchar](50) NULL,
	[memberId] [nvarchar](50) NULL,
	[firstName] [nvarchar](50) NULL,
	[chargeRate] [numeric](10, 5) NULL,
	[dateOfBirth] [date] NULL,
	[isChargeable] [bit] NULL,
	[treatAsAdult] [bit] NULL,
	[acceptedOffer] [bit] NULL,
	[isPlaceholderAge] [bit] NULL,
	[memberPointsAccrualRate] [numeric](10, 5) NULL,
	[memberPointsAccrued] [int] NULL,
	[personalIdentifiers] [nvarchar](255) NULL,
	[CreateBatchID] [int] NULL,
 CONSTRAINT [pk_impQuoteTraveller] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impQuoteTraveller_identifier]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impQuoteTraveller_identifier] ON [dbo].[impQuoteTraveller]
(
	[identifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impQuoteTraveller_QuoteIDKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impQuoteTraveller_QuoteIDKey] ON [dbo].[impQuoteTraveller]
(
	[QuoteIDKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
