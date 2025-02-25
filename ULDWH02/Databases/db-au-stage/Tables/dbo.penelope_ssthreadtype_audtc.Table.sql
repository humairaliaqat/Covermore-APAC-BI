USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssthreadtype_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssthreadtype_audtc](
	[kthreadtypeid] [int] NOT NULL,
	[threadtype] [nvarchar](100) NOT NULL,
	[allowauto] [varchar](5) NOT NULL,
	[usecancel] [varchar](5) NOT NULL,
	[kthreadclassid] [int] NOT NULL
) ON [PRIMARY]
GO
