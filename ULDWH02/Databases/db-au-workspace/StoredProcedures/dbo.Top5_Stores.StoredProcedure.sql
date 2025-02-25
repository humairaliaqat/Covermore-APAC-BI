USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Top5_Stores]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Sri Sailesh Pandravada
-- Name         [dbo].[Top5_Stores] 
-- Create date: 2018-11-13
-- Description:	To retireve Top 5 Stores base don policies Sold
-- =============================================
Create PROCEDURE [dbo].[Top5_Stores]
	-- Add the parameters for the stored procedure here
	@Str_Date  DATE,
	@End_Date  DATE,
	@Grp_Name  nvarchar(50) = null
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	    -- Insert statements for procedure here
	select top 5 * from
	   (select 
	   B.AlphaCode As 'Agency Code',
	   B.OutletName as 'Agency Name', 
	   Sum(A.GrossPremium) as 'Sell Price',
	   Sum(A.BasePolicyCount) as 'Policy Count'
	   from 
			[db-au-cmdwh].[dbo].[penPolicyTransSummary] A 
			inner join  (Select   OutletAlphaKey,OutletName,AlphaCode  from [db-au-cmdwh].[dbo].[penOutlet] 
					where GroupName =  @Grp_Name and
					OutletStatus = 'Current') B	
	   
	   on A.OutletAlphaKey = B.OutletAlphaKey
	   where A.PostingDate between @Str_Date and @End_Date
	   group by B.AlphaCode,B.OutletName
	   ) C
	   order by C.[Policy Count] DESC
	
END
GO
