USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[emlMailbox]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emlMailbox](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MailboxName] [varchar](100) NOT NULL,
	[MailboxGroup] [varchar](100) NOT NULL,
	[Domain] [varchar](3) NOT NULL,
	[Company] [varchar](20) NOT NULL,
	[EmailAddress] [nvarchar](200) NOT NULL,
	[EmailAddressDisplayName] [nvarchar](200) NOT NULL,
	[isEnabled] [tinyint] NOT NULL,
	[Comments] [nvarchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
