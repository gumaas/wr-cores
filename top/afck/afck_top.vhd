
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.gn4124_core_pkg.all;
use work.gencores_pkg.all;
use work.wrcore_pkg.all;
use work.wr_fabric_pkg.all;
use work.wr_xilinx_pkg.all;
use work.etherbone_pkg.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.wishbone_pkg.all;


entity afck_top is
  generic
    (
      g_nic_usedma          : boolean := false;
      g_simulation          : integer := 0);
  port
    (
      clk_20m_vcxo_i        : in std_logic;    -- 20MHz VCXO clock


      gtp_clk_p_i           : in std_logic;  -- Dedicated clock for Xilinx GTP transceiver
      gtp_clk_n_i           : in std_logic;


      -- clk_stable_p_i    : in std_logic;
      -- clk_stable_n_i    : in std_logic;

      dac_sclk_o            : out std_logic;
      dac_din_o             : out std_logic;
      dac_cs1_n_o           : out std_logic;
      dac_cs2_n_o           : out std_logic;

      
      fpga_scl_b : inout std_logic;
      fpga_sda_b : inout std_logic;
      
      -- na dio
      -- spi_sclk_o : out std_logic;
      -- spi_ncs_o  : out std_logic;
      -- spi_mosi_o : out std_logic;
      -- spi_miso_i : in  std_logic := 'L';

      -- nie ma
      -- thermo_id : inout std_logic;      -- 1-Wire interface to DS18B20


      -------------------------------------------------------------------------
      -- SFP pins
      -------------------------------------------------------------------------

      sfp_txp_o           : out std_logic;
      sfp_txn_o           : out std_logic;

      sfp_rxp_i           : in std_logic;
      sfp_rxn_i           : in std_logic;

      sfp_mod_def0_b      : in    std_logic;  -- sfp detect
      sfp_mod_def1_b      : inout std_logic;  -- scl
      sfp_mod_def2_b      : inout std_logic;  -- sda
      sfp_rate_select_b   : inout std_logic;
      sfp_tx_fault_i      : in    std_logic;
      sfp_tx_disable_o    : out   std_logic;
      sfp_los_i           : in    std_logic;


      -------------------------------------------------------------------------
      -- Digital I/O FMC Pins
      -------------------------------------------------------------------------

     dio_clk_p_i : in std_logic;
     dio_clk_n_i : in std_logic;

     dio_n_i : in std_logic_vector(4 downto 0);
     dio_p_i : in std_logic_vector(4 downto 0);

     dio_n_o : out std_logic_vector(4 downto 0);
     dio_p_o : out std_logic_vector(4 downto 0);

     dio_oe_n_o    : out std_logic_vector(4 downto 0);
     dio_term_en_o : out std_logic_vector(4 downto 0);

     dio_onewire_b  : inout std_logic;
     dio_sdn_n_o    : out   std_logic;  -- this is for ??
     dio_sdn_ck_n_o : out   std_logic;

     dio_led_top_o : out std_logic;
     dio_led_bot_o : out std_logic;

     dio_scl_b : inout std_logic;
     dio_sda_b : inout std_logic;
      -- dio_GA signals conneected to ground on SPEC board.  

      -- test0_out   : out std_logic;
      -- test1_out   : out std_logic;

      -----------------------------------------
      --UART
      -----------------------------------------
      uart_rxd_i          : in  std_logic;
      uart_txd_o          : out std_logic
      );

end afck_top;

architecture rtl of afck_top is

  ------------------------------------------------------------------------------
  -- Components declaration
  ------------------------------------------------------------------------------

  -- component gn4124_core is
  --   port(
  --     ---------------------------------------------------------
  --     -- Control and status
  --     rst_n_a_i : in  std_logic;        -- Asynchronous reset from GN4124
  --     status_o  : out std_logic_vector(31 downto 0);  -- Core status output

  --     ---------------------------------------------------------
  --     -- P2L Direction
  --     --
  --     -- Source Sync DDR related signals
  --     p2l_clk_p_i  : in  std_logic;     -- Receiver Source Synchronous Clock+
  --     p2l_clk_n_i  : in  std_logic;     -- Receiver Source Synchronous Clock-
  --     p2l_data_i   : in  std_logic_vector(15 downto 0);  -- Parallel receive data
  --     p2l_dframe_i : in  std_logic;     -- Receive Frame
  --     p2l_valid_i  : in  std_logic;     -- Receive Data Valid
  --     -- P2L Control
  --     p2l_rdy_o    : out std_logic;     -- Rx Buffer Full Flag
  --     p_wr_req_i   : in  std_logic_vector(1 downto 0);  -- PCIe Write Request
  --     p_wr_rdy_o   : out std_logic_vector(1 downto 0);  -- PCIe Write Ready
  --     rx_error_o   : out std_logic;     -- Receive Error
  --     vc_rdy_i     : in  std_logic_vector(1 downto 0);  -- Virtual channel ready

  --     ---------------------------------------------------------
  --     -- L2P Direction
  --     --
  --     -- Source Sync DDR related signals
  --     l2p_clk_p_o  : out std_logic;  -- Transmitter Source Synchronous Clock+
  --     l2p_clk_n_o  : out std_logic;  -- Transmitter Source Synchronous Clock-
  --     l2p_data_o   : out std_logic_vector(15 downto 0);  -- Parallel transmit data
  --     l2p_dframe_o : out std_logic;     -- Transmit Data Frame
  --     l2p_valid_o  : out std_logic;     -- Transmit Data Valid
  --     -- L2P Control
  --     l2p_edb_o    : out std_logic;     -- Packet termination and discard
  --     l2p_rdy_i    : in  std_logic;     -- Tx Buffer Full Flag
  --     l_wr_rdy_i   : in  std_logic_vector(1 downto 0);  -- Local-to-PCIe Write
  --     p_rd_d_rdy_i : in  std_logic_vector(1 downto 0);  -- PCIe-to-Local Read Response Data Ready
  --     tx_error_i   : in  std_logic;     -- Transmit Error

  --     ---------------------------------------------------------
  --     -- Interrupt interface
  --     dma_irq_o : out std_logic_vector(1 downto 0);  -- Interrupts sources to IRQ manager
  --     irq_p_i   : in  std_logic;  -- Interrupt request pulse from IRQ manager
  --     irq_p_o   : out std_logic;  -- Interrupt request pulse to GN4124 GPIO

  --     ---------------------------------------------------------
  --     -- DMA registers wishbone interface (slave classic)
  --     dma_reg_clk_i   : in  std_logic;
  --     dma_reg_adr_i   : in  std_logic_vector(31 downto 0) := x"00000000";
  --     dma_reg_dat_i   : in  std_logic_vector(31 downto 0) := x"00000000";
  --     dma_reg_sel_i   : in  std_logic_vector(3 downto 0)  := x"0";
  --     dma_reg_stb_i   : in  std_logic                     := '0';
  --     dma_reg_we_i    : in  std_logic                     := '0';
  --     dma_reg_cyc_i   : in  std_logic                     := '0';
  --     dma_reg_dat_o   : out std_logic_vector(31 downto 0);
  --     dma_reg_ack_o   : out std_logic;
  --     dma_reg_stall_o : out std_logic;

  --     ---------------------------------------------------------
  --     -- CSR wishbone interface (master pipelined)
  --     csr_clk_i   : in  std_logic;
  --     csr_adr_o   : out std_logic_vector(31 downto 0);
  --     csr_dat_o   : out std_logic_vector(31 downto 0);
  --     csr_sel_o   : out std_logic_vector(3 downto 0);
  --     csr_stb_o   : out std_logic;
  --     csr_we_o    : out std_logic;
  --     csr_cyc_o   : out std_logic;
  --     csr_dat_i   : in  std_logic_vector(31 downto 0);
  --     csr_ack_i   : in  std_logic;
  --     csr_stall_i : in  std_logic;

  --     ---------------------------------------------------------
  --     -- DMA wishbone interface (master pipelined)
  --     dma_clk_i   : in  std_logic;
  --     dma_adr_o   : out std_logic_vector(31 downto 0);
  --     dma_dat_o   : out std_logic_vector(31 downto 0);
  --     dma_sel_o   : out std_logic_vector(3 downto 0);
  --     dma_stb_o   : out std_logic;
  --     dma_we_o    : out std_logic;
  --     dma_cyc_o   : out std_logic;
  --     dma_dat_i   : in  std_logic_vector(31 downto 0) := x"00000000";
  --     dma_ack_i   : in  std_logic                     := '0';
  --     dma_stall_i : in  std_logic                     := '0'
  --     );
  -- end component;  --  gn4124_core


  component afck_reset_gen
    port (
      clk_sys_i        : in  std_logic;
      rst_pcie_n_a_i   : in  std_logic;
      rst_button_n_a_i : in  std_logic;
      rst_n_o          : out std_logic);
  end component;

  component ext_pll_10_to_125m
    port (
      clk_ext_i     : in  std_logic;
      clk_ext_mul_o : out std_logic;
      rst_a_i       : in  std_logic);
  end component;

  component phy_icon
  port(
      control0    : inout std_logic_vector(35 downto 0)
    );
  end component;

  component phy_ila
  port (
      control     : inout std_logic_vector(35 downto 0);
      clk       : in std_logic;
      data      : in std_logic_vector(127 downto 0);
      trig0       : in std_logic_vector(31 downto 0)
    );
  end component;

  signal  chs_control   : std_logic_vector( 35 downto 0 );
  signal  chs_data    : std_logic_vector( 127 downto 0 );
  signal  phy_debug     : std_logic_vector( 127 downto 0 );
  signal  chs_trig    : std_logic_vector( 31 downto 0 );
  signal  debug_clk   : std_logic;

  --component chipscope_ila
  --  port (
  --    CONTROL : inout std_logic_vector(35 downto 0);
  --    CLK     : in    std_logic;
  --    TRIG0   : in    std_logic_vector(31 downto 0);
  --    TRIG1   : in    std_logic_vector(31 downto 0);
  --    TRIG2   : in    std_logic_vector(31 downto 0);
  --    TRIG3   : in    std_logic_vector(31 downto 0));
  --end component;

  --signal CONTROL : std_logic_vector(35 downto 0);
  --signal CLK     : std_logic;
  --signal TRIG0   : std_logic_vector(31 downto 0);
  --signal TRIG1   : std_logic_vector(31 downto 0);
  --signal TRIG2   : std_logic_vector(31 downto 0);
  --signal TRIG3   : std_logic_vector(31 downto 0);

  --component chipscope_icon
  --  port (
  --    CONTROL0 : inout std_logic_vector (35 downto 0));
  --end component;

  ------------------------------------------------------------------------------
  -- Constants declaration
  ------------------------------------------------------------------------------
  constant c_BAR0_APERTURE     : integer := 20;
  constant c_CSR_WB_SLAVES_NB  : integer := 1;
  constant c_DMA_WB_SLAVES_NB  : integer := 1;
  constant c_DMA_WB_ADDR_WIDTH : integer := 26;

  ------------------------------------------------------------------------------
  -- Signals declaration
  ------------------------------------------------------------------------------

  -- LCLK from GN4124 used as system clock
  signal l_clk : std_logic;

  -- Dedicated clock for GTP transceiver
  signal gtp_dedicated_clk : std_logic;

  -- P2L colck PLL status
  signal p2l_pll_locked : std_logic;

  -- Reset
  signal rst_a : std_logic;
  signal rst   : std_logic;

  -- DMA wishbone bus
  --signal dma_adr     : std_logic_vector(31 downto 0);
  --signal dma_dat_i   : std_logic_vector((32*c_DMA_WB_SLAVES_NB)-1 downto 0);
  --signal dma_dat_o   : std_logic_vector(31 downto 0);
  --signal dma_sel     : std_logic_vector(3 downto 0);
  --signal dma_cyc     : std_logic;  --_vector(c_DMA_WB_SLAVES_NB-1 downto 0);
  --signal dma_stb     : std_logic;
  --signal dma_we      : std_logic;
  --signal dma_ack     : std_logic;  --_vector(c_DMA_WB_SLAVES_NB-1 downto 0);
  --signal dma_stall   : std_logic;  --_vector(c_DMA_WB_SLAVES_NB-1 downto 0);
  signal ram_we      : std_logic_vector(0 downto 0);
  signal ddr_dma_adr : std_logic_vector(29 downto 0);

  signal irq_to_gn4124 : std_logic;

  -- SPI
  signal spi_slave_select : std_logic_vector(7 downto 0);


  signal pllout_clk_sys       : std_logic;
  signal pllout_clk_dmtd      : std_logic;
  signal pllout_clk_fb_pllref : std_logic;
  signal pllout_clk_fb_dmtd   : std_logic;

  signal clk_125m_pllref      : std_logic;
  signal clk_125m_buffed      : std_logic;
  signal clk_cs               : std_logic;

  signal clk_20m_vcxo_buf : std_logic;
  signal clk_62M5_ref  : std_logic;
  signal clk_sys          : std_logic;
  signal clk_dmtd         : std_logic;
  signal dac_rst_n        : std_logic;
  signal led_divider      : unsigned(23 downto 0);

  signal wrc_scl_o : std_logic;
  signal wrc_scl_i : std_logic;
  signal wrc_sda_o : std_logic;
  signal wrc_sda_i : std_logic;
  signal sfp_scl_o : std_logic;
  signal sfp_scl_i : std_logic;
  signal sfp_sda_o : std_logic;
  signal sfp_sda_i : std_logic;
  signal dio       : std_logic_vector(3 downto 0);

  signal dac_hpll_load_p1 : std_logic;
  signal dac_dpll_load_p1 : std_logic;
  signal dac_hpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_data    : std_logic_vector(15 downto 0);

  signal pps     : std_logic;
  signal pps_led : std_logic;

  signal phy_tx_data      : std_logic_vector(15 downto 0);
  signal phy_tx_k         : std_logic_vector(1 downto 0);
  signal phy_tx_disparity : std_logic;
  signal phy_tx_enc_err   : std_logic;
  signal phy_rx_data      : std_logic_vector(15 downto 0);
  signal phy_rx_rbclk     : std_logic;
  signal phy_rx_k         : std_logic_vector(1 downto 0);
  signal phy_rx_enc_err   : std_logic;
  signal phy_rx_bitslide  : std_logic_vector(4 downto 0);
  signal phy_rst          : std_logic;
  signal phy_loopen       : std_logic;



  signal dio_in  : std_logic_vector(4 downto 0);
  signal dio_out : std_logic_vector(4 downto 0);
  signal dio_clk : std_logic;

  signal local_reset_n  : std_logic;
  signal button1_synced : std_logic_vector(2 downto 0);

  signal genum_wb_out    : t_wishbone_master_out;
  signal genum_wb_in     : t_wishbone_master_in;
  signal genum_csr_ack_i : std_logic;

  signal wrc_slave_i : t_wishbone_slave_in;
  signal wrc_slave_o : t_wishbone_slave_out;

  signal owr_en : std_logic_vector(1 downto 0);
  signal owr_i  : std_logic_vector(1 downto 0);

  signal wb_adr : std_logic_vector(31 downto 0);  --c_BAR0_APERTURE-priv_log2_ceil(c_CSR_WB_SLAVES_NB+1)-1 downto 0);

  signal etherbone_rst_n   : std_logic;
  signal etherbone_src_out : t_wrf_source_out;
  signal etherbone_src_in  : t_wrf_source_in;
  signal etherbone_snk_out : t_wrf_sink_out;
  signal etherbone_snk_in  : t_wrf_sink_in;
  signal etherbone_wb_out  : t_wishbone_master_out;
  signal etherbone_wb_in   : t_wishbone_master_in;
  signal etherbone_cfg_in  : t_wishbone_slave_in;
  signal etherbone_cfg_out : t_wishbone_slave_out;

  signal local_reset, ext_pll_reset : std_logic;
  signal clk_ext, clk_ext_mul       : std_logic;
  signal clk_ref_div2               : std_logic;
  

  signal  pll0_lock   : std_logic;
  signal  pll1_lock   : std_logic;

  signal  clk_stable    : std_logic;
  signal  clk_stable_tmp  : std_logic;

begin

  local_reset <= not local_reset_n;

  -- U_Ext_PLL : ext_pll_10_to_125m
  --   port map (
  --     clk_ext_i     => clk_ext,
  --     clk_ext_mul_o => clk_ext_mul,
  --     rst_a_i       => ext_pll_reset);

  U_Extend_EXT_Reset : gc_extend_pulse
    generic map (
      g_width => 1000)
    port map (
      clk_i      => clk_sys,
      rst_n_i    => local_reset_n,
      pulse_i    => local_reset,
      extended_o => ext_pll_reset
    );


-- clock input buffers
  cmp_gtp_dedicated_clk_buf : IBUFDS_GTE2
    port map (
      I           => gtp_clk_p_i,
      IB          => gtp_clk_n_i,
      O           => gtp_dedicated_clk,
      ODIV2       => open,
      CEB         => '0'
      );

  -- cmp_stable_clk_buff : IBUFDS_GTE2
  --   port map (
  --     O           => clk_stable_tmp,
  --     ODIV2       => open,
  --     CEB         => '0',
  --     I           => clk_stable_p_i,
  --     IB          => clk_stable_n_i
  --     );


  -- global clock buffer
  cmp_clk_vcxo : IBUFG
    generic map (
      IBUF_LOW_PWR  => true,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD    => "DEFAULT"
    )
    port map (
      I             => clk_20m_vcxo_i,  -- Diff_p buffer input (connect directly to top-level port)
      O             => clk_20m_vcxo_buf                      -- Buffer output
    );


  -- global clock buffer for 125MHz clk (so it could be used in gtx and system)
  cmp_clk_ref_buf : BUFG
    port map (
      I           => gtp_dedicated_clk,
      O           => clk_125m_buffed
    );

  cmp_clk_stab_buf : BUFG
    port map (
      I           => clk_stable_tmp,
      O           => clk_stable
    );

    
    -- clk_stable <= clk_sys;

  cmp_sys_clk_pll : PLL_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",
      CLK_FEEDBACK       => "CLKFBOUT",
      COMPENSATION       => "INTERNAL",
      DIVCLK_DIVIDE      => 1,
      CLKFBOUT_MULT      => 8,
      CLKFBOUT_PHASE     => 0.000,
      CLKOUT0_DIVIDE     => 16,         -- 62.5 MHz
      CLKOUT0_PHASE      => 0.000,
      CLKOUT0_DUTY_CYCLE => 0.500,
      CLKOUT1_DIVIDE     => 4,         -- 250 MHz
      CLKOUT1_PHASE      => 0.000,
      CLKOUT1_DUTY_CYCLE => 0.500,
      CLKOUT2_DIVIDE     => 16,
      CLKOUT2_PHASE      => 0.000,
      CLKOUT2_DUTY_CYCLE => 0.500,
      CLKIN_PERIOD       => 8.0,
      REF_JITTER         => 0.016
    )
    port map (
      CLKFBOUT => pllout_clk_fb_pllref,
      CLKOUT0  => pllout_clk_sys,
      CLKOUT1  => clk_cs,
      CLKOUT2  => open,
      CLKOUT3  => open,
      CLKOUT4  => open,
      CLKOUT5  => open,
      LOCKED   => pll0_lock,
      RST      => '0',
      CLKFBIN  => pllout_clk_fb_pllref,
      CLKIN    => clk_125m_buffed
    );     -- 125 MHz

  cmp_dmtd_clk_pll : PLL_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",
      CLK_FEEDBACK       => "CLKFBOUT",
      COMPENSATION       => "INTERNAL",
      DIVCLK_DIVIDE      => 1,
      CLKFBOUT_MULT      => 50,
      CLKFBOUT_PHASE     => 0.000,
      CLKOUT0_DIVIDE     => 16,         -- 62.5 MHz
      CLKOUT0_PHASE      => 0.000,
      CLKOUT0_DUTY_CYCLE => 0.500,
      CLKOUT1_DIVIDE     => 16,         -- 62.5 MHz
      CLKOUT1_PHASE      => 0.000,
      CLKOUT1_DUTY_CYCLE => 0.500,
      CLKOUT2_DIVIDE     => 8,
      CLKOUT2_PHASE      => 0.000,
      CLKOUT2_DUTY_CYCLE => 0.500,
      CLKIN_PERIOD       => 50.0,
      REF_JITTER         => 0.016
    )
    port map (
      CLKFBOUT => pllout_clk_fb_dmtd,
      CLKOUT0  => pllout_clk_dmtd,
      CLKOUT1  => open,
      CLKOUT2  => open,
      CLKOUT3  => open,
      CLKOUT4  => open,
      CLKOUT5  => open,
      LOCKED   => pll1_lock,
      RST      => '0',
      CLKFBIN  => pllout_clk_fb_dmtd,
      CLKIN    => clk_20m_vcxo_buf
    );    -- 20 MHz


  -- clocks generated with plls
  cmp_clk_dmtd_buf : BUFG
    port map (
      I => pllout_clk_dmtd,
      O => clk_dmtd
    );
  
  cmp_clk_sys_buf : BUFG
    port map (
      I => pllout_clk_sys,
      O => clk_sys
    );


  -- resetting fsm (simply adding delay)
  U_Reset_Gen : afck_reset_gen
    port map (
      clk_sys_i        => clk_sys,
      rst_pcie_n_a_i   => '1',
      rst_button_n_a_i => '1',
      rst_n_o          => local_reset_n
    );
  

    rst     <= not local_reset_n;



  


  -- ------------------------------------------------------------------------------
  -- -- GN4124 interface
  -- ------------------------------------------------------------------------------
  -- cmp_gn4124_core : gn4124_core
  --   port map
  --   (
  --     ---------------------------------------------------------
  --     -- Control and status
  --     rst_n_a_i => L_RST_N,
  --     status_o  => open,

  --     ---------------------------------------------------------
  --     -- P2L Direction
  --     --
  --     -- Source Sync DDR related signals
  --     p2l_clk_p_i  => P2L_CLKp,
  --     p2l_clk_n_i  => P2L_CLKn,
  --     p2l_data_i   => P2L_DATA,
  --     p2l_dframe_i => P2L_DFRAME,
  --     p2l_valid_i  => P2L_VALID,
  --     -- P2L Control
  --     p2l_rdy_o    => P2L_RDY,
  --     p_wr_req_i   => P_WR_REQ,
  --     p_wr_rdy_o   => P_WR_RDY,
  --     rx_error_o   => RX_ERROR,
  --     vc_rdy_i     => VC_RDY,

  --     ---------------------------------------------------------
  --     -- L2P Direction
  --     --
  --     -- Source Sync DDR related signals
  --     l2p_clk_p_o  => L2P_CLKp,
  --     l2p_clk_n_o  => L2P_CLKn,
  --     l2p_data_o   => L2P_DATA,
  --     l2p_dframe_o => L2P_DFRAME,
  --     l2p_valid_o  => L2P_VALID,
  --     -- L2P Control
  --     l2p_edb_o    => L2P_EDB,
  --     l2p_rdy_i    => L2P_RDY,
  --     l_wr_rdy_i   => L_WR_RDY,
  --     p_rd_d_rdy_i => P_RD_D_RDY,
  --     tx_error_i   => TX_ERROR,

  --     ---------------------------------------------------------
  --     -- Interrupt interface
  --     dma_irq_o => open,
  --     irq_p_i   => '0',
  --     irq_p_o   => GPIO(0),

  --     ---------------------------------------------------------
  --     -- DMA registers wishbone interface (slave classic)
  --     dma_reg_clk_i => clk_sys,

  --     ---------------------------------------------------------
  --     -- CSR wishbone interface (master pipelined)
  --     csr_clk_i   => clk_sys,
  --     csr_adr_o   => wb_adr,
  --     csr_dat_o   => genum_wb_out.dat,
  --     csr_sel_o   => genum_wb_out.sel,
  --     csr_stb_o   => genum_wb_out.stb,
  --     csr_we_o    => genum_wb_out.we,
  --     csr_cyc_o   => genum_wb_out.cyc,
  --     csr_dat_i   => genum_wb_in.dat,
  --     csr_ack_i   => genum_csr_ack_i,
  --     csr_stall_i => genum_wb_in.stall,

  --     ---------------------------------------------------------
  --     -- L2P DMA Interface (Pipelined Wishbone master)
  --     dma_clk_i => clk_sys
  --     --dma_adr_o   => dma_adr,
  --     --dma_dat_o   => dma_dat_o,
  --     --dma_sel_o   => dma_sel,
  --     --dma_stb_o   => dma_stb,
  --     --dma_we_o    => dma_we,
  --     --dma_cyc_o   => dma_cyc,
  --     --dma_dat_i   => dma_dat_i,
  --     --dma_ack_i   => dma_ack,
  --     --dma_stall_i => dma_stall
  --     );
  
  -- genum_csr_ack_i                <= genum_wb_in.ack or genum_wb_in.err;
  -- genum_wb_out.adr(1 downto 0)   <= (others => '0');
  -- genum_wb_out.adr(18 downto 2)  <= wb_adr(16 downto 0);
  -- genum_wb_out.adr(31 downto 19) <= (others => '0');

  -- wishbone port that was used by GN41
  -- there is no psie on afck so it is not used
    genum_wb_out.adr  <= ( others => '0' );
    genum_wb_out.dat   <= ( others => '0' );
    genum_wb_out.sel   <= ( others => '0' );
    genum_wb_out.stb   <= '0';
    genum_wb_out.we    <= '0';
    genum_wb_out.cyc   <= '0';


  process(clk_sys, rst)
  begin
    if rising_edge(clk_sys) then
      led_divider <= led_divider + 1;
    end if;
  end process;

  fpga_scl_b <= '0' when wrc_scl_o = '0' else 'Z';
  fpga_sda_b <= '0' when wrc_sda_o = '0' else 'Z';
  wrc_scl_i  <= fpga_scl_b;
  wrc_sda_i  <= fpga_sda_b;

  sfp_mod_def1_b <= '0' when sfp_scl_o = '0' else 'Z';
  sfp_mod_def2_b <= '0' when sfp_sda_o = '0' else 'Z';
  sfp_scl_i      <= sfp_mod_def1_b;
  sfp_sda_i      <= sfp_mod_def2_b;

  -- thermo_id <= '0' when owr_en(0) = '1' else 'Z';
  -- owr_i(0)  <= thermo_id;

  U_WR_CORE : xwr_core
    generic map (
      g_simulation                => 0,
      g_with_external_clock_input => true,
      --
      g_phys_uart                 => true,
      g_virtual_uart              => true,
      g_aux_clks                  => 0,
      g_ep_rxbuf_size             => 1024,
      g_tx_runt_padding           => true,
      g_pcs_16bit                 => true,
      g_softpll_enable_debugger   => true,
      g_dpram_initf               => "",
      g_aux_sdb                   => c_etherbone_sdb,
      g_dpram_size                => 131072/4,
      g_interface_mode            => PIPELINED,
      g_address_granularity       => BYTE)
    port map (
      clk_sys_i     => clk_sys,
      clk_dmtd_i    => clk_dmtd,
      clk_ref_i     => clk_62M5_ref,
      clk_aux_i     => (others => '0'),
      clk_ext_i     => clk_ext,
      clk_ext_mul_i => clk_ext_mul,
      pps_ext_i     => dio_in(3),
      rst_n_i       => local_reset_n,

      dac_hpll_load_p1_o => dac_hpll_load_p1,
      dac_hpll_data_o    => dac_hpll_data,
      dac_dpll_load_p1_o => dac_dpll_load_p1,
      dac_dpll_data_o    => dac_dpll_data,

      phy_ref_clk_i      => clk_62M5_ref,
      phy_tx_data_o      => phy_tx_data,
      phy_tx_k_o         => phy_tx_k(0),
      phy_tx_k16_o         => phy_tx_k(1),
      phy_tx_disparity_i => phy_tx_disparity,
      phy_tx_enc_err_i   => phy_tx_enc_err,
      phy_rx_data_i      => phy_rx_data,
      phy_rx_rbclk_i     => phy_rx_rbclk,
      phy_rx_k_i         => phy_rx_k(0),
      phy_rx_k16_i         => phy_rx_k(1),
      phy_rx_enc_err_i   => phy_rx_enc_err,
      phy_rx_bitslide_i  => phy_rx_bitslide,
      phy_rst_o          => phy_rst,
      phy_loopen_o       => phy_loopen,

      led_act_o  => open,
      led_link_o => open,
      scl_o      => wrc_scl_o,
      scl_i      => wrc_scl_i,
      sda_o      => wrc_sda_o,
      sda_i      => wrc_sda_i,
      sfp_scl_o  => sfp_scl_o,
      sfp_scl_i  => sfp_scl_i,
      sfp_sda_o  => sfp_sda_o,
      sfp_sda_i  => sfp_sda_i,
      sfp_det_i  => sfp_mod_def0_b,
      btn1_i     => '1',
      btn2_i     => '1',
      -- upewnic sie co to robi!!!!
      spi_sclk_o  => open,
      spi_ncs_o   => open,
      spi_mosi_o  => open,
      spi_miso_i  => '0',

      uart_rxd_i => uart_rxd_i,
      uart_txd_o => uart_txd_o,

      owr_en_o => owr_en,
      owr_i    => owr_i,

      slave_i => wrc_slave_i,
      slave_o => wrc_slave_o,

      aux_master_o => etherbone_cfg_in,
      aux_master_i => etherbone_cfg_out,

      wrf_src_o => etherbone_snk_in,
      wrf_src_i => etherbone_snk_out,
      wrf_snk_o => etherbone_src_in,
      wrf_snk_i => etherbone_src_out,

      tm_dac_value_o       => open,
      tm_dac_wr_o          => open,
      tm_clk_aux_lock_en_i => (others => '0'),
      tm_clk_aux_locked_o  => open,
      tm_time_valid_o      => open,
      tm_tai_o             => open,
      tm_cycles_o          => open,
      pps_p_o              => pps,
      pps_led_o            => pps_led,

--      dio_o       => dio_out(4 downto 1),
      rst_aux_n_o => etherbone_rst_n
      );

  Etherbone : eb_slave_core
    generic map (
      g_sdb_address => x"0000000000030000")
    port map (
      clk_i       => clk_sys,
      nRst_i      => etherbone_rst_n,
      src_o       => etherbone_src_out,
      src_i       => etherbone_src_in,
      snk_o       => etherbone_snk_out,
      snk_i       => etherbone_snk_in,
      cfg_slave_o => etherbone_cfg_out,
      cfg_slave_i => etherbone_cfg_in,
      master_o    => etherbone_wb_out,
      master_i    => etherbone_wb_in);

  ---------------------
  masterbar : xwb_crossbar
    generic map (
      g_num_masters => 2,
      g_num_slaves  => 1,
      g_registered  => false,
      g_address     => (0 => x"00000000"),
      g_mask        => (0 => x"00000000"))
    port map (
      clk_sys_i   => clk_sys,
      rst_n_i     => local_reset_n,
      slave_i(0)  => genum_wb_out,
      slave_i(1)  => etherbone_wb_out,
      slave_o(0)  => genum_wb_in,
      slave_o(1)  => etherbone_wb_in,
      master_i(0) => wrc_slave_o,
      master_o(0) => wrc_slave_i);


U_GTP : wr_gtx_phy_kintex7
  generic map (
    -- set to non-zero value to speed up the simulation by reducing some delays
    g_simulation         => g_simulation
  )
  port map(
    -- Dedicated reference 125 MHz clock for the GTX transceiver
    clk_gtx_i       => gtp_dedicated_clk,

    -- TX path, synchronous to tx_out_clk_o (62.5 MHz):
    tx_out_clk_o    => clk_62M5_ref,
    -- tx_locked_o     => open, 

    -- data input (8 bits, not 8b10b-encoded)
    tx_data_i       => phy_tx_data,

    -- 1 when tx_data_i contains a control code, 0 when it's a data byte
    tx_k_i        => phy_tx_k,

    -- disparity of the currently transmitted 8b10b code (1 = plus, 0 = minus).
    -- Necessary for the PCS to generate proper frame termination sequences.
    -- Generated for the 2nd byte (LSB) of tx_data_i.
    tx_disparity_o    => phy_tx_disparity,

    -- Encoding error indication (1 = error, 0 = no error)
    tx_enc_err_o    => phy_tx_enc_err,

    -- RX path, synchronous to ch0_rx_rbclk_o.

    -- RX recovered clock
    rx_rbclk_o      => phy_rx_rbclk,

    -- 8b10b-decoded data output. The data output must be kept invalid before
    -- the transceiver is locked on the incoming signal to prevent the EP from
    -- detecting a false carrier.
    rx_data_o       => phy_rx_data,

    -- 1 when the byte on rx_data_o is a control code
    rx_k_o        => phy_rx_k,

    -- encoding error indication
    rx_enc_err_o    => phy_rx_enc_err,

    -- RX bitslide indication, indicating the delay of the RX path of the
    -- transceiver (in UIs). Must be valid when ch0_rx_data_o is valid.
    rx_bitslide_o     => phy_rx_bitslide,
    -- reset input, active hi
    rst_i             => phy_rst, 
    loopen_i          => phy_loopen,
    

    pad_txn_o         => sfp_txn_o,
    pad_txp_o         => sfp_txp_o,
            
    pad_rxn_i         => sfp_rxn_i,
    pad_rxp_i         => sfp_rxp_i

  ); 


  ---------------------

  -- U_GTP : wr_gtp_phy_spartan6
  --   generic map (
  --     g_enable_ch0 => 0,
  --     g_enable_ch1 => 1,
  --     g_simulation => 0)
  --   port map (
  --     gtp_clk_i => gtp_dedicated_clk,

  --     ch0_ref_clk_i      => clk_62M5_ref,
  --     ch0_tx_data_i      => x"00",
  --     ch0_tx_k_i         => '0',
  --     ch0_tx_disparity_o => open,
  --     ch0_tx_enc_err_o   => open,
  --     ch0_rx_rbclk_o     => open,
  --     ch0_rx_data_o      => open,
  --     ch0_rx_k_o         => open,
  --     ch0_rx_enc_err_o   => open,
  --     ch0_rx_bitslide_o  => open,
  --     ch0_rst_i          => '1',
  --     ch0_loopen_i       => '0',

  --     ch1_ref_clk_i      => clk_62M5_ref,
  --     ch1_tx_data_i      => phy_tx_data,
  --     ch1_tx_k_i         => phy_tx_k,
  --     ch1_tx_disparity_o => phy_tx_disparity,
  --     ch1_tx_enc_err_o   => phy_tx_enc_err,
  --     ch1_rx_data_o      => phy_rx_data,
  --     ch1_rx_rbclk_o     => phy_rx_rbclk,
  --     ch1_rx_k_o         => phy_rx_k,
  --     ch1_rx_enc_err_o   => phy_rx_enc_err,
  --     ch1_rx_bitslide_o  => phy_rx_bitslide,
  --     ch1_rst_i          => phy_rst,
  --     ch1_loopen_i       => phy_loopen,
  --     pad_txn0_o         => open,
  --     pad_txp0_o         => open,
  --     pad_rxn0_i         => '0',
  --     pad_rxp0_i         => '0',
  --     pad_txn1_o         => sfp_txn_o,
  --     pad_txp1_o         => sfp_txp_o,
  --     pad_rxn1_i         => sfp_rxn_i,
  --     pad_rxp1_i         => sfp_rxp_i);

  

  
  U_DAC_ARB : spec_serial_dac_arb
    generic map (
      g_invert_sclk    => false,
      g_num_extra_bits => 8)

    port map (
      clk_i   => clk_sys,
      rst_n_i => local_reset_n,

      val1_i  => dac_dpll_data,
      load1_i => dac_dpll_load_p1,

      val2_i  => dac_hpll_data,
      load2_i => dac_hpll_load_p1,

      dac_cs_n_o(0) => dac_cs1_n_o,
      dac_cs_n_o(1) => dac_cs2_n_o,
      dac_clr_n_o   => open,
      dac_sclk_o    => dac_sclk_o,
      dac_din_o     => dac_din_o);


  U_Extend_PPS : gc_extend_pulse
    generic map (
      g_width => 10000000)
    port map (
      clk_i      => clk_62M5_ref,
      rst_n_i    => local_reset_n,
      pulse_i    => pps_led,
      extended_o => dio_led_top_o);


  gen_dio_iobufs : for i in 0 to 4 generate
    U_ibuf : IBUFDS
      generic map (
        DIFF_TERM => true)
      port map (
        O  => dio_in(i),
        I  => dio_p_i(i),
        IB => dio_n_i(i)
        );

    U_obuf : OBUFDS
      port map (
        I  => dio_out(i),
        O  => dio_p_o(i),
        OB => dio_n_o(i)
        );
  end generate gen_dio_iobufs;

  U_input_buffer : IBUFGDS
    generic map (
      DIFF_TERM => true)
    port map (
      O  => clk_ext,
      I  => dio_clk_p_i,
      IB => dio_clk_n_i
      );

  dio_led_bot_o <= '0';

  process(clk_62M5_ref)
  begin
    if rising_edge(clk_62M5_ref) then
      if local_reset = '1' then
        clk_ref_div2  <= '0';
      else
        clk_ref_div2 <= not clk_ref_div2;
      end if;
    end if;
  end process;
  
  dio_out(0) <= pps;
  dio_out(1) <= clk_ref_div2;

  dio_oe_n_o(0)          <= '0';
  dio_oe_n_o(2 downto 1) <= (others => '0');
  dio_oe_n_o(3)          <= '1';        -- for external 1-PPS
  dio_oe_n_o(4)          <= '1';        -- for external 10MHz clock

  dio_onewire_b <= '0' when owr_en(1) = '1' else 'Z';
  owr_i(1)      <= dio_onewire_b;

  dio_term_en_o <= (others => '0');

  dio_sdn_ck_n_o <= '1';
  dio_sdn_n_o    <= '1';

  sfp_tx_disable_o <= '0';








    --  icon_inst : phy_icon
    --    port map (
    --      CONTROL0   => chs_control 
    --    );

    
    --  ila_inst : phy_ila
    --    port map (
    --      CONTROL    => chs_control,
    --      CLK    => clk_cs,
    --      DATA     => chs_data,
    --      TRIG0    => chs_trig
    --    );
  
    -- chs_trig( 0 )     <= sfp_los_i;
    -- -- chs_trig( 1 )     <= dac_din;
    -- -- chs_trig( 2 )     <= dac_cs1_n;
    -- -- chs_trig( 3 )     <= dac_cs2_n;
    -- -- chs_trig( 4 )     <= ep_src_out.stb;
    -- -- chs_trig( 5 )     <= ep_snk_in.stb;
    -- chs_trig( 7 downto 6 )  <= phy_debug(7 downto 6); --    <= rx_k_int;
    -- chs_trig( 23 downto 8 )   <= phy_debug( 47 downto 32 ); --  <= rx_data_int;
    -- chs_trig( 31 downto 24 )  <= phy_debug( 23 downto 16 ); --  <= tx_data_swapped;
    -- -- chs_trig( chs_trig'left downto 8 )   <= ( others => '0' );
     
    -- chs_trig( 1 )     <= wrc_scl_o;
    -- chs_trig( 2 )     <= wrc_scl_i;
    -- chs_trig( 3 )     <= wrc_sda_o;
    -- chs_trig( 4 )     <= wrc_sda_i;

    -- -- from wr_gtx_phy_kintex7.vhd
    -- chs_data( 63 downto 0 ) <= phy_debug( 63 downto 0 );
     
    -- -- from TLE
    -- chs_data( 64 + 0 )      <= sfp_mod_def0_b;
    -- chs_data( 64 + 1 )      <= sfp_scl_o;
    -- chs_data( 64 + 2 )      <= sfp_scl_i;
    -- chs_data( 64 + 3 )      <= sfp_sda_o;
    -- chs_data( 64 + 4 )      <= sfp_sda_i;
    -- chs_data( 64 + 5 )      <= sfp_rate_select_b;
    -- chs_data( 64 + 6 )      <= sfp_tx_fault_i;
    -- chs_data( 64 + 7 )      <= sfp_los_i;
    
    -- -- chs_data( 64 + 8 )      <= dac_sclk;
    -- -- chs_data( 64 + 9 )      <= dac_din;
    -- -- chs_data( 64 + 10 )     <= dac_cs1_n;
    -- -- chs_data( 64 + 11 )     <= dac_cs2_n;
    
    -- chs_https://github.com/gumaas/general-cores.gitdata( 64 + 12 )     <= pll0_lock;
    -- chs_data( 64 + 13 )     <= pll1_lock;
    
    -- chs_data( 64 + 14 )     <= wrc_scl_o;
    -- chs_data( 64 + 15 )     <= wrc_scl_i;
    -- chs_data( 64 + 16 )     <= wrc_sda_o;
    -- chs_data( 64 + 17 )     <= wrc_sda_i;

    
    -- -- chs_data( 64 + 31 downto 64 + 16 )      <= ep_src_out.dat;
    -- -- chs_data( 64 + 32 + 15 downto 64 + 32 )   <= ep_snk_in.dat;
    -- -- chs_data( 64 + 32 + 16 )      <= ep_src_out.stb;
    -- -- chs_data( 64 + 32 + 17 )      <= ep_snk_in.stb;
    
    
    -- chs_data( chs_data'left downto 64 + 32 + 18 )   <= ( others => '0' );




end rtl;


