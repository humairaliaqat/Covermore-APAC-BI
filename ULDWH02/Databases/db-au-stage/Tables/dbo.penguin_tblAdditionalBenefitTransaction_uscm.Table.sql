USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAdditionalBenefitTransaction_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAdditionalBenefitTransaction_uscm](
	[Id] [int] NOT NULL,
	[PolicyId] [int] NOT NULL,
	[BenefitId] [int] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[Status] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblAdditionalBenefitTransaction_uscm_BenefitID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblAdditionalBenefitTransaction_uscm_BenefitID] ON [dbo].[penguin_tblAdditionalBenefitTransaction_uscm]
(
	[BenefitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
