USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimContact_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimContact_AU](
	[DimContactID] [int] NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[PhoneNumber] [nvarchar](100) NOT NULL,
	[PhoneType] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
