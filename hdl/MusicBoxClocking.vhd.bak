-------------------------------------------------------------------------------
-- Title      : Music Box Nano - Clocking
-- Project    : 
-------------------------------------------------------------------------------
-- File       : MusicBoxClocking.vhd
-- Author     :   <Marco@JUDI-WIN10>
-- Company    : 
-- Created    : 2016-07-28
-- Last update: 2016-07-28
-- Platform   : Mentor Graphics ModelSim, Altera Quartus
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Gathers all clocking and reset resources for the Music Box Nano
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-07-28  1.0      Marco Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity MusicBoxClocking is

  port (
    CLOCK_50       : in  std_logic;
    RESET_RI       : in  std_logic;
    ClkSystem_CO   : out std_logic;
    ClkPWM_CO      : out std_logic;
    ResetSystem_SO : out std_logic;
    ResetPWM_SO    : out std_logic;
    FreqInt_SO     : out std_logic;
    KeyInt_SO      : out std_logic);

end entity MusicBoxClocking;

architecture RTL of MusicBoxClocking is

  constant KEYFREQDIV : integer := 9;   -- divides the frequency wave to the
                                        -- key-speed wave

  signal Clk5M_C   : std_logic := '0';
  signal Clk64M_C  : std_logic := '0';
  signal Clk128k_C : std_logic := '0';

  signal ResetSystem_S : std_logic := '0';
  signal ResetPWM_S    : std_logic := '0';

  signal PLLLocked_S : std_logic := '0';

  signal FreqWave_SN, FreqWave_SP : std_logic := '0';
  signal FreqEdgeDet_S            : std_logic;

  signal ClkDivider_D           : unsigned(KEYFREQDIV-1 downto 0) := (others => '0');
  signal KeyWave_SN, KeyWave_SP : std_logic                       := '0';
  signal KeyEdgeDet_S           : std_logic                       := '0';

begin  -- architecture RTL

  -- clock generator PLL from 50MHz input clock
  ClocksPLL_i : entity work.ClocksPLL
    port map (
      areset => RESET_RI,
      inclk0 => CLOCK_50,
      c0     => Clk5M_C,
      c1     => Clk64M_C,
      c2     => Clk128k_C,
      locked => PLLLocked_S);

  -- clock outputs
  ClkSystem_CO <= Clk5M_C;
  ClkPWM_CO    <= Clk64M_C;

  -- reset synchronizer for System Clock
  ResetSync_Sys_i : entity work.ResetSync
    port map (
      Clk_CI        => Clk5M_C,
      ClkStable_RI  => PLLLocked_S,
      OtherReset_RI => '0',
      SyncReset_SO  => ResetSystem_S);

  ResetSystem_SO <= ResetSystem_S;

  -- reset sync for pwm clock
  ResetSync_pwm_i : entity work.ResetSync
    port map (
      Clk_CI        => Clk64M_C,
      ClkStable_RI  => PLLLocked_S,
      OtherReset_RI => '0',
      SyncReset_SO  => ResetPWM_S);

  ResetPWM_SO <= ResetPWM_S;

  -----------------------------------------------------------------------------
  -- Generation of Interrupts
  -----------------------------------------------------------------------------

  -- frequency wave generator
  CrossClockDomain_Freq_i : entity work.CrossClockDomain
    port map (
      Clk_CI     => Clk5M_C,
      AsyncIn_SI => Clk128k_C,
      SyncOut_SO => FreqWave_SN);

  clk_divider : process (Clk128k_C) is
  begin  -- process clk_divider
    if Clk128k_C'event and Clk128k_C = '1' then  -- rising clock edge
      ClkDivider_D <= ClkDivider_D + 1;
    end if;
  end process clk_divider;

  CrossClockDomain_Key_i : entity work.CrossClockDomain
    port map (
      Clk_CI     => Clk5M_C,
      AsyncIn_SI => ClkDivider_D(KEYFREQDIV-1),
      SyncOut_SO => KeyWave_SN);

  -- edge detector flipflops
  edge_det : process (Clk5M_C) is
  begin  -- process freq_edge_det
    if Clk5M_C'event and Clk5M_C = '1' then  -- rising clock edge
      if ResetSystem_S = '1' then            -- synchronous reset (active high)
        FreqWave_SP <= '0';
        FreqInt_SO  <= '0';
        KeyWave_SP  <= '0';
        KeyInt_SO   <= '0';
      else
        FreqWave_SP <= FreqWave_SN;
        FreqInt_SO  <= FreqWave_SN and not(FreqWave_SP);
        KeyWave_SP  <= KeyWave_SN;
        KeyInt_SO   <= KeyWave_SN and not(KeyWave_SP);
      end if;
    end if;
  end process edge_det;

end architecture RTL;
