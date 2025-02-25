USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrFinanceProductMap]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrFinanceProductMap](
	[CountryKey] [nvarchar](5) NULL,
	[ProductCode] [nvarchar](25) NULL,
	[PlanName] [nvarchar](50) NULL,
	[FinanceProductCode] [nvarchar](25) NULL,
	[OldFinanceProductCode] [nvarchar](25) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_main]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_main] ON [dbo].[usrFinanceProductMap]
(
	[CountryKey] ASC,
	[ProductCode] ASC,
	[PlanName] ASC
)
INCLUDE([FinanceProductCode],[OldFinanceProductCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
