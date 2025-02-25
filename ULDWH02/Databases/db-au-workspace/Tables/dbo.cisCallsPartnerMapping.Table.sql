USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cisCallsPartnerMapping]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisCallsPartnerMapping](
	[ApplicationName] [varchar](30) NOT NULL,
	[GatewayNumber] [nvarchar](50) NULL,
	[Group] [varchar](250) NULL
) ON [PRIMARY]
GO
