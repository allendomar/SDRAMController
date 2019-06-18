library verilog;
use verilog.vl_types.all;
entity sm_altpll_altpll is
    port(
        clk             : out    vl_logic_vector(4 downto 0);
        inclk           : in     vl_logic_vector(1 downto 0)
    );
end sm_altpll_altpll;
