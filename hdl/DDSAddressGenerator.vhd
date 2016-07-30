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
-- Description: Generator for DDS and Evelope ROM
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


entity DDSAddressGenerator is

  generic (
    ENV_DECAY_SPEED   : integer := 250;
    DDS_COUNTER_WIDTH : integer := 29);

  port (
    Clk_CI            : in  std_logic;
    Reset_SI          : in  std_logic;
    Increment_D       : in  std_logic_vector(DDS_COUNTER_WIDTH-1 downto 0);
    IncrementValid_SI : in  std_logic;
    FreqTick_SI       : in  std_logic;
    DDSAddr_DO        : out std_logic_vector(11 downto 0);
    EnvAddr_DO        : out std_logic_vector(7 downto 0));

end entity DDSAddressGenerator;
