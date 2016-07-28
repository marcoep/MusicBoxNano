-------------------------------------------------------------------------------
-- Title      : Music Box Nano
-- Project    : 
-------------------------------------------------------------------------------
-- File       : MusicBoxNano.vhd
-- Author     :   <Marco@JUDI-WIN10>
-- Company    : 
-- Created    : 2016-07-28
-- Last update: 2016-07-29
-- Platform   : Mentor Graphics ModelSim, Altera Quartus
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Top-Level for the MusicBoxNano Project
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


entity MusicBoxNano is

  port (
    CLOCK_50  : in  std_logic;
    Button_DI : in  std_logic_vector(1 downto 0);
    Led_DO    : out std_logic_vector(7 downto 0);
    PWMOut_DO : out std_logic);

end entity MusicBoxNano;


architecture RTL of MusicBoxNano is

  -- global signals
  signal ClkSys_C   : std_logic := '0';
  signal ResetSys_S : std_logic := '0';
  signal ClkPWM_C   : std_logic := '0';
  signal ResetPWM_S : std_logic := '0';

  -- frequency and key ticks
  signal FreqTick_S : std_logic := '0';
  signal KeyTick_S  : std_logic := '0';

  -- note data from Song ROM
  signal KeyData_D  : std_logic_vector(6 downto 0) := (others => '0');
  signal KeyValid_S : std_logic                    := '0';

  -- key to freq increment
  signal FreqIncrement_D : std_logic_vector(28 downto 0) := (others => '0');
  signal KeyValidShim_S  : std_logic                     := '0';
  signal FreqIncrValid_S : std_logic                     := '0';

begin  -- architecture RTL


  -----------------------------------------------------------------------------
  -- Clocking and Reset Resources
  -----------------------------------------------------------------------------
  MusicBoxClocking_i : entity work.MusicBoxClocking
    port map (
      CLOCK_50       => CLOCK_50,
      RESET_RI       => Button_DI(0),
      ClkSystem_CO   => ClkSys_C,
      ClkPWM_CO      => ClkPWM_C,
      ResetSystem_SO => ResetSys_S,
      ResetPWM_SO    => ResetPWM_S,
      FreqInt_SO     => FreqTick_S,
      KeyInt_SO      => KeyTick_S);


  -----------------------------------------------------------------------------
  -- Song ROM
  -----------------------------------------------------------------------------
  SongDB_i : entity work.SongDB
    port map (
      Clk_CI         => ClkSys_C,
      Reset_SI       => ResetSys_S,
      KeyTick_SI     => KeyTick_S,
      NewKeyData_DO  => KeyData_D,
      NewKeyValid_SO => KeyValid_S);

  -----------------------------------------------------------------------------
  -- Key to Frequency Mapping
  -----------------------------------------------------------------------------
  KeyToFreqROM_i : entity work.KeyToFreqROM  -- latency 2
    port map (
      address => KeyData_D,
      clock   => ClkSys_C,
      q       => FreqIncrement_D);

  shim_valid : process (ClkSys_C) is
  begin  -- process shim_valid
    if ClkSys_C'event and ClkSys_C = '1' then  -- rising clock edge
      if ResetSys_S = '1' then          -- synchronous reset (active high)
        KeyValidShim_S  <= '0';
        FreqIncrValid_S <= '0';
      else
        KeyValidShim_S  <= KeyValid_S;
        FreqIncrValid_S <= KeyValidShim_S;
      end if;
    end if;
  end process shim_valid;


  -- continue here


end architecture RTL;
