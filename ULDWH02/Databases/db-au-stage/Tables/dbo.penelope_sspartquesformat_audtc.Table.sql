USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_sspartquesformat_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_sspartquesformat_audtc](
	[kpartquesformatid] [int] NOT NULL,
	[partquesformat] [nvarchar](30) NOT NULL,
	[kpartquestypeid] [int] NOT NULL
) ON [PRIMARY]
GO
