# ===== hul_async_groups.xdc (Final FIX) =====
# Define groups using manually defined clean clock names
set_clock_groups -asynchronous \
  -group [get_clocks {clk_trg clk_gtx clk_int clk_out4}] \
  -group [get_clocks {clk_sys}]
# =======================================================