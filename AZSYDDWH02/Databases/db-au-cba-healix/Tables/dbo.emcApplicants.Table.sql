USE [db-au-cba-healix]
GO
/****** Object:  Table [dbo].[emcApplicants]    Script Date: 20/02/2025 3:54:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emcApplicants](
	[ApplicantID] [int] IDENTITY(1,1) NOT NULL,
	[sessionid] [varchar](max) NULL,
	[Identifier] [nvarchar](4000) NULL,
	[FirstName] [varchar](max) NULL,
	[LastName] [varchar](max) NULL,
	[DOB] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
