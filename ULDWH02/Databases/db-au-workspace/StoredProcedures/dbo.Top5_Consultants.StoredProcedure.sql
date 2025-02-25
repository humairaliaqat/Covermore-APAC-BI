USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Top5_Consultants]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Sri Sailesh Pandravada
-- Name         [dbo].[Top5_Consultants] 
-- Create date: 2018-11-13
-- Description:	To retireve Top 5 Consultants base don policies Sold
-- =============================================
Create PROCEDURE [dbo].[Top5_Consultants]
	-- Add the parameters for the stored procedure here
	@Str_Date  DATE,
	@End_Date  DATE,
	@Grp_Name  nvarchar(50) = null
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--declare @rptStartDate date
    --declare @rptEndDate date

	--set @rptStartDate = @Str_Date
	--set @rptEndDate  = @End_Date

    -- Insert statements for procedure here
	select top 5 * from
	    (select 
	          B.AlphaCode As 'Agency Code',
	          B.OutletName as 'Agency Name', 
	          D.Consultant,
	          Sum(A.GrossPremium) as 'Sell Price',
	          Sum(A.BasePolicyCount) as 'Policy Count'
	    from 
			[db-au-cmdwh].[dbo].[penPolicyTransSummary] A 
			inner join [db-au-cmdwh].[dbo].[penOutlet]  B on A.OutletAlphaKey = B.OutletAlphaKey and
											   B.GroupName =  @Grp_Name and 
											   B.OutletStatus = 'Current'
				  			 
			cross apply ( select concat(FirstName, ' ',LastName) as Consultant from [db-au-cmdwh].[dbo].[penUser] C
							where A.UserKey = C.UserKey and UserStatus = 'Current'
			             )   D 
		where 
				A.PostingDate between @Str_Date and @End_Date
	    group by
				D.Consultant,B.AlphaCode,B.OutletName
	    )E
	   order by E.[Policy Count] DESC
	
END
GO
