-------------------------------------------------------------------------------
-- Title      : PWM Generator
-- Project    : 
-------------------------------------------------------------------------------
-- File       : PWMGenerator.vhd
-- Author     :   <Marco@JUDI-WIN10>
-- Company    : 
-- Created    : 2016-08-01
-- Last update: 2016-08-01
-- Platform   : Mentor Graphics ModelSim, Altera Quartus
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Generate PWM with given pulse width.
-------------------------------------------------------------------------------
-- Copyright (c) 2016 Marco Eppenberger
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-08-01  1.0      Marco Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity PWMGenerator is

  port (
    Clk_CI       : in  std_logic;
    Reset_SI     : in  std_logic;
    DutyCycle_DI : in  std_logic_vector(7 downto 0);
    PulseOut_DO  : out std_logic);

end entity PWMGenerator;


architecture RTL of PWMGenerator is

  signal DutyCycle_D  : unsigned(7 downto 0) := (others => '0');
  signal PWMCounter_D : unsigned(7 downto 0) := (others => '0');

begin

  outreg : process (Clk_CI) is
  begin  -- process outreg
    if Clk_CI'event and Clk_CI = '1' then  -- rising clock edge
      if Reset_SI = '1' then               -- synchronous reset (active high)
        DutyCycle_D  <= (others => '0');
        PWMCounter_D <= (others => '0');
        PulseOut_DO  <= '0';
      else
        DutyCycle_D  <= unsigned(DutyCycle_DI);
        PWMCounter_D <= PWMCounter_D + 1;
        if PWMCounter_D < DutyCycle_D then
          PulseOut_DO <= '1';
        else
          PulseOut_DO <= '0';
        end if;
      end if;
    end if;
  end process outreg;

end architecture RTL;
