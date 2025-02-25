USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impPaymentTypes]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impPaymentTypes](
	[id] [smallint] NOT NULL,
	[payment_type] [nvarchar](100) NULL,
 CONSTRAINT [pk_impPaymentTypes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
