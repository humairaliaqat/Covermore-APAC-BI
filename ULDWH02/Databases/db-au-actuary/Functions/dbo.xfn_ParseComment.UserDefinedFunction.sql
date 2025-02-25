USE [db-au-actuary]
GO
/****** Object:  UserDefinedFunction [dbo].[xfn_ParseComment]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[xfn_ParseComment](@comment [nvarchar](max))
RETURNS  TABLE (
	[AMTDurationOld] [nvarchar](max) NULL,
	[AMTDurationNew] [nvarchar](max) NULL,
	[PlanOld] [nvarchar](max) NULL,
	[PlanNew] [nvarchar](max) NULL,
	[EmailOld] [nvarchar](max) NULL,
	[EmailNew] [nvarchar](max) NULL,
	[MobileOld] [nvarchar](max) NULL,
	[MobileNew] [nvarchar](max) NULL,
	[PhoneOld] [nvarchar](max) NULL,
	[PhoneNew] [nvarchar](max) NULL,
	[StreetOld] [nvarchar](max) NULL,
	[StreetNew] [nvarchar](max) NULL,
	[SuburbOld] [nvarchar](max) NULL,
	[SuburbNew] [nvarchar](max) NULL,
	[PostCodeOld] [nvarchar](max) NULL,
	[PostCodeNew] [nvarchar](max) NULL,
	[DepartOld] [nvarchar](max) NULL,
	[DepartNew] [nvarchar](max) NULL,
	[ReturnOld] [nvarchar](max) NULL,
	[ReturnNew] [nvarchar](max) NULL,
	[DestinationOld] [nvarchar](max) NULL,
	[DestinationNew] [nvarchar](max) NULL,
	[PrimaryOld] [nvarchar](max) NULL,
	[PrimaryNew] [nvarchar](max) NULL,
	[TitleOld] [nvarchar](max) NULL,
	[TitleNew] [nvarchar](max) NULL,
	[NameOld] [nvarchar](max) NULL,
	[NameNew] [nvarchar](max) NULL,
	[DOBOld] [nvarchar](max) NULL,
	[DOBNew] [nvarchar](max) NULL,
	[MemberOld] [nvarchar](max) NULL,
	[MemberNew] [nvarchar](max) NULL,
	[VelocityOld] [nvarchar](max) NULL,
	[VelocityNew] [nvarchar](max) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [AutoCommentParser].[UserDefinedFunctions].[FormatEmail]
GO
