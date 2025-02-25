USE [db-au-star]
GO
/****** Object:  Table [dbo].[Dim_Consultant]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Consultant](
	[Consultant_SK] [int] IDENTITY(0,1) NOT NULL,
	[Outlet_SK] [int] NULL,
	[Consultant_ID] [varchar](50) NOT NULL,
	[Consultant_Username] [varchar](50) NULL,
	[Consultant_First_Name] [varchar](200) NULL,
	[Consultant_Surname] [varchar](200) NULL,
	[Consultant_Access_Level] [varchar](50) NOT NULL,
	[Consultant_Date_Of_Birth] [datetime] NULL,
	[Consultant_Accreditation_Date] [datetime] NULL,
	[Consultant_Status] [varchar](50) NOT NULL,
	[Domain_ID] [int] NOT NULL,
	[Valid_From_Date] [datetime] NOT NULL,
	[Valid_To_Date] [datetime] NULL,
	[Is_Latest] [char](1) NOT NULL,
	[Source_System_Code] [varchar](20) NOT NULL,
	[Create_Date] [datetime] NOT NULL,
	[Update_Date] [datetime] NULL,
	[Insert_Batch_ID] [int] NOT NULL,
	[Update_Batch_ID] [int] NULL,
 CONSTRAINT [Dim_Consultant_PK] PRIMARY KEY CLUSTERED 
(
	[Consultant_SK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
