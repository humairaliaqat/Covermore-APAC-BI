USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vHLOLatestOutlet]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vHLOLatestOutlet]
AS 
     SELECT o.outletalphakey 
	 FROM   [db-au-cmdwh]..penoutlet o 
       INNER JOIN [db-au-cmdwh]..penoutlet lo 
               ON o.latestoutletkey = lo.outletkey 
                  AND o.outletstatus = 'Current' 
                  AND lo.outletstatus = 'Current' 
	 WHERE  1 = 1 
       AND o.outletstatus = 'Current' 
       AND ( lo.supergroupname = 'Stella' OR lo.groupname = 'Traveller''s Choice' ) 
       AND lo.outlettype = 'B2C' 
GO
