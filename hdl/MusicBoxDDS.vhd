-------------------------------------------------------------------------------
-- Title      : Direct Digital Synthesis
-- Project    : 
-------------------------------------------------------------------------------
-- File       : MusicBoxDDS.vhd
-- Author     :   <Marco@JUDI-WIN10>
-- Company    : 
-- Created    : 2016-08-01
-- Last update: 2016-08-01
-- Platform   : Mentor Graphics ModelSim, Altera Quartus
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Direct Digital Synthesis for the Music Box Project. Takes
-- frequency increments and distributes it to DDS address generators. The
-- addresses get translated to the waveform one by one, multiplied with the
-- envelope, added up, and put out. 16-fold parallelism
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

library work;
use work.Helpers_Pkg.all;


entity MusicBoxDDS is

  port (
    Clk_CI           : in  std_logic;
    Reset_SI         : in  std_logic;
    FreqTick_SI      : in  std_logic;
    FreqIncrement_D  : in  std_logic_vector(28 downto 0);
    FreqIncrValid_SI : in  std_logic;
    Waveform_DO      : out std_logic_vector(9 downto 0));

end entity MusicBoxDDS;


architecture RTL of MusicBoxDDS is

  -- distribution
  signal EnableShift_S : std_logic_vector(15 downto 0) := (0 => '1', others => '0');

  -- collection
  type wave_addr_gen_t is array(0 to 15) of std_logic_vector(11 downto 0);
  signal WaveAddrGen_D   : wave_addr_gen_t               := (others => (others => '0'));
  signal WaveAddr_D      : std_logic_vector(11 downto 0) := (others => '0');
  type env_addr_gen_t is array(0 to 15) of std_logic_vector(7 downto 0);
  signal EnvAddrGen_D    : env_addr_gen_t                := (others => (others => '0'));
  signal EnvAddr_D       : std_logic_vector(7 downto 0)  := (others => '0');
  signal CollectionCnt_S : unsigned(3 downto 0)          := (others => '0');
  signal ColCntZero_S    : std_logic                     := '0';

  -- multiply accumulate
  signal WaveformROM_D      : std_logic_vector(7 downto 0) := (others => '0');
  signal WaveformToMul_D    : signed(8 downto 0)           := (others => '0');
  signal EnvelopeROM_D      : std_logic_vector(7 downto 0) := (others => '0');
  signal EnvelopeToMul_D    : signed(8 downto 0)           := (others => '0');
  signal WaveformPostMul_D  : signed(21 downto 0)          := (others => '0');
  signal WaveformSum_D      : signed(21 downto 0)          := (others => '0');
  signal WaveformUnsigned_D : signed(21 downto 0)          := (others => '0');

begin  -- architecture RTL

  -----------------------------------------------------------------------------
  -- Distribute the Enable
  -----------------------------------------------------------------------------
  shift_ena_reg : process (Clk_CI) is
  begin
    if Clk_CI'event and Clk_CI = '1' then
      if Reset_SI = '1' then
        EnableShift_S <= ("0000000000000001");
      else
        if FreqIncrValid_SI = '1' then
          EnableShift_S <= EnableShift_S(14 downto 0) & EnableShift_S(15);
        end if;
      end if;
    end if;
  end process shift_ena_reg;

  -----------------------------------------------------------------------------
  -- Generate the wave address generators
  -----------------------------------------------------------------------------
  wave_addr_gens : for i in 0 to 15 generate
    DDSAddressGenerator_i : entity work.DDSAddressGenerator
      generic map (
        ENV_DECAY_SPEED   => 8192,
        DDS_COUNTER_WIDTH => 29)
      port map (
        Clk_CI            => Clk_CI,
        Reset_SI          => Reset_SI,
        Increment_DI      => FreqIncrement_D,
        IncrementValid_SI => (FreqIncrValid_SI and EnableShift_S(i)),
        FreqTick_SI       => FreqTick_SI,
        DDSAddr_DO        => WaveAddrGen_D(i),
        EnvAddr_DO        => EnvAddrGen_D(i));
  end generate wave_addr_gens;

  -----------------------------------------------------------------------------
  -- Put Outputs through Env and Wave ROM
  -----------------------------------------------------------------------------

  -- counter for collection
  output_cnt : process (Clk_CI) is
  begin
    if Clk_CI'event and Clk_CI = '1' then
      if Reset_SI = '1' then
        CollectionCnt_S <= (others => '0');
      else
        CollectionCnt_S <= CollectionCnt_S + 1;
      end if;
    end if;
  end process output_cnt;

  -- Mux (each latency 2)
  WaveAddrMux_i : entity work.WaveAddrMux
    port map (
      clock   => Clk_CI,
      data0x  => WaveAddrGen_D(0),
      data1x  => WaveAddrGen_D(1),
      data2x  => WaveAddrGen_D(2),
      data3x  => WaveAddrGen_D(3),
      data4x  => WaveAddrGen_D(4),
      data5x  => WaveAddrGen_D(5),
      data6x  => WaveAddrGen_D(6),
      data7x  => WaveAddrGen_D(7),
      data8x  => WaveAddrGen_D(8),
      data9x  => WaveAddrGen_D(9),
      data10x => WaveAddrGen_D(10),
      data11x => WaveAddrGen_D(11),
      data12x => WaveAddrGen_D(12),
      data13x => WaveAddrGen_D(13),
      data14x => WaveAddrGen_D(14),
      data15x => WaveAddrGen_D(15),
      sel     => std_logic_vector(CollectionCnt_S),
      result  => WaveAddr_D);
  EnvAddrMux_i : entity work.EnvAddrMux
    port map (
      clock   => Clk_CI,
      data0x  => EnvAddrGen_D(0),
      data1x  => EnvAddrGen_D(1),
      data2x  => EnvAddrGen_D(2),
      data3x  => EnvAddrGen_D(3),
      data4x  => EnvAddrGen_D(4),
      data5x  => EnvAddrGen_D(5),
      data6x  => EnvAddrGen_D(6),
      data7x  => EnvAddrGen_D(7),
      data8x  => EnvAddrGen_D(8),
      data9x  => EnvAddrGen_D(9),
      data10x => EnvAddrGen_D(10),
      data11x => EnvAddrGen_D(11),
      data12x => EnvAddrGen_D(12),
      data13x => EnvAddrGen_D(13),
      data14x => EnvAddrGen_D(14),
      data15x => EnvAddrGen_D(15),
      sel     => std_logic_vector(CollectionCnt_S),
      result  => EnvAddr_D);

  -- Wave and Env ROM (each latency 2)
  WaveformROM_i : entity work.WaveformROM
    port map (
      address => WaveAddr_D,
      clock   => Clk_CI,
      q       => WaveformROM_D);
  EnvelopeROM_i : entity work.EnvelopeROM
    port map (
      address => EnvAddr_D,
      clock   => Clk_CI,
      q       => EnvelopeROM_D);


  -----------------------------------------------------------------------------
  -- Multiply and Accumulate
  -----------------------------------------------------------------------------

  -- resize words
  premul_reg : process (Clk_CI) is
  begin  -- process premul_reg
    if Clk_CI'event and Clk_CI = '1' then  -- rising clock edge
      WaveformToMul_D <= resize(signed(WaveformROM_D), 9);
      EnvelopeToMul_D <= signed('0' & EnvelopeROM_D);
    end if;
  end process premul_reg;

  -- multiply and resize for accumulation
  WaveformPostMul_D <= resize(WaveformToMul_D * EnvelopeToMul_D, 22);

  -- accumulate
  ColCntZero_S <= bool2sl(CollectionCnt_S = "0000");
  accumulate_reg : process (Clk_CI) is
  begin  -- process accumulate_reg
    if Clk_CI'event and Clk_CI = '1' then
      if Reset_SI = '1' then
        WaveformSum_D <= (others => '0');
      else
        if ColCntZero_S = '1' then
          WaveformSum_D <= WaveformPostMul_D;
        else
          WaveformSum_D <= WaveformSum_D + WaveformPostMul_D;
        end if;
      end if;
    end if;
  end process accumulate_reg;

  -- calculate unsigned
  unsigned_reg : process (Clk_CI) is
  begin  -- process unsigned_reg
    if Clk_CI'event and Clk_CI = '1' then
      if Reset_SI = '1' then
        WaveformUnsigned_D <= (others => '0');
      else
        if ColCntZero_S = '1' then
          WaveformUnsigned_D <= WaveformSum_D + to_signed(2**20, 22);
        end if;
      end if;
    end if;
  end process unsigned_reg;

  -- output register
  output_reg : process (Clk_CI) is
  begin  -- process output_reg
    if Clk_CI'event and Clk_CI = '1' then
      if Reset_SI = '1' then
        Waveform_DO <= (others => '0');
      else
        Waveform_DO <= std_logic_vector(WaveformUnsigned_D(20 downto 11));
      end if;
    end if;
  end process output_reg;


end architecture RTL;
