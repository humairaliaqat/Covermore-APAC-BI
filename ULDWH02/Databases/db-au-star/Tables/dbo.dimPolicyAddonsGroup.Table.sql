USE [db-au-star]
GO
/****** Object:  Table [dbo].[dimPolicyAddonsGroup]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimPolicyAddonsGroup](
	[PolicyAddonsGroupSK] [bigint] IDENTITY(1,1) NOT NULL,
	[PolicySK] [bigint] NULL,
	[AddonsGroup] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [cidx_dimPolicyAddonsGroup]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx_dimPolicyAddonsGroup] ON [dbo].[dimPolicyAddonsGroup]
(
	[PolicyAddonsGroupSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyAddonsGroup_PolicySK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [idx_dimPolicyAddonsGroup_PolicySK] ON [dbo].[dimPolicyAddonsGroup]
(
	[PolicySK] ASC
)
INCLUDE([AddonsGroup]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
