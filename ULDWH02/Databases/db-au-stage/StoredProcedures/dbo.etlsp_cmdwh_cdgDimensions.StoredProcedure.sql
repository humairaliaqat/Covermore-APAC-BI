USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cdgDimensions]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_cdgDimensions]
as
begin
/*
20150106, LS, create
20150825, LT, removes accent from Country name from cdg_Country_au
20170525, VL, update for new table schema 			
20180111, VL, 1. backup existing dimension tables to [bhdwh03].[db-au-backup]
			  2. point source to new linked server [WAREHOUSEV2.POWEREDBYCOVERMORE.COM] analytics data warehouse 
				 for dimension tables 
				  * DimBusinessUnit
				  * DimProduct
				  * DimCampaign
				  * DimConstruct
				  * DimOffer
20180124, RL, pointing data source to the new linked server for cdgRegion
20180124, RL, cdgChannel and cdgDestination are no longer updated
*/


    set nocount on


    if object_id('[db-au-cmdwh]..cdgBusinessUnit') is null
    begin

        create table [db-au-cmdwh]..cdgBusinessUnit
        (
            BIRowID int not null identity(1,1),
            BusinessUnitID int not null,
            BusinessUnit nvarchar(255) null,
            Domain nvarchar(255) null,
			[Partner] nvarchar(255) null,
			Currency nvarchar(255) null
        )
        
        create clustered index idx_cdgBusinessUnit_main on [db-au-cmdwh]..cdgBusinessUnit(BIRowID)
        create nonclustered index idx_cdgBusinessUnit_id on [db-au-cmdwh]..cdgBusinessUnit(BusinessUnitID) include(BusinessUnit,Domain)
        
    end
	
    merge into [db-au-cmdwh]..cdgBusinessUnit with(tablock) t
    -- using cdg_business_units_AU s on t.BusinessUnitID = s.id
	using cdg_DimBusinessUnit_AU s on t.BusinessUnitID = s.DimBusinessUnitID
        
    when matched then
        update
        set
            BusinessUnit = s.BusinessUnitName,	-- s.business_unit,
            Domain = s.Domain,
			[Partner] = s.[Partner],
			Currency = s.Currency
            
    when not matched by target then 
        insert
        (
            BusinessUnitID,
            BusinessUnit,
            Domain,
			[Partner],
			Currency
        )
        values
        (
            s.DimBusinessUnitID,	-- s.id,
            s.BusinessUnitName,		-- s.business_unit,
            s.Domain,
			s.[Partner],
			s.Currency
        )
    ;


    if object_id('[db-au-cmdwh]..cdgCampaign') is null
    begin
    
        create table [db-au-cmdwh]..cdgCampaign
        (
            BIRowID int not null identity(1,1),
            CampaignID int not null,
            Campaign nvarchar(255) null,
			BusinessUnitID int null,
			PathType nchar(1) null
        )

        create clustered index idx_cdgCampaign_main on [db-au-cmdwh]..cdgCampaign(BIRowID)
        create nonclustered index idx_cdgCampaign_id on [db-au-cmdwh]..cdgCampaign(CampaignID) include(Campaign)
        
    end
    
    merge into [db-au-cmdwh]..cdgCampaign with(tablock) t
	using cdg_DimCampaign_AU s on t.CampaignID = s.DimCampaignID 
        
    when matched then
        update
        set
            Campaign = s.CampaignName	-- s.campaign,
            
    when not matched by target then 
        insert
        (
            CampaignID,
            Campaign
        )
        values
        (
            s.DimCampaignID,	-- s.id,
            s.CampaignName		-- s.campaign,
        )
    ;
    
    if object_id('[db-au-cmdwh]..cdgConstruct') is null
    begin
    
        create table [db-au-cmdwh]..cdgConstruct
        (
            BIRowID int not null identity(1,1),
            ConstructID int not null,
            Construct nvarchar(255) null
        )
    
        create clustered index idx_cdgConstruct_main on [db-au-cmdwh]..cdgConstruct(BIRowID)
        create nonclustered index idx_cdgConstruct_id on [db-au-cmdwh]..cdgConstruct(ConstructID) include(Construct)
        
    end

    merge into [db-au-cmdwh]..cdgConstruct with(tablock) t
	using cdg_DimConstruct_AU s on t.ConstructID = s.DimConstructID 
        
    when matched then
        update
        set
            Construct = s.ConstructName	-- s.construct
            
    when not matched by target then 
        insert
        (
            ConstructID,
            Construct
        )
        values
        (
            s.DimConstructID,	-- s.id,
            s.ConstructName		-- s.construct
        )
    ;
    
	-- 20180124, RL, source table DimCovermoreCountry target table cdgDestination
	-- cdgquote2.public.analytics_sessions.destination_country_id has been NULL since Jun 2015
	-- this is an issue of Innate analytics_sessions
	-- therefore, dimDestination is actually not used
	-- destination_country_id can't be used to merge data between cdgDestination and DimCovermoreCountry as id has changed by Innate for this table
	-- destination_country_code should be used for merget the destination table between cdgDestination and DimCovermoreCountry in the new solution

    if object_id('[db-au-cmdwh]..cdgOffer') is null
    begin
    
        create table [db-au-cmdwh]..cdgOffer
        (
            BIRowID int not null identity(1,1),
            OfferID int not null,
            Offer nvarchar(255) null
        )
    
        create clustered index idx_cdgOffer_main on [db-au-cmdwh]..cdgOffer(BIRowID)
        create nonclustered index idx_cdgOffer_id on [db-au-cmdwh]..cdgOffer(OfferID) include(Offer)
        
    end

    merge into [db-au-cmdwh]..cdgOffer with(tablock) t
	using cdg_DimOffer_AU s on t.OfferID = s.DimOfferID	-- s.id
        
    when matched then
        update
        set
            Offer = s.OfferName		-- s.offer
            
    when not matched by target then 
        insert
        (
            OfferID,
            Offer
        )
        values
        (
            s.DimOfferID,	-- s.id,
            s.OfferName		-- s.offer	
        )
    ;
    

    if object_id('[db-au-cmdwh]..cdgProduct') is null
    begin
    
        create table [db-au-cmdwh]..cdgProduct
        (
            BIRowID int not null identity(1,1),
            ProductID int not null,
            Product nvarchar(100) null,
            ProductCode nvarchar(255) null,
            PlanCode nvarchar(255) null
        )
    
        create clustered index idx_cdgProduct_main on [db-au-cmdwh]..cdgProduct(BIRowID)
        create nonclustered index idx_cdgProduct_id on [db-au-cmdwh]..cdgProduct(ProductID) include(Product,ProductCode,PlanCode)
        
    end

    merge into [db-au-cmdwh]..cdgProduct with(tablock) t
	using cdg_DimProduct_AU s on t.ProductID = s.DimProductID
        
    when matched then
        update
        set
            Product = s.ProductName,		-- s.product,
            ProductCode = s.ProductCode,	-- s.code,
            PlanCode = s.PlanCode			-- s.plan_code
            
    when not matched by target then 
        insert
        (
            ProductID,
            Product,
            ProductCode,
            PlanCode
        )
        values
        (
            s.DimProductID,		-- s.id,
            s.ProductName,		-- s.product,
            s.ProductCode,		-- s.code,
            s.PlanCode			-- s.plan_code
        )
    ;


    if object_id('[db-au-cmdwh]..cdgRegion') is null
    begin
    
        create table [db-au-cmdwh]..cdgRegion
        (
            BIRowID int not null identity(1,1),
            RegionID int not null,
            Region nvarchar(4000) null
        )
    
        create clustered index idx_cdgRegion_main on [db-au-cmdwh]..cdgRegion(BIRowID)
        create nonclustered index idx_cdgRegion_id on [db-au-cmdwh]..cdgRegion(RegionID) include(Region)
        
    end
    
    merge into [db-au-cmdwh]..cdgRegion with(tablock) t
	using cdg_DimRegion_AU s on t.RegionID = s.DimRegionID
        
    when matched then
        update
        set
            Region = s.RegionName
            
    when not matched by target then 
        insert
        (
            RegionID,
            Region
        )
        values
        (
            s.DimRegionID,
            s.RegionName
        )
    ;
    

end
GO
