USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_SessionPartnerMetaData_AU_AG]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_SessionPartnerMetaData_AU_AG](
	[SessionToken] [nvarchar](50) NULL,
	[PartnerMetaData] [nvarchar](4000) NULL,
	[QuoteTransactionDateTime] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [NonClusteredIndex-20240831-025151]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20240831-025151] ON [dbo].[cdg_SessionPartnerMetaData_AU_AG]
(
	[SessionToken] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
