USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_SessionPartnerMetaData_AU]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_SessionPartnerMetaData_AU](
	[SessionToken] [nvarchar](50) NULL,
	[PartnerMetaData] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
