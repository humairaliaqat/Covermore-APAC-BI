USE [db-au-cmdwh]
GO
/****** Object:  PartitionFunction [ifts_comp_fragment_partition_function_19FB42BC]    Script Date: 24/02/2025 12:39:33 PM ******/
CREATE PARTITION FUNCTION [ifts_comp_fragment_partition_function_19FB42BC](varbinary(128)) AS RANGE LEFT FOR VALUES (0x0037003000300030003300340036, 0x006E006E003200310033003900350035)
GO
