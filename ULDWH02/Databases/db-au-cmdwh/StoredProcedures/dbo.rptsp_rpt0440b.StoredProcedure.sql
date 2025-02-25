USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0440b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0440b] 
    @Country varchar(3),
    @PolicyNumber varchar(20)
    
as
begin
/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0440b
--  Author:         Linus Tor
--  Date Created:   20130626
--  Description:    This stored procedure returns traveller details. It will be called from a Webi report
--  Parameters:     @Country: Country is AU, NZ, MY, SG, or UK
--                  @PolicyNumber: valid policy number
--   
--  Change History: 20130626 - LT - Created
--                  20130731 - LS - remove conversion on left side of equation
--                                  remove order by, webi reordered the result set anyway
--
/****************************************************************************************************/								   

--uncomment to debug
/*
declare @Country varchar(3)
declare @PolicyNumber varchar(20)
select @Country = 'AU', @PolicyNumber = '50006698'
*/

    set nocount on

    SELECT
      Customer.CountryKey,
      Customer.PolicyNo,
      Customer.Title,
      Customer.FirstName,
      Customer.LastName,
      Customer.DateOfBirth,
      Customer.AgeAtDateOfIssue,
      Customer.AddressStreet,
      Customer.AddressSuburb,
      Customer.AddressState,
      Customer.AddressPostCode,
      Customer.Phone,
      Customer.WorkPhone,
      isNull(Customer.Email,'') as Email,
      Customer.isPrimary
    FROM
      Customer
    WHERE
      (
       Customer.PolicyNo  = @PolicyNumber
       AND
       Customer.CountryKey  = @Country
      )
    --ORDER BY Customer.isPrimary desc

end


GO
