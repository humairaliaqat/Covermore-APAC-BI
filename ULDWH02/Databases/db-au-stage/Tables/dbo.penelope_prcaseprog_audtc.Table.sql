USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_prcaseprog_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_prcaseprog_audtc](
	[kcaseprogid] [int] NOT NULL,
	[kagserid] [int] NOT NULL,
	[kproggroupid] [int] NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[billserv] [varchar](5) NULL,
	[cptcode] [nvarchar](50) NULL,
	[suggestedsessioncount] [int] NULL,
	[suggestedapptlength] [int] NULL,
	[iseapcaseservice] [varchar](5) NOT NULL,
	[defaultbookingtabattendee] [varchar](5) NOT NULL,
	[fahcsiaprog] [varchar](5) NOT NULL,
	[fahcsiaservicetype] [ntext] NULL,
	[isfrc] [varchar](5) NULL,
	[islegalass] [varchar](5) NULL,
	[hasparentagree] [varchar](5) NULL,
	[defaultbookingeventmembers] [varchar](5) NOT NULL,
	[defaultbookingservfilemembers] [varchar](5) NOT NULL,
	[fahcsiaprogenddate] [date] NULL,
	[hasfahcsiafeedback] [varchar](5) NULL,
	[kexempttypeidchilddefault] [int] NULL,
	[fahcsiasessfeedefaulttopaying] [varchar](5) NOT NULL,
	[kexempttypeidnofeedefault] [int] NULL,
	[defaultbookingworkers] [varchar](5) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
