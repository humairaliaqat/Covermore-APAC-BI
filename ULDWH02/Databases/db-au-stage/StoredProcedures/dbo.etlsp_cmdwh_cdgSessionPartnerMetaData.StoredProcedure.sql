USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cdgSessionPartnerMetaData]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--create
CREATE 
procedure [dbo].[etlsp_cmdwh_cdgSessionPartnerMetaData]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Ratnesh Sharma
Date:           20180918
Prerequisite:   Requires ETL043_CDGQuote agent job successfully run
Description:    
Change History:
                20180918 - RS - Procedure created
						
*************************************************************************************************************************************/


if object_id('[db-au-cmdwh].dbo.cdgSessionPartnerMetaData') is null
begin
	create table [db-au-cmdwh].dbo.cdgSessionPartnerMetaData
	(
	[SessionToken] [uniqueidentifier] NOT NULL,
	[PartnerMetaData] [nvarchar](4000) NULL
    ) ON [PRIMARY]

	create nonclustered index idx_cdgSessionPartnerMetaData_SessionToken on [db-au-cmdwh].dbo.cdgSessionPartnerMetaData(SessionToken)
end
else
	delete a
	from
		[db-au-cmdwh].dbo.cdgSessionPartnerMetaData a
		inner join cdg_SessionPartnerMetaData_AU b on 
			a.SessionToken = b.SessionToken
			

insert [db-au-cmdwh].dbo.cdgSessionPartnerMetaData with(tablock)
(	
	[SessionToken],
	[PartnerMetaData],
	GroupCode                    ,
	GroupName                    ,
	SubGroupCode                 ,
	SubGroupName                 ,
	AgencyAlphaCode              ,
	AgencyName                   ,
	AgencyAddressStreet          ,
	AgencyAddressSuburb          ,
	AgencyAddressState           ,
	AgencyAddressPostCode        ,
	ConsultantUserName           ,
	ConsultantName               ,
	ConsultantEmailAddress       ,
	regionID                     ,
	countryID                    ,
	countryName                  ,
	iso3Code                     ,
	departureDate                ,
	returnDate                   ,
	totalTravelers               ,
	totalAdults                  ,
	totalChildren                ,
	isResident                   ,
	billingEmail                 ,
	billingPhone                 ,
	billingState                 ,
	age_1                        ,
	tripCost_1                   ,
	dateOfBirth_1                ,
	title_1                      ,
	firstName_1                  ,
	lastName_1                   ,
	age_2                        ,
	tripCost_2                   ,
	dateOfBirth_2                ,
	title_2                      ,
	firstName_2                  ,
	lastName_2                   ,
	age_3                        ,
	tripCost_3                   ,
	dateOfBirth_3                ,
	title_3                      ,
	firstName_3                  ,
	lastName_3                   ,
	age_4                        ,
	tripCost_4                   ,
	dateOfBirth_4                ,
	title_4                      ,
	firstName_4                  ,
	lastName_4                   ,
	age_5                        ,
	tripCost_5                   ,
	dateOfBirth_5                ,
	title_5                      ,
	firstName_5                  ,
	lastName_5                   ,
	age_6                        ,
	tripCost_6                   ,
	dateOfBirth_6                ,
	title_6                      ,
	firstName_6                  ,
	lastName_6                   ,
	age_7                        ,
	tripCost_7                   ,
	dateOfBirth_7                ,
	title_7                      ,
	firstName_7                  ,
	lastName_7                   ,
	age_8                        ,
	tripCost_8                   ,
	dateOfBirth_8                ,
	title_8                      ,
	firstName_8                  ,
	lastName_8                   ,
	age_9                        ,
	tripCost_9                   ,
	dateOfBirth_9                ,
	title_9                      ,
	firstName_9                  ,
	lastName_9                   ,
	age_10                       ,
	tripCost_10                  ,
	dateOfBirth_10               ,
	title_10                     ,
	firstName_10                 ,
	lastName_10                  
)
select
	[SessionToken],
	[PartnerMetaData],
	JSON_VALUE(PartnerMetaData,'$.GroupCode'),
	JSON_VALUE(PartnerMetaData,'$.GroupName'),
	JSON_VALUE(PartnerMetaData,'$.SubGroupCode'),
	JSON_VALUE(PartnerMetaData,'$.SubGroupName'),
	JSON_VALUE(PartnerMetaData,'$.AgencyAlphaCode'),
	JSON_VALUE(PartnerMetaData,'$.AgencyName'),
	JSON_VALUE(PartnerMetaData,'$.AgencyAddressStreet'),
	JSON_VALUE(PartnerMetaData,'$.AgencyAddressSuburb'),
	JSON_VALUE(PartnerMetaData,'$.AgencyAddressState'),
	JSON_VALUE(PartnerMetaData,'$.AgencyAddressPostCode'),
	JSON_VALUE(PartnerMetaData,'$.ConsultantUserName'),
	JSON_VALUE(PartnerMetaData,'$.ConsultantName'),
	JSON_VALUE(PartnerMetaData,'$.ConsultantEmailAddress'),
	JSON_VALUE(PartnerMetaData,'$.regionID'),
	JSON_VALUE(PartnerMetaData,'$.countryID'),
	JSON_VALUE(PartnerMetaData,'$.countryName'),
	JSON_VALUE(PartnerMetaData,'$.iso3Code'),
	--JSON_VALUE(PartnerMetaData,'$.departureDate'),
	case when isdate(JSON_VALUE(PartnerMetaData,'$.departureDate'))=1 then JSON_VALUE(PartnerMetaData,'$.departureDate') else null end,
	--JSON_VALUE(PartnerMetaData,'$.returnDate'),
	case when isdate(JSON_VALUE(PartnerMetaData,'$.returnDate'))=1 then JSON_VALUE(PartnerMetaData,'$.returnDate') else null end,
	JSON_VALUE(PartnerMetaData,'$.totalTravelers'),
	JSON_VALUE(PartnerMetaData,'$.totalAdults'),
	JSON_VALUE(PartnerMetaData,'$.totalChildren'),
	JSON_VALUE(PartnerMetaData,'$.isResident'),
	JSON_VALUE(PartnerMetaData,'$.billingEmail'),
	JSON_VALUE(PartnerMetaData,'$.billingPhone'),
	JSON_VALUE(PartnerMetaData,'$.billingState'),
	JSON_VALUE(PartnerMetaData,'$.age_1'),
	JSON_VALUE(PartnerMetaData,'$.tripCost_1'),
	--JSON_VALUE(PartnerMetaData,'$.dateOfBirth_1'),
	case when isdate(JSON_VALUE(PartnerMetaData,'$.dateOfBirth_1'))=1 then JSON_VALUE(PartnerMetaData,'$.dateOfBirth_1') else null end,
	JSON_VALUE(PartnerMetaData,'$.title_1'),
	JSON_VALUE(PartnerMetaData,'$.firstName_1'),
	JSON_VALUE(PartnerMetaData,'$.lastName_1'),
	JSON_VALUE(PartnerMetaData,'$.age_2'),
	JSON_VALUE(PartnerMetaData,'$.tripCost_2'),
	--JSON_VALUE(PartnerMetaData,'$.dateOfBirth_2'),
	case when isdate(JSON_VALUE(PartnerMetaData,'$.dateOfBirth_2'))=1 then JSON_VALUE(PartnerMetaData,'$.dateOfBirth_2') else null end,
	JSON_VALUE(PartnerMetaData,'$.title_2'),
	JSON_VALUE(PartnerMetaData,'$.firstName_2'),
	JSON_VALUE(PartnerMetaData,'$.lastName_2'),
	JSON_VALUE(PartnerMetaData,'$.age_3'),
	JSON_VALUE(PartnerMetaData,'$.tripCost_3'),
	--JSON_VALUE(PartnerMetaData,'$.dateOfBirth_3'),
	case when isdate(JSON_VALUE(PartnerMetaData,'$.dateOfBirth_3'))=1 then JSON_VALUE(PartnerMetaData,'$.dateOfBirth_3') else null end,
	JSON_VALUE(PartnerMetaData,'$.title_3'),
	JSON_VALUE(PartnerMetaData,'$.firstName_3'),
	JSON_VALUE(PartnerMetaData,'$.lastName_3'),
	JSON_VALUE(PartnerMetaData,'$.age_4'),
	JSON_VALUE(PartnerMetaData,'$.tripCost_4'),
	--JSON_VALUE(PartnerMetaData,'$.dateOfBirth_4'),
	case when isdate(JSON_VALUE(PartnerMetaData,'$.dateOfBirth_4'))=1 then JSON_VALUE(PartnerMetaData,'$.dateOfBirth_4') else null end,
	JSON_VALUE(PartnerMetaData,'$.title_4'),
	JSON_VALUE(PartnerMetaData,'$.firstName_4'),
	JSON_VALUE(PartnerMetaData,'$.lastName_4'),
	JSON_VALUE(PartnerMetaData,'$.age_5'),
	JSON_VALUE(PartnerMetaData,'$.tripCost_5'),
	--JSON_VALUE(PartnerMetaData,'$.dateOfBirth_5'),
	case when isdate(JSON_VALUE(PartnerMetaData,'$.dateOfBirth_5'))=1 then JSON_VALUE(PartnerMetaData,'$.dateOfBirth_5') else null end,
	JSON_VALUE(PartnerMetaData,'$.title_5'),
	JSON_VALUE(PartnerMetaData,'$.firstName_5'),
	JSON_VALUE(PartnerMetaData,'$.lastName_5'),
	JSON_VALUE(PartnerMetaData,'$.age_6'),
	JSON_VALUE(PartnerMetaData,'$.tripCost_6'),
	--JSON_VALUE(PartnerMetaData,'$.dateOfBirth_6'),
	case when isdate(JSON_VALUE(PartnerMetaData,'$.dateOfBirth_6'))=1 then JSON_VALUE(PartnerMetaData,'$.dateOfBirth_6') else null end,
	JSON_VALUE(PartnerMetaData,'$.title_6'),
	JSON_VALUE(PartnerMetaData,'$.firstName_6'),
	JSON_VALUE(PartnerMetaData,'$.lastName_6'),
	JSON_VALUE(PartnerMetaData,'$.age_7'),
	JSON_VALUE(PartnerMetaData,'$.tripCost_7'),
	--JSON_VALUE(PartnerMetaData,'$.dateOfBirth_7'),
	case when isdate(JSON_VALUE(PartnerMetaData,'$.dateOfBirth_7'))=1 then JSON_VALUE(PartnerMetaData,'$.dateOfBirth_7') else null end,
	JSON_VALUE(PartnerMetaData,'$.title_7'),
	JSON_VALUE(PartnerMetaData,'$.firstName_7'),
	JSON_VALUE(PartnerMetaData,'$.lastName_7'),
	JSON_VALUE(PartnerMetaData,'$.age_8'),
	JSON_VALUE(PartnerMetaData,'$.tripCost_8'),
	--JSON_VALUE(PartnerMetaData,'$.dateOfBirth_8'),
	case when isdate(JSON_VALUE(PartnerMetaData,'$.dateOfBirth_8'))=1 then JSON_VALUE(PartnerMetaData,'$.dateOfBirth_8') else null end,
	JSON_VALUE(PartnerMetaData,'$.title_8'),
	JSON_VALUE(PartnerMetaData,'$.firstName_8'),
	JSON_VALUE(PartnerMetaData,'$.lastName_8'),
	JSON_VALUE(PartnerMetaData,'$.age_9'),
	JSON_VALUE(PartnerMetaData,'$.tripCost_9'),
	--JSON_VALUE(PartnerMetaData,'$.dateOfBirth_9'),
	case when isdate(JSON_VALUE(PartnerMetaData,'$.dateOfBirth_9'))=1 then JSON_VALUE(PartnerMetaData,'$.dateOfBirth_9') else null end,
	JSON_VALUE(PartnerMetaData,'$.title_9'),
	JSON_VALUE(PartnerMetaData,'$.firstName_9'),
	JSON_VALUE(PartnerMetaData,'$.lastName_9'),
	JSON_VALUE(PartnerMetaData,'$.age_10'),
	JSON_VALUE(PartnerMetaData,'$.tripCost_10'),
	--JSON_VALUE(PartnerMetaData,'$.dateOfBirth_10'),
	case when isdate(JSON_VALUE(PartnerMetaData,'$.dateOfBirth_10'))=1 then JSON_VALUE(PartnerMetaData,'$.dateOfBirth_10') else null end,
	JSON_VALUE(PartnerMetaData,'$.title_10'),
	JSON_VALUE(PartnerMetaData,'$.firstName_10'),
	JSON_VALUE(PartnerMetaData,'$.lastName_10')
from
	cdg_SessionPartnerMetaData_AU
GO
