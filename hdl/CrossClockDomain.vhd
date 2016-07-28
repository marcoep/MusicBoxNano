-------------------------------------------------------------------------------
-- Title      : Simple Clock Domain Crossing for Single Bit Signals
-- Project    : 
-------------------------------------------------------------------------------
-- File       : CrossClockDomain.vhd
-- Author     :   <Marco@JUDI-WIN10>
-- Company    : 
-- Created    : 2016-07-28
-- Last update: 2016-07-28
-- Platform   : Mentor Graphics ModelSim, Altera Quartus
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Clock Domain Crossing for std_logic signals with a 5-stage
-- synchronizer circuit.
-------------------------------------------------------------------------------
-- Copyright (c) 2016 Marco Eppenberger <mail@mebg.ch>
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-07-28  1.0      Marco Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity CrossClockDomain is

  port (
    Clk_CI     : in  std_logic;
    AsyncIn_SI : in  std_logic;
    SyncOut_SO : out std_logic);

end entity CrossClockDomain;


architecture RTL of CrossClockDomain is

  signal clk_sync_0 : std_logic := '0';
  signal clk_sync_1 : std_logic := '0';
  signal clk_sync_2 : std_logic := '0';
  signal clk_sync_3 : std_logic := '0';

begin  -- architecture RTL

  sync_clock_domain : process (Clk_CI) is
  begin  -- process sync_clock_domain
    if Clk_CI'event and Clk_CI = '1' then  -- rising clock edge
      clk_sync_0 <= AsyncIn_SI;
      clk_sync_1 <= clk_sync_0;
      clk_sync_2 <= clk_sync_1;
      clk_sync_3 <= clk_sync_2;
      SyncOut_SO <= clk_sync_3;
    end if;
  end process sync_clock_domain;

end architecture RTL;

