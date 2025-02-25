USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Tickets_Issued_Shop_20230510]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tickets_Issued_Shop_20230510](
	[Date of Issue] [datetime] NULL,
	[Booking Business Unit Name] [nvarchar](255) NULL,
	[No of Tickets Issued] [float] NULL,
	[Number Of Travellers] [int] NULL,
	[Strike Rate] [float] NULL
) ON [PRIMARY]
GO
