USE [db-au-cmdwh]
GO
/****** Object:  PartitionFunction [ifts_comp_fragment_partition_function_026D0697]    Script Date: 24/02/2025 12:39:32 PM ******/
CREATE PARTITION FUNCTION [ifts_comp_fragment_partition_function_026D0697](varbinary(128)) AS RANGE LEFT FOR VALUES (0x0039003200380034003100320032, 0x006E006E0033003700320032003000350035)
GO
