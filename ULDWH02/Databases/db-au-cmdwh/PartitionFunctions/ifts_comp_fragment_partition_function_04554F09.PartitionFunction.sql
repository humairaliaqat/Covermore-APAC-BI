USE [db-au-cmdwh]
GO
/****** Object:  PartitionFunction [ifts_comp_fragment_partition_function_04554F09]    Script Date: 24/02/2025 12:39:33 PM ******/
CREATE PARTITION FUNCTION [ifts_comp_fragment_partition_function_04554F09](varbinary(128)) AS RANGE LEFT FOR VALUES (0x0036003800310037003600340036, 0x006E006E0034003400330030003600300035)
GO
