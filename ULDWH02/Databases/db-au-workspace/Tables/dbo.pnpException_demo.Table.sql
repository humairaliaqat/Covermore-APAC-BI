USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[pnpException_demo]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pnpException_demo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ExceptionNo] [int] NULL,
	[ExceptionIDName] [varchar](50) NULL,
	[ExceptionIDValue] [varchar](50) NULL,
	[ExceptionStatus] [int] NULL,
	[ServiceType] [varchar](50) NULL,
	[UserID] [int] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[ExceptionDetail] [varchar](1000) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
