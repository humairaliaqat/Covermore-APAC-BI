USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyTransactionStatus_aucm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyTransactionStatus_aucm](
	[ID] [int] NOT NULL,
	[StatusDescription] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicyTransactionStatus_aucm_ID]    Script Date: 24/02/2025 5:08:06 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblPolicyTransactionStatus_aucm_ID] ON [dbo].[penguin_tblPolicyTransactionStatus_aucm]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
