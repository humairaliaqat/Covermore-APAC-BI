USE [db-au-star]
GO
/****** Object:  Table [dbo].[factPhoneSales]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factPhoneSales](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[DateSK] [int] NOT NULL,
	[EmployeeSK] [int] NOT NULL,
	[SupervisorSK] [int] NOT NULL,
	[TeamSK] [int] NOT NULL,
	[Premium] [float] NOT NULL,
	[SellPrice] [float] NOT NULL,
	[CreateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_factPhoneSales_BIRowID]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [idx_factPhoneSales_BIRowID] ON [dbo].[factPhoneSales]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factPhoneSales_DateSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factPhoneSales_DateSK] ON [dbo].[factPhoneSales]
(
	[DateSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
