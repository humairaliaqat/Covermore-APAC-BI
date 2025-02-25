USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impBusinessUnits]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impBusinessUnits](
	[id] [smallint] NOT NULL,
	[business_unit] [nvarchar](100) NULL,
	[domain] [nvarchar](50) NULL,
	[partner] [nvarchar](100) NULL,
	[currency] [nvarchar](50) NULL,
 CONSTRAINT [pk_impBusinessUnits] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
