USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_FCStrikeRateTicketRawData_Jan18Sep19]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_FCStrikeRateTicketRawData_Jan18Sep19](
	[FCEGMNation] [nvarchar](50) NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[DocumentNumber] [varchar](100) NULL,
	[IssueDate] [date] NULL,
	[T3Code] [varchar](50) NULL,
	[InternationalTicketCount] [int] NOT NULL
) ON [PRIMARY]
GO
