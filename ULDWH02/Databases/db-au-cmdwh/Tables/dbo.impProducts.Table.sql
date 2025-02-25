USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impProducts]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impProducts](
	[id] [smallint] NOT NULL,
	[code] [nvarchar](100) NULL,
	[plan_code] [nvarchar](50) NULL,
	[product] [nvarchar](50) NULL,
 CONSTRAINT [pk_impProducts] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
