USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblSecurity_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblSecurity_AU](
	[UserID] [int] NOT NULL,
	[Login] [varchar](15) NULL,
	[FullName] [varchar](50) NULL,
	[SecLevel] [varchar](5) NULL,
	[Password] [varchar](10) NULL,
	[Initial] [char](2) NULL,
	[Phone] [varchar](15) NULL,
	[Email] [varchar](50) NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emc_EMC_tblSecurity_AU_Login]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_emc_EMC_tblSecurity_AU_Login] ON [dbo].[emc_EMC_tblSecurity_AU]
(
	[Login] ASC
)
INCLUDE([UserID],[FullName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_emc_EMC_tblSecurity_AU_UserID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_emc_EMC_tblSecurity_AU_UserID] ON [dbo].[emc_EMC_tblSecurity_AU]
(
	[UserID] ASC
)
INCLUDE([FullName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
