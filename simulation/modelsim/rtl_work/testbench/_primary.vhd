library verilog;
use verilog.vl_types.all;
entity testbench is
    generic(
        Tt              : integer := 500
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Tt : constant is 1;
end testbench;
