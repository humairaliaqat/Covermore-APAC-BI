USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[web_ProductReview]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[web_ProductReview](
	[ReviewID] [int] IDENTITY(0,1) NOT NULL,
	[ReviewTopic] [nvarchar](255) NULL,
	[ReviewDescription] [varchar](max) NULL,
	[ReviewDate] [datetime] NULL,
	[CustomerRating] [nvarchar](255) NULL,
	[UserLink] [nvarchar](255) NULL,
	[UserLocation] [nvarchar](255) NULL,
	[LabelSuccessfulValue] [nvarchar](255) NULL,
	[LabelDefaultValue] [nvarchar](255) NULL,
	[Code] [nvarchar](255) NULL,
	[Label] [nvarchar](255) NULL,
	[AbsRelevance] [numeric](16, 8) NULL,
	[PostContents] [varchar](max) NULL,
	[ClaimNo] [int] NULL,
	[PolicyNo] [int] NULL,
	[CaseRefNo] [int] NULL,
	[HashKey] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
