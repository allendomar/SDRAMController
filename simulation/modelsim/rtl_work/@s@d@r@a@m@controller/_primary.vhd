library verilog;
use verilog.vl_types.all;
entity SDRAMController is
    port(
        CLK             : in     vl_logic;
        RESET           : in     vl_logic;
        SD_CLK          : out    vl_logic;
        SD_CKE          : out    vl_logic;
        SD_CS           : out    vl_logic;
        SD_WE           : out    vl_logic;
        SD_CAS          : out    vl_logic;
        SD_RAS          : out    vl_logic;
        SD_LDQM         : out    vl_logic;
        SD_UDQM         : out    vl_logic;
        SD_BS           : out    vl_logic_vector(1 downto 0);
        S_A             : out    vl_logic_vector(11 downto 0);
        S_DQ            : inout  vl_logic_vector(15 downto 0);
        re              : out    vl_logic;
        s               : in     vl_logic_vector(3 downto 0);
        led             : out    vl_logic_vector(3 downto 0)
    );
end SDRAMController;
