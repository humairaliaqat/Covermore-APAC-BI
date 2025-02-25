USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[CiscoCalls_MappingPeter_AU]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CiscoCalls_MappingPeter_AU](
	[APPLICATION] [nvarchar](255) NULL,
	[SCRIPT] [nvarchar](max) NULL,
	[TRIGGER] [nvarchar](max) NULL,
	[LAST SCRIPT APPLIED] [nvarchar](255) NULL,
	[Finesse] [nvarchar](255) NULL,
	[No Voicemail] [nvarchar](255) NULL,
	[Partner Name] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
