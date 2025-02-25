USE [db-au-star]
GO
/****** Object:  Table [dbo].[dimDomainFX]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimDomainFX](
	[DomainFXSK] [bigint] IDENTITY(1,1) NOT NULL,
	[DomainSK] [int] NOT NULL,
	[DateSK] [bigint] NOT NULL,
	[FXCurrency] [varchar](50) NOT NULL,
	[FXRate] [decimal](25, 10) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimDomainFX_DomainFXSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [idx_dimDomainFX_DomainFXSK] ON [dbo].[dimDomainFX]
(
	[DomainFXSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimDomainFX_DateSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimDomainFX_DateSK] ON [dbo].[dimDomainFX]
(
	[DateSK] ASC,
	[DomainSK] ASC
)
INCLUDE([FXCurrency],[FXRate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
