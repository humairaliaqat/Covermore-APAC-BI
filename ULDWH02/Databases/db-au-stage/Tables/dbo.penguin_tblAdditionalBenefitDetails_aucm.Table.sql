USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAdditionalBenefitDetails_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAdditionalBenefitDetails_aucm](
	[Id] [int] NOT NULL,
	[AdditionalBenefitTransactionId] [int] NOT NULL,
	[Data] [nvarchar](max) NULL,
	[Comments] [varchar](1000) NULL,
	[JsonData] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblAdditionalBenefitDetails_aucm_ABTId]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblAdditionalBenefitDetails_aucm_ABTId] ON [dbo].[penguin_tblAdditionalBenefitDetails_aucm]
(
	[AdditionalBenefitTransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
