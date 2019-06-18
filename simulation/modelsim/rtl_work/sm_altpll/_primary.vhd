library verilog;
use verilog.vl_types.all;
entity sm_altpll is
    port(
        inclk0          : in     vl_logic;
        c0              : out    vl_logic
    );
end sm_altpll;
