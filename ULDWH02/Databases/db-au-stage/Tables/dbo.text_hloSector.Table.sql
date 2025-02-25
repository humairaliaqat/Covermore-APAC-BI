USE [db-au-stage]
GO
/****** Object:  Table [dbo].[text_hloSector]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[text_hloSector](
	[Airline Name] [varchar](50) NULL,
	[Type Description] [varchar](50) NULL,
	[Primary Document] [varchar](50) NULL,
	[Original Tkt Document No] [varchar](50) NULL,
	[Sector Refunded] [varchar](50) NULL,
	[Ticket has been Refunded] [varchar](50) NULL,
	[Adult Child Infant] [varchar](50) NULL,
	[Return One way] [varchar](50) NULL,
	[Date of Issue] [varchar](50) NULL,
	[Gross Fare] [varchar](50) NULL,
	[Net Fare] [varchar](50) NULL,
	[Levies] [varchar](50) NULL,
	[Carrier] [varchar](50) NULL,
	[Class Group] [varchar](50) NULL,
	[Flight Date] [varchar](50) NULL,
	[Tkt Stat] [varchar](50) NULL,
	[Sector Stat] [varchar](50) NULL,
	[PNR] [varchar](50) NULL,
	[Orig Country] [varchar](50) NULL,
	[Dest Country] [varchar](50) NULL,
	[Orig Dest] [varchar](50) NULL,
	[Tkt Orig Country] [varchar](50) NULL,
	[Turnaround City] [varchar](50) NULL,
	[Turnaround Country] [varchar](50) NULL,
	[Customer ID] [varchar](50) NULL,
	[Ci Agent Name] [varchar](50) NULL,
	[Ci State] [varchar](50) NULL,
	[Ag TC SP] [varchar](50) NULL,
	[Source_File_ID] [int] NULL,
	[Load_Date] [datetime] NULL
) ON [PRIMARY]
GO
