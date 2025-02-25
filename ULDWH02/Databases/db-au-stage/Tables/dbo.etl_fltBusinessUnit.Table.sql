USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_fltBusinessUnit]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_fltBusinessUnit](
	[DimBusinessUnitId] [varchar](255) NULL,
	[BusinessUnitId] [varchar](255) NULL,
	[Business_Name] [varchar](255) NULL,
	[Legal_Entity_Name] [varchar](255) NULL,
	[Business_Open_Date] [varchar](255) NULL,
	[Business_Close_Date] [varchar](255) NULL,
	[BusinessType] [varchar](255) NULL,
	[T3_Code] [varchar](255) NULL,
	[Board_Report_Name] [varchar](255) NULL,
	[Pseudo_Code] [varchar](255) NULL,
	[Locality_Suburb] [varchar](255) NULL,
	[State_Province] [varchar](255) NULL,
	[Post_Code] [varchar](255) NULL,
	[Brand_Name] [varchar](255) NULL,
	[Discipline_Name] [varchar](255) NULL,
	[Village_Name] [varchar](255) NULL,
	[Division_Name] [varchar](255) NULL,
	[Region_Name] [varchar](255) NULL,
	[CountryNm] [varchar](255) NULL,
	[Company_Name] [varchar](255) NULL,
	[Nation_Name] [varchar](255) NULL,
	[Group_Name] [varchar](255) NULL,
	[Effective_From_Date] [varchar](255) NULL,
	[Effective_To_Date] [varchar](255) NULL,
	[Is_Current] [varchar](255) NULL
) ON [PRIMARY]
GO
