USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_SessionPartnerMetaData_AU_Temp]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_SessionPartnerMetaData_AU_Temp](
	[SessionToken] [nvarchar](50) NULL,
	[PartnerMetaData] [nvarchar](4000) NULL,
	[QuoteTransactionDateTime] [datetime] NULL
) ON [PRIMARY]
GO
