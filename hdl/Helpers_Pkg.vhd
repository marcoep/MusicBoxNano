-------------------------------------------------------------------------------
-- Title      : Helper Functions
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Helpers_Pkg.vhd
-- Author     :   <Marco@JUDI-WIN10>
-- Company    : 
-- Created    : 2016-07-29
-- Last update: 2016-07-29
-- Platform   : Mentor Graphics ModelSim, Altera Quartus
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Helper Functions for VHDL
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-07-29  1.0      Marco Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



package Helpers_Pkg is

  -----------------------------------------------------------------------------
  -- helper functions
  -----------------------------------------------------------------------------
  -- converts a boolean signal to a std_logic signal
  function bool2sl(L     : boolean) return std_logic;
  -- does bit-reversal on an SLV (only downto indexing!)
  function reverseBits(L : std_logic_vector) return std_logic_vector;

end package Helpers_Pkg;



package body Helpers_Pkg is

  -----------------------------------------------------------------------------
  -- helper functions
  -----------------------------------------------------------------------------
  function bool2sl(L : boolean) return std_logic is
  begin
    if L then
      return('1');
    else
      return('0');
    end if;
  end function bool2sl;

  function reverseBits(L : std_logic_vector) return std_logic_vector is
    constant maxidx : integer                   := L'left;
    variable result : std_logic_vector(L'range) := (others => '0');
  begin
    for i in L'range loop
      result(i) := L(maxidx-i);
    end loop;  -- i
    return result;
  end function reverseBits;


end package body Helpers_Pkg;

