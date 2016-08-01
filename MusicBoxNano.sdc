create_clock -period 20.000 -name CLOCK_50 [get_ports CLOCK_50]
derive_pll_clocks
derive_clock_uncertainty

# clock sync flipflops are false pathed
set_false_path -to [get_registers *clk_sync_*]
