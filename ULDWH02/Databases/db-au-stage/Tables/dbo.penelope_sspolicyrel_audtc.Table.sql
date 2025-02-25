USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_sspolicyrel_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_sspolicyrel_audtc](
	[kpolicyrelid] [int] NOT NULL,
	[policyrel] [nvarchar](25) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[relinscode] [nchar](3) NULL,
	[relinscode2] [nvarchar](3) NOT NULL
) ON [PRIMARY]
GO
