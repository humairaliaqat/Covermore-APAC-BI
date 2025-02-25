USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usr_DTCStaffLeaveTaken]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usr_DTCStaffLeaveTaken](
	[LineID] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](1) NULL,
	[Level 1] [smallint] NULL,
	[ID] [smallint] NULL,
	[Full Name] [varchar](100) NULL,
	[Leave Type Descripion] [varchar](20) NULL,
	[Leave Start Date] [datetime] NULL,
	[Leave End Date] [datetime] NULL,
	[Date Paid] [datetime] NULL,
	[Units Taken] [real] NULL,
	[Leave Reason Description] [varchar](50) NULL,
 CONSTRAINT [PK_usr_DTCStaffLeaveTaken] PRIMARY KEY CLUSTERED 
(
	[LineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
