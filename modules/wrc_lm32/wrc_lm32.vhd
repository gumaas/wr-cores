
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wrc_lm32 is
  generic(
    g_addr_width : integer;
    g_num_irqs   : integer
    );
  port(
    clk_i   : in std_logic;
    rst_n_i : in std_logic;
    irq_i   : in std_logic_vector(g_num_irqs-1 downto 0);

    iwb_adr_o : out std_logic_vector(g_addr_width-1 downto 0);
    iwb_dat_o : out std_logic_vector(31 downto 0);
    iwb_dat_i : in  std_logic_vector(31 downto 0);
    iwb_cyc_o : out std_logic;
    iwb_stb_o : out std_logic;
    iwb_ack_i : in  std_logic;

    dwb_adr_o : out std_logic_vector(g_addr_width-1 downto 0);
    dwb_dat_o : out std_logic_vector(31 downto 0);
    dwb_dat_i : in  std_logic_vector(31 downto 0);
    dwb_cyc_o : out std_logic;
    dwb_stb_o : out std_logic;
    dwb_sel_o : out std_logic_vector(3 downto 0);
    dwb_we_o  : out std_logic;
    dwb_ack_i : in  std_logic
    );

end wrc_lm32;

architecture rtl of wrc_lm32 is
  component lm32_top                    -- Defined in lm32_top.v
    port(
      clk_i     : in  std_logic;
      rst_i     : in  std_logic;
      interrupt : in  std_logic_vector(31 downto 0);
      I_DAT_I   : in  std_logic_vector(31 downto 0);
      I_ACK_I   : in  std_logic;
      I_ERR_I   : in  std_logic;
      I_RTY_I   : in  std_logic;
      D_DAT_I   : in  std_logic_vector(31 downto 0);
      D_ACK_I   : in  std_logic;
      D_ERR_I   : in  std_logic;
      D_RTY_I   : in  std_logic;
      I_DAT_O   : out std_logic_vector(31 downto 0);
      I_ADR_O   : out std_logic_vector(31 downto 0);
      I_CYC_O   : out std_logic;
      I_SEL_O   : out std_logic_vector(3 downto 0);
      I_STB_O   : out std_logic;
      I_WE_O    : out std_logic;
      I_CTI_O   : out std_logic_vector(2 downto 0);
      I_LOCK_O  : out std_logic;
      I_BTE_O   : out std_logic_vector(1 downto 0);
      D_DAT_O   : out std_logic_vector(31 downto 0);
      D_ADR_O   : out std_logic_vector(31 downto 0);
      D_CYC_O   : out std_logic;
      D_SEL_O   : out std_logic_vector(3 downto 0);
      D_STB_O   : out std_logic;
      D_WE_O    : out std_logic;
      D_CTI_O   : out std_logic_vector(2 downto 0);
      D_LOCK_O  : out std_logic;
      D_BTE_O   : out std_logic_vector(1 downto 0));
  end component lm32_top;

  signal rst         : std_logic;
  signal iwb_adr_int : std_logic_vector(31 downto 0);
  signal dwb_adr_int : std_logic_vector(31 downto 0);
  signal irqs_vec    : std_logic_vector(31 downto 0);

  signal dwb_data_int : std_logic_vector(31 downto 0);
  
begin

  irqs_vec(g_num_irqs-1 downto 0) <= irq_i;
  irqs_vec(31 downto g_num_irqs)  <= (others => '0');

  rst <= not rst_n_i;

  WRAPPED_LM32 : lm32_top
    port map (
      clk_i     => clk_i,
      rst_i     => rst,
      interrupt => irqs_vec,

      I_DAT_I  => iwb_dat_i,
      I_ACK_I  => iwb_ack_i,
      I_ERR_I  => '0',
      I_RTY_I  => '0',
      D_DAT_I  => dwb_data_int,
      D_ACK_I  => dwb_ack_i,
      D_ERR_I  => '0',
      D_RTY_I  => '0',
      I_DAT_O  => iwb_dat_o,
      I_ADR_O  => iwb_adr_int,
      I_CYC_O  => iwb_cyc_o,
      I_SEL_O  => open,
      I_STB_O  => iwb_stb_o,
      I_WE_O   => open,
      I_CTI_O  => open,
      I_LOCK_O => open,
      I_BTE_O  => open,
      D_DAT_O  => dwb_dat_o,
      D_ADR_O  => dwb_adr_int,
      D_CYC_O  => dwb_cyc_o,
      D_SEL_O  => dwb_sel_o,
      D_STB_O  => dwb_stb_o,
      D_WE_O   => dwb_we_o,
      D_CTI_O  => open,
      D_LOCK_O => open,
      D_BTE_O  => open);

  iwb_adr_o <= iwb_adr_int(g_addr_width+1 downto 2);
  dwb_adr_o <= dwb_adr_int(g_addr_width+1 downto 2);

  process(dwb_dat_i)
  begin
    
    for i in 0 to 31 loop
      if(dwb_dat_i(i) = 'X') then
        dwb_data_int(i) <= '0';
      else
        dwb_data_int(i) <= dwb_dat_i(i);
      end if;
    end loop;
  end process;
  
end rtl;