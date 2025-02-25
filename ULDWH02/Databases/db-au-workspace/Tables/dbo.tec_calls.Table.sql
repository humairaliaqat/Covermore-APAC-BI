USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tec_calls]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tec_calls](
	[Role] [varchar](16) NOT NULL,
	[CSQ] [varchar](40) NULL,
	[Agent] [nvarchar](50) NULL,
	[SessionID] [bigint] NULL,
	[ContactType] [varchar](50) NULL,
	[CallStartDateTime] [datetime] NULL,
	[Team] [varchar](7) NOT NULL,
	[RingTime] [int] NULL,
	[ConnectTime] [int] NULL,
	[TalkTime] [int] NULL,
	[IndonesiaFLag] [int] NULL
) ON [PRIMARY]
GO
