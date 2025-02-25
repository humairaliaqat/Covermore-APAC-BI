USE [db-au-star]
GO
/****** Object:  Table [dbo].[Dim_Outlet]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Outlet](
	[Outlet_SK] [int] IDENTITY(0,1) NOT NULL,
	[Outlet_ID] [varchar](50) NOT NULL,
	[Outlet_Desc] [varchar](200) NULL,
	[Alpha_Code] [varchar](50) NOT NULL,
	[Board_Level_Code] [varchar](50) NULL,
	[Board_Level_Desc] [varchar](200) NULL,
	[Super_Group_Code] [varchar](50) NULL,
	[Super_Group_Desc] [varchar](200) NULL,
	[Group_ID] [varchar](50) NOT NULL,
	[Group_Code] [varchar](50) NOT NULL,
	[Group_Desc] [varchar](200) NULL,
	[Sub_Group_ID] [varchar](50) NOT NULL,
	[Sub_Group_Code] [varchar](50) NOT NULL,
	[Sub_Group_Desc] [varchar](200) NULL,
	[FC_EGM_Nation_ID] [varchar](50) NOT NULL,
	[FC_EGM_Nation_Desc] [varchar](200) NULL,
	[FC_Nation_ID] [varchar](50) NOT NULL,
	[FC_Nation_Desc] [varchar](200) NULL,
	[FC_Area_ID] [varchar](50) NOT NULL,
	[FC_Area_Desc] [varchar](200) NULL,
	[Outlet_Type_ID] [varchar](50) NOT NULL,
	[Outlet_Type_Code] [varchar](50) NOT NULL,
	[Outlet_Status] [varchar](50) NOT NULL,
	[Branch_Name] [varchar](200) NULL,
	[State_Code] [varchar](50) NOT NULL,
	[State_Desc] [varchar](200) NULL,
	[Is_Latest] [char](1) NOT NULL,
	[Domain_ID] [int] NOT NULL,
	[Valid_From_Date] [datetime] NOT NULL,
	[Valid_To_Date] [datetime] NULL,
	[Source_System_Code] [varchar](20) NOT NULL,
	[Create_Date] [datetime] NOT NULL,
	[Update_Date] [datetime] NULL,
	[Sales_Force_SK] [int] NULL,
	[Insert_Batch_ID] [int] NOT NULL,
	[Update_Batch_ID] [int] NULL,
 CONSTRAINT [Dim_Outlet_PK] PRIMARY KEY CLUSTERED 
(
	[Outlet_SK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
