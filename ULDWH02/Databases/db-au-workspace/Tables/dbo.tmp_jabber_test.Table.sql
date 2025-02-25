USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_jabber_test]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_jabber_test](
	[to_jid] [nvarchar](200) NULL,
	[from_jid] [nvarchar](200) NULL,
	[sent_date] [datetime2](7) NOT NULL,
	[subject] [nvarchar](128) NULL,
	[thread_ID] [nvarchar](128) NULL,
	[msg_type] [nvarchar](1) NULL,
	[direction] [nvarchar](1) NULL,
	[body_len] [int] NOT NULL,
	[message_len] [int] NOT NULL,
	[body_string] [nvarchar](2000) NULL,
	[message_string] [nvarchar](1000) NULL,
	[body_text] [nvarchar](2000) NULL,
	[message_text] [nvarchar](1000) NULL,
	[history_flag] [nvarchar](1) NULL
) ON [PRIMARY]
GO
