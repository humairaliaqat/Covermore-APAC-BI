USE [db-au-actuary]
GO
/****** Object:  Table [ws].[~GLMFactors]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[~GLMFactors](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Factor Name] [varchar](255) NULL,
	[Factor Level] [varchar](500) NULL,
	[Estimate Value] [decimal](30, 10) NULL,
 CONSTRAINT [PK_GLMFactors] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_factor]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_factor] ON [ws].[~GLMFactors]
(
	[Factor Name] ASC,
	[Factor Level] ASC
)
INCLUDE([Estimate Value]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
