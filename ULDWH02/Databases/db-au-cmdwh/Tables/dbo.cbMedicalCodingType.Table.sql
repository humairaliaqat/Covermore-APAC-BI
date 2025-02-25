USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbMedicalCodingType]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbMedicalCodingType](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Tag] [varchar](100) NULL,
	[Type] [nvarchar](300) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cbMedicalCodingType_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cbMedicalCodingType_BIRowID] ON [dbo].[cbMedicalCodingType]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbMedicalCodingType_Tag]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbMedicalCodingType_Tag] ON [dbo].[cbMedicalCodingType]
(
	[Tag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
