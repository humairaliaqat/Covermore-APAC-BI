USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOTP_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOTP_ukcm](
	[ID] [int] NOT NULL,
	[OutletTypeID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[EffectiveDate] [datetime] NULL,
	[DomainId] [int] NOT NULL,
	[SubGroupId] [int] NOT NULL
) ON [PRIMARY]
GO
