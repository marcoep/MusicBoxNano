-------------------------------------------------------------------------------
-- Title      : Song ROM and Duration Counter
-- Project    : 
-------------------------------------------------------------------------------
-- File       : SongDB.vhd
-- Author     :   <Marco@JUDI-WIN10>
-- Company    : 
-- Created    : 2016-07-28
-- Last update: 2016-07-29
-- Platform   : Mentor Graphics ModelSim, Altera Quartus
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Implements the song ROM and the duration counter to release the
-- next key.
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

library work;
use work.Helpers_Pkg.all;


entity SongDB is

  port (
    Clk_CI         : in  std_logic;
    Reset_SI       : in  std_logic;
    KeyTick_SI     : in  std_logic;
    NewKeyData_DO  : out std_logic_vector(6 downto 0);
    NewKeyValid_SO : out std_logic);

end entity SongDB;


architecture RTL of SongDB is

  -- ROM constants (adapt to Quartus IP and generated .mif file)
  constant SONG_ROM_ADDR_WIDTH : integer := 11;  -- adapt to song ROM address width
  constant MAX_SONG_ADDR       : integer := 1067;  -- adapt to song ROM depth

  -- duration counter
  constant DURATION_COUNTER_WIDTH : integer                                     := 10;  -- fixed in MATLAB
  signal DurCounter_S             : unsigned(DURATION_COUNTER_WIDTH-1 downto 0) := (others => '0');
  signal DurationZero_S           : std_logic                                   := '0';
  signal LoadNextDuration_S       : std_logic                                   := '0';

  -- address counter
  signal GenNextAddr_S : std_logic                                := '0';
  signal AddrCounter_S : unsigned(SONG_ROM_ADDR_WIDTH-1 downto 0) := (others => '0');

  -- song rom output
  signal ROMout_D      : std_logic_vector(16 downto 0) := (others => '0');
  signal CurKey_D      : std_logic_vector(6 downto 0)  := (others => '0');
  signal CurDuration_D : std_logic_vector(9 downto 0)  := (others => '0');

  -- fsm
  type states_t is (INIT, WAITZERO, ADDRLAT1, ROMLAT1, ROMLAT2);
  signal State_SN, State_SP : states_t;

begin  -- architecture RTL

  -- instantiate song rom (latency 2)
  SongROM_i : entity work.SongROM
    port map (
      address => std_logic_vector(AddrCounter_S),
      clock   => Clk_CI,
      q       => ROMout_D);
  CurKey_D      <= ROMout_D(6 downto 0);
  CurDuration_D <= ROMout_D(16 downto 7);


  -- address counter
  addr_gen : process (Clk_CI) is
  begin  -- process addr_gen
    if Clk_CI'event and Clk_CI = '1' then  -- rising clock edge
      if Reset_SI = '1' then               -- synchronous reset (active high)
        AddrCounter_S <= (others => '0');
      else
        if GenNextAddr_S = '1' then
          if AddrCounter_S = MAX_SONG_ADDR then
            AddrCounter_S <= (others => '0');
          else
            AddrCounter_S <= AddrCounter_S + 1;
          end if;
        end if;
      end if;
    end if;
  end process addr_gen;


  -- duration counter
  dur_gen : process (Clk_CI) is
  begin  -- process addr_gen
    if Clk_CI'event and Clk_CI = '1' then  -- rising clock edge
      if Reset_SI = '1' then               -- synchronous reset (active high)
        DurCounter_S <= (others => '0');
      else
        if KeyTick_SI = '1' then
          DurCounter_S <= DurCounter_S - 1;
        end if;
        if LoadNextDuration_S = '1' then
          DurCounter_S <= unsigned(CurDuration_D);
        end if;
      end if;
    end if;
  end process dur_gen;

  DurationZero_S <= bool2sl(DurCounter_S = 0);


  -- outputs
  NewKeyData_DO  <= CurKey_D;
  NewKeyValid_SO <= LoadNextDuration_S;


  -----------------------------------------------------------------------------
  -- FSM
  -----------------------------------------------------------------------------

  fsm_comb : process (DurationZero_S, State_SP) is
  begin  -- process fsm_comb

    -- default assignments
    State_SN           <= State_SP;
    LoadNextDuration_S <= '0';
    GenNextAddr_S      <= '0';

    case State_SP is
      when INIT =>
        -- init state, duration does not matter, just load address 0 data for
        -- the first note
        State_SN <= ADDRLAT1;
      -------------------------------------------------------------------------
      when WAITZERO =>
        if DurationZero_S = '1' then
          GenNextAddr_S <= '1';
          State_SN      <= ADDRLAT1;
        end if;
      -------------------------------------------------------------------------
      when ADDRLAT1 =>
        State_SN <= ROMLAT1;
      -------------------------------------------------------------------------
      when ROMLAT1 =>
        State_SN <= ROMLAT2;
      -------------------------------------------------------------------------
      when ROMLAT2 =>
        LoadNextDuration_S <= '1';
        State_SN           <= WAITZERO;
      -----------------------------------------------------------------------
      when others =>
        State_SN <= INIT;
    end case;
  end process fsm_comb;

  fsm_reg : process (Clk_CI) is
  begin  -- process fsm_reg
    if Clk_CI'event and Clk_CI = '1' then  -- rising clock edge
      if Reset_SI = '1' then               -- synchronous reset (active high)
        State_SP <= INIT;
      else
        State_SP <= State_SN;
      end if;
    end if;
  end process fsm_reg;



end architecture RTL;
