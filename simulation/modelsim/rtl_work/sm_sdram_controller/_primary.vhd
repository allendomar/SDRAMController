library verilog;
use verilog.vl_types.all;
entity sm_sdram_controller is
    generic(
        CAS_LATENCY     : integer := 3;
        INIT_CYCL       : integer := 100
    );
    port(
        clkIn           : in     vl_logic;
        rst_n           : in     vl_logic;
        cs              : in     vl_logic;
        we              : in     vl_logic;
        re              : out    vl_logic;
        ready           : out    vl_logic;
        a               : in     vl_logic_vector(5 downto 0);
        wd              : in     vl_logic_vector(31 downto 0);
        rd              : out    vl_logic_vector(31 downto 0);
        sd_clk          : out    vl_logic;
        sd_cke          : out    vl_logic;
        sd_cs           : out    vl_logic;
        sd_we           : out    vl_logic;
        sd_cas          : out    vl_logic;
        sd_ras          : out    vl_logic;
        sd_ldqm         : out    vl_logic;
        sd_udqm         : out    vl_logic;
        sd_bs           : out    vl_logic_vector(1 downto 0);
        s_a             : out    vl_logic_vector(11 downto 0);
        s_dq            : inout  vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CAS_LATENCY : constant is 1;
    attribute mti_svvh_generic_type of INIT_CYCL : constant is 1;
end sm_sdram_controller;
