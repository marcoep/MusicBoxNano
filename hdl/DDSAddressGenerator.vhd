-------------------------------------------------------------------------------
-- Title      : DDS Address Generator
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DDSAddressGenerator.vhd
-- Author     : Marco Eppenberger  <marco@Pierce.home>
-- Company    : 
-- Created    : 2016-07-30
-- Last update: 2016-07-30
-- Platform   : ModelSim, Altera Quartus
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Generator for DDS and Evelope ROM address.
-------------------------------------------------------------------------------
-- Copyright (c) 2016 Marco Eppenberger
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-07-30  1.0      marco Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Helpers_Pkg.all;


entity DDSAddressGenerator is

  generic (
    ENV_DECAY_SPEED   : integer := 250;  -- 250 is one second (min 1, max 1023)
    DDS_COUNTER_WIDTH : integer := 29);  -- min 12

  port (
    Clk_CI            : in  std_logic;
    Reset_SI          : in  std_logic;
    Increment_DI      : in  std_logic_vector(DDS_COUNTER_WIDTH-1 downto 0);
    IncrementValid_SI : in  std_logic;
    FreqTick_SI       : in  std_logic;
    DDSAddr_DO        : out std_logic_vector(11 downto 0);
    EnvAddr_DO        : out std_logic_vector(7 downto 0));

end entity DDSAddressGenerator;


architecture RTL of DDSAddressGenerator is

  -- the last 1/8th of the wave table is the sustain part
  constant SUSTAIN_BEGIN_ADDR : integer := (2**(DDS_COUNTER_WIDTH-3))*7;

  -- Envelope Address Generation
  signal EnvTickCounter_DN : unsigned(9 downto 0) := (others => '0');
  signal EnvTickCounter_DP : unsigned(9 downto 0) := (others => '0');
  signal EnvTick_S         : std_logic            := '0';
  signal EnvAddr_DN        : unsigned(7 downto 0) := (others => '0');
  signal EnvAddr_DP        : unsigned(7 downto 0) := (others => '0');
  signal EnvelopeDone_S    : std_logic            := '0';

  -- DDS Address Generation
  signal DDSAddr_DN, DDSAddr_DP         : unsigned(DDS_COUNTER_WIDTH-1 downto 0) := (others => '0');
  signal IncrementBuf_D                 : unsigned(DDS_COUNTER_WIDTH-1 downto 0) := (others => '0');
  signal SustainFlag_SN, SustainFlag_SP : std_logic                              := '0';


begin  -- architecture RTL

  -----------------------------------------------------------------------------
  -- DDS (Waveform) Address Generator
  -----------------------------------------------------------------------------

  -- next DDS addr logic
  next_dds_addr : process (DDSAddr_DP, FreqTick_SI, IncrementBuf_D,
                           IncrementValid_SI, SustainFlag_SP) is
    variable addr_tmp       : unsigned(DDS_COUNTER_WIDTH-1 downto 0) := (others => '0');
    variable dds_in_sustain : boolean                                := false;
  begin
    -- defaults
    DDSAddr_DN     <= DDSAddr_DP;
    SustainFlag_SN <= SustainFlag_SP;

    -- add increment to address and check if in sustain region
    addr_tmp       := DDSAddr_DP + IncrementBuf_D;
    dds_in_sustain := addr_tmp >= SUSTAIN_BEGIN_ADDR;

    -- get next DDS addr when frequency ticks
    if FreqTick_SI = '1' then
      if SustainFlag_SP = '1' and not(dds_in_sustain) then
        DDSAddr_DN <= addr_tmp + SUSTAIN_BEGIN_ADDR;
      else
        DDSAddr_DN <= addr_tmp;
      end if;
    end if;

    -- sustain flag is set from 0 to 1 when the address reaches the sustain
    -- part the first time
    if dds_in_sustain then
      SustainFlag_SN <= '1';
    end if;

    -- reset when we get a new increment
    if IncrementValid_SI = '1' then
      SustainFlag_SN <= '0';
      DDSAddr_DN     <= (others => '0');
    end if;
  end process next_dds_addr;

  -- DDS generator flipflop
  DDSAddrGen : process (Clk_CI) is
  begin  -- process DDSAddrGen
    if Clk_CI'event and Clk_CI = '1' then
      if Reset_SI = '1' then
        IncrementBuf_D <= (others => '0');
        SustainFlag_SP <= '0';
        DDSAddr_DP     <= (others => '0');
      else
        if IncrementValid_SI = '1' then
          IncrementBuf_D <= unsigned(Increment_DI);
        end if;
        SustainFlag_SP <= SustainFlag_SN;
        DDSAddr_DP     <= DDSAddr_DN;
      end if;
    end if;
  end process DDSAddrGen;

  -- output
  DDSAddr_DO <= DDSAddr_DP(DDS_COUNTER_WIDTH-1 downto DDS_COUNTER_WIDTH-12);


  -----------------------------------------------------------------------------
  -- Envelope Address Generator
  -----------------------------------------------------------------------------

  -- envelope tick if counter reaches out of bounds
  EnvTick_S <= bool2sl(EnvTickCounter_DP >= ENV_DECAY_SPEED);

  -- next tick logic
  env_tick : process (EnvTickCounter_DP, EnvTick_S, FreqTick_SI) is
  begin
    EnvTickCounter_DN <= EnvTickCounter_DP;
    if FreqTick_SI = '1' then
      if EnvTick_S = '1' then
        EnvTickCounter_DN <= (others => '0');
      else
        EnvTickCounter_DN <= EnvTickCounter_DP + 1;
      end if;
    end if;
  end process env_tick;

  -- address done
  EnvelopeDone_S <= bool2sl(EnvAddr_DP = 255);

  -- next address logic
  next_addr_logic : process (EnvAddr_DP, EnvTick_S, EnvelopeDone_S) is
  begin
    EnvAddr_DN <= EnvAddr_DP;
    if EnvTick_S = '1' and EnvelopeDone_S = '0' then
      EnvAddr_DN <= EnvAddr_DP + 1;
    end if;
  end process next_addr_logic;

  -- envelope address flipflops, also reset when new increment comes in
  EnvAddrGen : process (Clk_CI) is
  begin
    if Clk_CI'event and Clk_CI = '1' then
      if (Reset_SI = '1' or IncrementValid_SI = '1') then
        EnvAddr_DP        <= (others => '0');
        EnvTickCounter_DP <= (others => '0');
      else
        EnvAddr_DP        <= EnvAddr_DN;
        EnvTickCounter_DP <= EnvTickCounter_DN;
      end if;
    end if;
  end process EnvAddrGen;

  -- output
  EnvAddr_DO <= std_logic_vector(EnvAddr_DP);


end architecture RTL;
