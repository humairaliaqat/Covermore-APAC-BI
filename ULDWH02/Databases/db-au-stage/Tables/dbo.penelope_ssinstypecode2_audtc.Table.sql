USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssinstypecode2_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssinstypecode2_audtc](
	[kinstypecode2id] [int] NOT NULL,
	[instypecode2] [nvarchar](5) NOT NULL,
	[instypecode2desc] [nvarchar](70) NOT NULL
) ON [PRIMARY]
GO
