USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblEMCNames_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblEMCNames_AU](
	[ContID] [int] NOT NULL,
	[ClientID] [int] NULL,
	[ContType] [char](1) NULL,
	[Title] [varchar](4) NULL,
	[Surname] [varchar](50) NULL,
	[Firstname] [varchar](25) NULL,
	[eMailResponse] [bit] NULL,
	[Sex] [varchar](6) NULL,
	[Height] [float] NULL,
	[Weight] [float] NULL,
	[Smoked] [bit] NULL,
	[Relationship] [varchar](25) NULL,
	[DOB] [varbinary](100) NULL,
	[Street] [varbinary](350) NULL,
	[Suburb] [varbinary](100) NULL,
	[State] [varbinary](100) NULL,
	[Pcode] [varbinary](100) NULL,
	[PhoneBH] [varbinary](100) NULL,
	[PhoneAH] [varbinary](100) NULL,
	[Fax] [varbinary](100) NULL,
	[Email] [varbinary](300) NULL,
	[MedicalRisk] [numeric](18, 2) NULL,
	[IsAnnualMultiTrip] [bit] NULL,
	[IsWinterSport] [bit] NULL,
	[RegionID] [int] NULL,
	[HashCode] [nvarchar](50) NULL,
	[ScreeningResultBase64] [nvarchar](500) NULL,
	[ScreeningVersion] [varchar](10) NULL,
	[OriginalHashCode] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_emc_EMC_tblEMCNames_AU_ClientID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_emc_EMC_tblEMCNames_AU_ClientID] ON [dbo].[emc_EMC_tblEMCNames_AU]
(
	[ClientID] ASC
)
INCLUDE([ContType],[MedicalRisk],[ScreeningVersion],[eMailResponse],[IsAnnualMultiTrip],[IsWinterSport]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
