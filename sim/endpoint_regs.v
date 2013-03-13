`define ADDR_EP_ECR                    7'h0
`define EP_ECR_PORTID_OFFSET 0
`define EP_ECR_PORTID 32'h0000001f
`define EP_ECR_RST_CNT_OFFSET 5
`define EP_ECR_RST_CNT 32'h00000020
`define EP_ECR_TX_EN_OFFSET 6
`define EP_ECR_TX_EN 32'h00000040
`define EP_ECR_RX_EN_OFFSET 7
`define EP_ECR_RX_EN 32'h00000080
`define EP_ECR_FEAT_VLAN_OFFSET 24
`define EP_ECR_FEAT_VLAN 32'h01000000
`define EP_ECR_FEAT_DMTD_OFFSET 25
`define EP_ECR_FEAT_DMTD 32'h02000000
`define EP_ECR_FEAT_PTP_OFFSET 26
`define EP_ECR_FEAT_PTP 32'h04000000
`define EP_ECR_FEAT_DPI_OFFSET 27
`define EP_ECR_FEAT_DPI 32'h08000000
`define ADDR_EP_TSCR                   7'h4
`define EP_TSCR_EN_TXTS_OFFSET 0
`define EP_TSCR_EN_TXTS 32'h00000001
`define EP_TSCR_EN_RXTS_OFFSET 1
`define EP_TSCR_EN_RXTS 32'h00000002
`define EP_TSCR_CS_START_OFFSET 2
`define EP_TSCR_CS_START 32'h00000004
`define EP_TSCR_CS_DONE_OFFSET 3
`define EP_TSCR_CS_DONE 32'h00000008
`define ADDR_EP_RFCR                   7'h8
`define EP_RFCR_A_RUNT_OFFSET 0
`define EP_RFCR_A_RUNT 32'h00000001
`define EP_RFCR_A_GIANT_OFFSET 1
`define EP_RFCR_A_GIANT 32'h00000002
`define EP_RFCR_A_HP_OFFSET 2
`define EP_RFCR_A_HP 32'h00000004
`define EP_RFCR_KEEP_CRC_OFFSET 3
`define EP_RFCR_KEEP_CRC 32'h00000008
`define EP_RFCR_HPAP_OFFSET 4
`define EP_RFCR_HPAP 32'h00000ff0
`define EP_RFCR_MRU_OFFSET 12
`define EP_RFCR_MRU 32'h03fff000
`define ADDR_EP_VCR0                   7'hc
`define EP_VCR0_QMODE_OFFSET 0
`define EP_VCR0_QMODE 32'h00000003
`define EP_VCR0_FIX_PRIO_OFFSET 2
`define EP_VCR0_FIX_PRIO 32'h00000004
`define EP_VCR0_PRIO_VAL_OFFSET 4
`define EP_VCR0_PRIO_VAL 32'h00000070
`define EP_VCR0_PVID_OFFSET 16
`define EP_VCR0_PVID 32'h0fff0000
`define ADDR_EP_VCR1                   7'h10
`define EP_VCR1_OFFSET_OFFSET 0
`define EP_VCR1_OFFSET 32'h000003ff
`define EP_VCR1_DATA_OFFSET 10
`define EP_VCR1_DATA 32'h0ffffc00
`define ADDR_EP_PFCR0                  7'h14
`define EP_PFCR0_MM_ADDR_OFFSET 0
`define EP_PFCR0_MM_ADDR 32'h0000003f
`define EP_PFCR0_MM_WRITE_OFFSET 6
`define EP_PFCR0_MM_WRITE 32'h00000040
`define EP_PFCR0_ENABLE_OFFSET 7
`define EP_PFCR0_ENABLE 32'h00000080
`define EP_PFCR0_MM_DATA_MSB_OFFSET 8
`define EP_PFCR0_MM_DATA_MSB 32'hffffff00
`define ADDR_EP_PFCR1                  7'h18
`define EP_PFCR1_MM_DATA_LSB_OFFSET 0
`define EP_PFCR1_MM_DATA_LSB 32'h00000fff
`define ADDR_EP_TCAR                   7'h1c
`define EP_TCAR_PCP_MAP_OFFSET 0
`define EP_TCAR_PCP_MAP 32'h00ffffff
`define ADDR_EP_FCR                    7'h20
`define EP_FCR_RXPAUSE_OFFSET 0
`define EP_FCR_RXPAUSE 32'h00000001
`define EP_FCR_TXPAUSE_OFFSET 1
`define EP_FCR_TXPAUSE 32'h00000002
`define EP_FCR_RXPAUSE_802_1Q_OFFSET 2
`define EP_FCR_RXPAUSE_802_1Q 32'h00000004
`define EP_FCR_TXPAUSE_802_1Q_OFFSET 3
`define EP_FCR_TXPAUSE_802_1Q 32'h00000008
`define EP_FCR_TX_THR_OFFSET 8
`define EP_FCR_TX_THR 32'h0000ff00
`define EP_FCR_TX_QUANTA_OFFSET 16
`define EP_FCR_TX_QUANTA 32'hffff0000
`define ADDR_EP_MACH                   7'h24
`define ADDR_EP_MACL                   7'h28
`define ADDR_EP_MDIO_CR                7'h2c
`define EP_MDIO_CR_DATA_OFFSET 0
`define EP_MDIO_CR_DATA 32'h0000ffff
`define EP_MDIO_CR_ADDR_OFFSET 16
`define EP_MDIO_CR_ADDR 32'h00ff0000
`define EP_MDIO_CR_RW_OFFSET 31
`define EP_MDIO_CR_RW 32'h80000000
`define ADDR_EP_MDIO_ASR               7'h30
`define EP_MDIO_ASR_RDATA_OFFSET 0
`define EP_MDIO_ASR_RDATA 32'h0000ffff
`define EP_MDIO_ASR_PHYAD_OFFSET 16
`define EP_MDIO_ASR_PHYAD 32'h00ff0000
`define EP_MDIO_ASR_READY_OFFSET 31
`define EP_MDIO_ASR_READY 32'h80000000
`define ADDR_EP_IDCODE                 7'h34
`define ADDR_EP_DSR                    7'h38
`define EP_DSR_LSTATUS_OFFSET 0
`define EP_DSR_LSTATUS 32'h00000001
`define EP_DSR_LACT_OFFSET 1
`define EP_DSR_LACT 32'h00000002
`define ADDR_EP_DMCR                   7'h3c
`define EP_DMCR_EN_OFFSET 0
`define EP_DMCR_EN 32'h00000001
`define EP_DMCR_N_AVG_OFFSET 16
`define EP_DMCR_N_AVG 32'h0fff0000
`define ADDR_EP_DMSR                   7'h40
`define EP_DMSR_PS_VAL_OFFSET 0
`define EP_DMSR_PS_VAL 32'h00ffffff
`define EP_DMSR_PS_RDY_OFFSET 24
`define EP_DMSR_PS_RDY 32'h01000000
