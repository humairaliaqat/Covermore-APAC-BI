USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impPolicyDestinationAirportCode]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impPolicyDestinationAirportCode](
	[BIRowID] [bigint] IDENTITY(0,1) NOT NULL,
	[PolicyIDKey] [nvarchar](50) NULL,
	[destinationAirportCodes] [nvarchar](50) NULL,
	[batchID] [int] NULL,
 CONSTRAINT [pk_impPolicyDestinationAirportCode] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impPolicyDestinationAirportCode_PolicyIDKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impPolicyDestinationAirportCode_PolicyIDKey] ON [dbo].[impPolicyDestinationAirportCode]
(
	[PolicyIDKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
