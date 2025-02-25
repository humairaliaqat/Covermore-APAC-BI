USE [db-au-stage]
GO
/****** Object:  Table [dbo].[DTProAccounting_pabatch_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTProAccounting_pabatch_audtc](
	[batch_ctrl_num] [varchar](16) NOT NULL,
	[created_date] [datetime] NULL,
	[created_user] [varchar](31) NOT NULL,
	[last_edit_date] [datetime] NULL,
	[batch_type] [varchar](4) NOT NULL,
	[last_edit_user] [varchar](31) NULL
) ON [PRIMARY]
GO
