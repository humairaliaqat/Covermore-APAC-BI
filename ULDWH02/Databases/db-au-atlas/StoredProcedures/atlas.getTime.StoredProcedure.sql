USE [db-au-atlas]
GO
/****** Object:  StoredProcedure [atlas].[getTime]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [atlas].[getTime]    
@EntityName varchar(100)

AS 
BEgin
Select  Flag,lastdatetime from [atlas].[JobConfig]
WHERE entityName=@EntityName
 
ENd
GO
