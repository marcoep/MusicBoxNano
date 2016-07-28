

-------------------------------------------------------------------------------
-- Title      : Reset Synchronizer Circuit with 4 FFs
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ResetSync.vhd
-- Author     :   <marcoep@ITET-IEF-W03>
-- Company    : Institute of Electromagnetic Fields, ETH Zurich
-- Created    : 2016-01-09
-- Last update: 2016-01-09
-- Platform   : Mentor Graphics ModelSim (simulation), Xilinx Vivado (synthesis, implementation)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- The Reset is asynchronously asserted logic high. The reset pulse is
-- guaranteed to last at least 4 Clk_CI cycles. Then, the reset is desasserted
-- synchronously with Clk_CI.
-------------------------------------------------------------------------------
-- Copyright (c) 2016 Marco Eppenberger <mail@mebg.ch>
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-01-09  1.0      marcoep Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ResetSync is

  port (
    ---------------------------------------------------------------------------
    -- Clock to synchronize reset to
    ---------------------------------------------------------------------------
    Clk_CI        : in  std_logic;
    ---------------------------------------------------------------------------
    -- Reset Inputs
    --  As long as ClkStable_RI is low, reset is asserted
    --  As long as OtherReset_RI is high, reset is asserted
    ---------------------------------------------------------------------------
    ClkStable_RI  : in  std_logic;
    OtherReset_RI : in  std_logic;
    ---------------------------------------------------------------------------
    -- Syncronized Reset Out
    --  Active high synchronized reset.
    --  SyncReset_SO is desasserted 4 cycles after reset condition is lifted
    ---------------------------------------------------------------------------
    SyncReset_SO  : out std_logic);

end entity ResetSync;


architecture RTL of ResetSync is

  signal AsyncReset_R             : std_logic                    := '0';
  signal ShiftRst_SN, ShiftRst_SP : std_logic_vector(3 downto 0) := (others => '1');

begin  -- architecture RTL

  -- reset condition
  AsyncReset_R <= OtherReset_RI or not(ClkStable_RI);

  -- Feed 0 to first FF
  ShiftRst_SN(0) <= '0';

  -- connect FFs
  ShiftRst_SN(3 downto 1) <= ShiftRst_SP(2 downto 0);

  -- FF chain
  ResetFFs : process (Clk_CI, AsyncReset_R) is
  begin  -- process ResetFFs
    if AsyncReset_R = '1' then                -- asynchronous active high reset
      ShiftRst_SP <= (others => '1');
    elsif Clk_CI'event and Clk_CI = '1' then  -- rising clock edge
      ShiftRst_SP <= ShiftRst_SN;
    end if;
  end process ResetFFs;

  -- assign output
  SyncReset_SO <= ShiftRst_SP(3);


end architecture RTL;

