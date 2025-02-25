USE [db-au-stage]
GO
/****** Object:  Table [dbo].[Tickets_Issued_Shop]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tickets_Issued_Shop](
	[Date of Issue] [datetime] NULL,
	[Alpha] [nvarchar](255) NULL,
	[Booking Business Unit Name] [nvarchar](255) NULL,
	[No of Tickets Issued] [float] NULL
) ON [PRIMARY]
GO
