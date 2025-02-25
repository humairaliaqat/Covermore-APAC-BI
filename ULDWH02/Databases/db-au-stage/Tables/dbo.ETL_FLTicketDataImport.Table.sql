USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_FLTicketDataImport]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_FLTicketDataImport](
	[IssuedDate] [datetime] NULL,
	[T3] [nvarchar](255) NULL,
	[ExtID] [nvarchar](255) NULL,
	[FLTicketCountINT] [float] NULL,
	[FLTicketCountDOM] [float] NULL,
	[CMPolicyCountINT] [float] NULL,
	[CMPolicyCountDOM] [float] NULL,
	[PCC] [nvarchar](255) NULL
) ON [PRIMARY]
GO
