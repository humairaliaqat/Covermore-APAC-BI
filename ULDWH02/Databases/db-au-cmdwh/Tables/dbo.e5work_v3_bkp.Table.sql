USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[e5work_v3_bkp]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5work_v3_bkp](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Domain] [varchar](5) NULL,
	[Country] [varchar](5) NULL,
	[Work_ID] [varchar](50) NULL,
	[Original_Work_ID] [uniqueidentifier] NOT NULL,
	[Parent_ID] [varchar](50) NULL,
	[Original_Parent_ID] [uniqueidentifier] NULL,
	[OriginWork_ID] [uniqueidentifier] NULL,
	[Reference] [int] NULL,
	[ClaimKey] [varchar](40) NULL,
	[AgencyCode] [nvarchar](20) NULL,
	[ClaimNumber] [int] NULL,
	[PolicyNumber] [varchar](50) NULL,
	[OnlineClaim] [bit] NULL,
	[ClaimType] [nvarchar](255) NULL,
	[ClaimDescription] [nvarchar](255) NULL,
	[SectionCheckList] [nvarchar](512) NULL,
	[ClaimantTitle] [nvarchar](50) NULL,
	[ClaimantFirstName] [nvarchar](100) NULL,
	[ClaimantSurname] [nvarchar](100) NULL,
	[WorkClassName] [nvarchar](100) NULL,
	[BusinessName] [nvarchar](100) NULL,
	[WorkType] [nvarchar](100) NULL,
	[GroupType] [nvarchar](100) NULL,
	[StatusName] [nvarchar](100) NULL,
	[AssignedDate] [datetime] NULL,
	[AssignedUserID] [nvarchar](100) NULL,
	[AssignedUser] [nvarchar](445) NULL,
	[CreationDate] [datetime] NOT NULL,
	[CreationUserID] [nvarchar](100) NULL,
	[CreationUser] [nvarchar](445) NULL,
	[CompletionDate] [datetime] NULL,
	[CompletionUserID] [nvarchar](100) NULL,
	[CompletionUser] [nvarchar](445) NULL,
	[DiarisedToDate] [datetime] NULL,
	[DueDate] [datetime] NULL,
	[SLAStartDate] [datetime] NULL,
	[SLAExpiryDate] [datetime] NULL,
	[SiteGroup] [int] NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[DeleteBatchID] [int] NULL
) ON [PRIMARY]
GO
