USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_UAPolicyData]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_UAPolicyData](
	[Nº voucher] [varchar](255) NULL,
	[Fecha de emisión] [varchar](255) NULL,
	[Fecha de vigencia] [varchar](255) NULL,
	[Fecha final] [varchar](255) NULL,
	[Días] [varchar](255) NULL,
	[Días cubiertos] [varchar](255) NULL,
	[Tipo de venta] [varchar](255) NULL,
	[Estado] [varchar](255) NULL,
	[Motivo] [varchar](255) NULL,
	[Producto] [varchar](255) NULL,
	[Organización Emisora] [varchar](255) NULL,
	[Cia Facturación] [varchar](255) NULL,
	[Cant Solicitantes] [varchar](255) NULL,
	[Destino] [varchar](255) NULL,
	[Tipo de cambio] [varchar](255) NULL,
	[Descuento] [varchar](255) NULL,
	[Comisión] [varchar](255) NULL,
	[Moneda local] [varchar](255) NULL,
	[Precio Bruto Local] [varchar](255) NULL,
	[Moneda lista] [varchar](255) NULL,
	[Precio Bruto] [varchar](255) NULL,
	[Precio - Neto Impuestos] [varchar](255) NULL,
	[Importe Comisión] [varchar](255) NULL,
	[Importe Neto] [varchar](255) NULL,
	[Precio - Neto Impuestos Lista] [varchar](255) NULL,
	[Importe Comisión Lista] [varchar](255) NULL,
	[Importe Neto Lista] [varchar](255) NULL,
	[País Emisión] [varchar](255) NULL,
	[Fecha Anulación] [varchar](255) NULL,
	[Tipo de cliente] [varchar](255) NULL,
	[Emisión Web] [varchar](255) NULL
) ON [PRIMARY]
GO
