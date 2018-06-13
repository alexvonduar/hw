// ================================================================
// NVDLA Open Source Project
// 
// Copyright(c) 2016 - 2017 NVIDIA Corporation.  Licensed under the
// NVDLA Open Hardware License; Check "LICENSE" which comes with 
// this distribution for more information.
// ================================================================

// File Name: HLS_cdp_icvt.v

module HLS_cdp_icvt (
   cfg_alu_in_rsc_z    //|< i
  ,cfg_mul_in_rsc_z    //|< i
  ,cfg_truncate_rsc_z  //|< i
  ,chn_data_in_rsc_vz  //|< i
  ,chn_data_in_rsc_z   //|< i
  ,chn_data_out_rsc_vz //|< i
  ,nvdla_core_clk      //|< i
  ,nvdla_core_rstn     //|< i
  ,chn_data_in_rsc_lz  //|> o
  ,chn_data_out_rsc_lz //|> o
  ,chn_data_out_rsc_z  //|> o
  );

input   [7:0] cfg_alu_in_rsc_z;
input  [15:0] cfg_mul_in_rsc_z;
input   [4:0] cfg_truncate_rsc_z;
input         chn_data_in_rsc_vz;
input   [7:0] chn_data_in_rsc_z;
input         chn_data_out_rsc_vz;
input         nvdla_core_clk;
input         nvdla_core_rstn;
output        chn_data_in_rsc_lz;
output        chn_data_out_rsc_lz;
output  [8:0] chn_data_out_rsc_z;

wire    [8:0] cfg_alu_ext;
wire    [7:0] cfg_alu_in;
wire   [15:0] cfg_mul_in;
wire    [4:0] cfg_truncate;
wire    [8:0] chn_data_ext;
wire    [7:0] chn_data_in;
wire    [8:0] chn_data_out;
wire          chn_in_prdy;
wire          chn_in_pvld;
wire          chn_out_prdy;
wire          chn_out_pvld;
wire          mon_sub_c;
wire   [24:0] mul_data_out;
wire   [24:0] mul_dout;
wire          mul_out_prdy;
wire          mul_out_pvld;
wire    [8:0] sub_data_out;
wire    [8:0] sub_dout;
wire          sub_out_prdy;
wire          sub_out_pvld;
wire    [8:0] tru_dout;


// synoff nets

// monitor nets

// debug nets

// tie high nets

// tie low nets

// no connect nets

// not all bits used nets

// todo nets

    
assign   chn_in_pvld  = chn_data_in_rsc_vz; 
assign   chn_out_prdy = chn_data_out_rsc_vz;
assign   chn_data_in[7:0]  = chn_data_in_rsc_z[7:0];  
assign   cfg_alu_in[7:0] = cfg_alu_in_rsc_z[7:0];   
assign   cfg_mul_in[15:0] = cfg_mul_in_rsc_z[15:0];
assign   cfg_truncate[4:0]  = cfg_truncate_rsc_z[4:0]; 

assign   chn_data_in_rsc_lz  = chn_in_prdy;  
assign   chn_data_out_rsc_lz = chn_out_pvld; 
assign   chn_data_out_rsc_z[8:0] = chn_data_out[8:0];

//cvt
assign   chn_data_ext[8:0] = {{1{chn_data_in[7]}}, chn_data_in[7:0]}; 
assign   cfg_alu_ext[8:0]  = {{1{cfg_alu_in[7]}}, cfg_alu_in[7:0]};

//sub
assign   {mon_sub_c,sub_dout[8:0]} = $signed(chn_data_ext[8:0]) -$signed(cfg_alu_ext[8:0]);

HLS_cdp_ICVT_pipe_p1 pipe_p1 (
   .nvdla_core_clk  (nvdla_core_clk)     //|< i
  ,.nvdla_core_rstn (nvdla_core_rstn)    //|< i
  ,.chn_in_pvld     (chn_in_pvld)        //|< w
  ,.sub_dout        (sub_dout[8:0])      //|< w
  ,.sub_out_prdy    (sub_out_prdy)       //|< w
  ,.chn_in_prdy     (chn_in_prdy)        //|> w
  ,.sub_data_out    (sub_data_out[8:0])  //|> w
  ,.sub_out_pvld    (sub_out_pvld)       //|> w
  );

//mul 
assign   mul_dout[24:0] = $signed(sub_data_out[8:0]) * $signed(cfg_mul_in[15:0]);

HLS_cdp_ICVT_pipe_p2 pipe_p2 (
   .nvdla_core_clk  (nvdla_core_clk)     //|< i
  ,.nvdla_core_rstn (nvdla_core_rstn)    //|< i
  ,.mul_dout        (mul_dout[24:0])     //|< w
  ,.mul_out_prdy    (mul_out_prdy)       //|< w
  ,.sub_out_pvld    (sub_out_pvld)       //|< w
  ,.mul_data_out    (mul_data_out[24:0]) //|> w
  ,.mul_out_pvld    (mul_out_pvld)       //|> w
  ,.sub_out_prdy    (sub_out_prdy)       //|> w
  );

//truncate
NV_NVDLA_HLS_shiftrightsu #(.IN_WIDTH(16 + 9 ),.OUT_WIDTH(9 ),.SHIFT_WIDTH(5 )) shiftright_su (
   .data_in         (mul_data_out[24:0]) //|< w
  ,.shift_num       (cfg_truncate[4:0])  //|< w
  ,.data_out        (tru_dout[8:0])      //|> w
  );
//signed 
//unsigned

HLS_cdp_ICVT_pipe_p3 pipe_p3 (
   .nvdla_core_clk  (nvdla_core_clk)     //|< i
  ,.nvdla_core_rstn (nvdla_core_rstn)    //|< i
  ,.chn_out_prdy    (chn_out_prdy)       //|< w
  ,.mul_out_pvld    (mul_out_pvld)       //|< w
  ,.tru_dout        (tru_dout[8:0])      //|< w
  ,.chn_data_out    (chn_data_out[8:0])  //|> w
  ,.chn_out_pvld    (chn_out_pvld)       //|> w
  ,.mul_out_prdy    (mul_out_prdy)       //|> w
  );

endmodule // HLS_cdp_icvt



// **************************************************************************************************************
// Generated by ::pipe -m -bc -rand none -is sub_data_out[8:0] (sub_out_pvld,sub_out_prdy) <= sub_dout[8:0] (chn_in_pvld,chn_in_prdy)
// **************************************************************************************************************
module HLS_cdp_ICVT_pipe_p1 (
   nvdla_core_clk
  ,nvdla_core_rstn
  ,chn_in_pvld
  ,sub_dout
  ,sub_out_prdy
  ,chn_in_prdy
  ,sub_data_out
  ,sub_out_pvld
  );
input        nvdla_core_clk;
input        nvdla_core_rstn;
input        chn_in_pvld;
input  [8:0] sub_dout;
input        sub_out_prdy;
output       chn_in_prdy;
output [8:0] sub_data_out;
output       sub_out_pvld;
reg          chn_in_prdy;
reg    [8:0] p1_pipe_data;
reg          p1_pipe_ready;
reg          p1_pipe_ready_bc;
reg          p1_pipe_valid;
reg          p1_skid_catch;
reg    [8:0] p1_skid_data;
reg    [8:0] p1_skid_pipe_data;
reg          p1_skid_pipe_ready;
reg          p1_skid_pipe_valid;
reg          p1_skid_ready;
reg          p1_skid_ready_flop;
reg          p1_skid_valid;
reg    [8:0] sub_data_out;
reg          sub_out_pvld;
//## pipe (1) skid buffer
always @(
  chn_in_pvld
  or p1_skid_ready_flop
  or p1_skid_pipe_ready
  or p1_skid_valid
  ) begin
  p1_skid_catch = chn_in_pvld && p1_skid_ready_flop && !p1_skid_pipe_ready;  
  p1_skid_ready = (p1_skid_valid)? p1_skid_pipe_ready : !p1_skid_catch;
end
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
  if (!nvdla_core_rstn) begin
    p1_skid_valid <= 1'b0;
    p1_skid_ready_flop <= 1'b1;
    chn_in_prdy <= 1'b1;
  end else begin
  p1_skid_valid <= (p1_skid_valid)? !p1_skid_pipe_ready : p1_skid_catch;
  p1_skid_ready_flop <= p1_skid_ready;
  chn_in_prdy <= p1_skid_ready;
  end
end
always @(posedge nvdla_core_clk) begin
  // VCS sop_coverage_off start
  p1_skid_data <= (p1_skid_catch)? sub_dout[8:0] : p1_skid_data;
  // VCS sop_coverage_off end
end
always @(
  p1_skid_ready_flop
  or chn_in_pvld
  or p1_skid_valid
  or sub_dout
  or p1_skid_data
  ) begin
  p1_skid_pipe_valid = (p1_skid_ready_flop)? chn_in_pvld : p1_skid_valid; 
  // VCS sop_coverage_off start
  p1_skid_pipe_data = (p1_skid_ready_flop)? sub_dout[8:0] : p1_skid_data;
  // VCS sop_coverage_off end
end
//## pipe (1) valid-ready-bubble-collapse
always @(
  p1_pipe_ready
  or p1_pipe_valid
  ) begin
  p1_pipe_ready_bc = p1_pipe_ready || !p1_pipe_valid;
end
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
  if (!nvdla_core_rstn) begin
    p1_pipe_valid <= 1'b0;
  end else begin
  p1_pipe_valid <= (p1_pipe_ready_bc)? p1_skid_pipe_valid : 1'd1;
  end
end
always @(posedge nvdla_core_clk) begin
  // VCS sop_coverage_off start
  p1_pipe_data <= (p1_pipe_ready_bc && p1_skid_pipe_valid)? p1_skid_pipe_data : p1_pipe_data;
  // VCS sop_coverage_off end
end
always @(
  p1_pipe_ready_bc
  ) begin
  p1_skid_pipe_ready = p1_pipe_ready_bc;
end
//## pipe (1) output
always @(
  p1_pipe_valid
  or sub_out_prdy
  or p1_pipe_data
  ) begin
  sub_out_pvld = p1_pipe_valid;
  p1_pipe_ready = sub_out_prdy;
  sub_data_out[8:0] = p1_pipe_data;
end
//## pipe (1) assertions/testpoints
`ifndef VIVA_PLUGIN_PIPE_DISABLE_ASSERTIONS
wire p1_assert_clk = nvdla_core_clk;
`ifdef SPYGLASS_ASSERT_ON
`else
// spyglass disable_block NoWidthInBasedNum-ML 
// spyglass disable_block STARC-2.10.3.2a 
// spyglass disable_block STARC05-2.1.3.1 
// spyglass disable_block STARC-2.1.4.6 
// spyglass disable_block W116 
// spyglass disable_block W154 
// spyglass disable_block W239 
// spyglass disable_block W362 
// spyglass disable_block WRN_58 
// spyglass disable_block WRN_61 
`endif // SPYGLASS_ASSERT_ON
`ifdef ASSERT_ON
`ifdef FV_ASSERT_ON
`define ASSERT_RESET nvdla_core_rstn
`else
`ifdef SYNTHESIS
`define ASSERT_RESET nvdla_core_rstn
`else
`ifdef ASSERT_OFF_RESET_IS_X
`define ASSERT_RESET ((1'bx === nvdla_core_rstn) ? 1'b0 : nvdla_core_rstn)
`else
`define ASSERT_RESET ((1'bx === nvdla_core_rstn) ? 1'b1 : nvdla_core_rstn)
`endif // ASSERT_OFF_RESET_IS_X
`endif // SYNTHESIS
`endif // FV_ASSERT_ON
`ifndef SYNTHESIS
  // VCS coverage off 
  nv_assert_no_x #(0,1,0,"No X's allowed on control signals")      zzz_assert_no_x_1x (nvdla_core_clk, `ASSERT_RESET, nvdla_core_rstn, (sub_out_pvld^sub_out_prdy^chn_in_pvld^chn_in_prdy)); // spyglass disable W504 SelfDeterminedExpr-ML 
  // VCS coverage on
`endif
`undef ASSERT_RESET
`endif // ASSERT_ON
`ifdef SPYGLASS_ASSERT_ON
`else
// spyglass enable_block NoWidthInBasedNum-ML 
// spyglass enable_block STARC-2.10.3.2a 
// spyglass enable_block STARC05-2.1.3.1 
// spyglass enable_block STARC-2.1.4.6 
// spyglass enable_block W116 
// spyglass enable_block W154 
// spyglass enable_block W239 
// spyglass enable_block W362 
// spyglass enable_block WRN_58 
// spyglass enable_block WRN_61 
`endif // SPYGLASS_ASSERT_ON
`ifdef SPYGLASS_ASSERT_ON
`else
// spyglass disable_block NoWidthInBasedNum-ML 
// spyglass disable_block STARC-2.10.3.2a 
// spyglass disable_block STARC05-2.1.3.1 
// spyglass disable_block STARC-2.1.4.6 
// spyglass disable_block W116 
// spyglass disable_block W154 
// spyglass disable_block W239 
// spyglass disable_block W362 
// spyglass disable_block WRN_58 
// spyglass disable_block WRN_61 
`endif // SPYGLASS_ASSERT_ON
`ifdef ASSERT_ON
`ifdef FV_ASSERT_ON
`define ASSERT_RESET nvdla_core_rstn
`else
`ifdef SYNTHESIS
`define ASSERT_RESET nvdla_core_rstn
`else
`ifdef ASSERT_OFF_RESET_IS_X
`define ASSERT_RESET ((1'bx === nvdla_core_rstn) ? 1'b0 : nvdla_core_rstn)
`else
`define ASSERT_RESET ((1'bx === nvdla_core_rstn) ? 1'b1 : nvdla_core_rstn)
`endif // ASSERT_OFF_RESET_IS_X
`endif // SYNTHESIS
`endif // FV_ASSERT_ON
  // VCS coverage off 
  nv_assert_hold_throughout_event_interval #(0,1,0,"valid removed before ready")      zzz_assert_hold_throughout_event_interval_2x (nvdla_core_clk, `ASSERT_RESET, (chn_in_pvld && !chn_in_prdy), (chn_in_pvld), (chn_in_prdy)); // spyglass disable W504 SelfDeterminedExpr-ML 
  // VCS coverage on
`undef ASSERT_RESET
`endif // ASSERT_ON
`ifdef SPYGLASS_ASSERT_ON
`else
// spyglass enable_block NoWidthInBasedNum-ML 
// spyglass enable_block STARC-2.10.3.2a 
// spyglass enable_block STARC05-2.1.3.1 
// spyglass enable_block STARC-2.1.4.6 
// spyglass enable_block W116 
// spyglass enable_block W154 
// spyglass enable_block W239 
// spyglass enable_block W362 
// spyglass enable_block WRN_58 
// spyglass enable_block WRN_61 
`endif // SPYGLASS_ASSERT_ON
`endif
endmodule // HLS_cdp_ICVT_pipe_p1




// **************************************************************************************************************
// Generated by ::pipe -m -bc -rand none -is mul_data_out[24:0] (mul_out_pvld,mul_out_prdy) <= mul_dout[24:0] (sub_out_pvld,sub_out_prdy)
// **************************************************************************************************************
module HLS_cdp_ICVT_pipe_p2 (
   nvdla_core_clk
  ,nvdla_core_rstn
  ,mul_dout
  ,mul_out_prdy
  ,sub_out_pvld
  ,mul_data_out
  ,mul_out_pvld
  ,sub_out_prdy
  );
input         nvdla_core_clk;
input         nvdla_core_rstn;
input  [24:0] mul_dout;
input         mul_out_prdy;
input         sub_out_pvld;
output [24:0] mul_data_out;
output        mul_out_pvld;
output        sub_out_prdy;
reg    [24:0] mul_data_out;
reg           mul_out_pvld;
reg    [24:0] p2_pipe_data;
reg           p2_pipe_ready;
reg           p2_pipe_ready_bc;
reg           p2_pipe_valid;
reg           p2_skid_catch;
reg    [24:0] p2_skid_data;
reg    [24:0] p2_skid_pipe_data;
reg           p2_skid_pipe_ready;
reg           p2_skid_pipe_valid;
reg           p2_skid_ready;
reg           p2_skid_ready_flop;
reg           p2_skid_valid;
reg           sub_out_prdy;
//## pipe (2) skid buffer
always @(
  sub_out_pvld
  or p2_skid_ready_flop
  or p2_skid_pipe_ready
  or p2_skid_valid
  ) begin
  p2_skid_catch = sub_out_pvld && p2_skid_ready_flop && !p2_skid_pipe_ready;  
  p2_skid_ready = (p2_skid_valid)? p2_skid_pipe_ready : !p2_skid_catch;
end
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
  if (!nvdla_core_rstn) begin
    p2_skid_valid <= 1'b0;
    p2_skid_ready_flop <= 1'b1;
    sub_out_prdy <= 1'b1;
  end else begin
  p2_skid_valid <= (p2_skid_valid)? !p2_skid_pipe_ready : p2_skid_catch;
  p2_skid_ready_flop <= p2_skid_ready;
  sub_out_prdy <= p2_skid_ready;
  end
end
always @(posedge nvdla_core_clk) begin
  // VCS sop_coverage_off start
  p2_skid_data <= (p2_skid_catch)? mul_dout[24:0] : p2_skid_data;
  // VCS sop_coverage_off end
end
always @(
  p2_skid_ready_flop
  or sub_out_pvld
  or p2_skid_valid
  or mul_dout
  or p2_skid_data
  ) begin
  p2_skid_pipe_valid = (p2_skid_ready_flop)? sub_out_pvld : p2_skid_valid; 
  // VCS sop_coverage_off start
  p2_skid_pipe_data = (p2_skid_ready_flop)? mul_dout[24:0] : p2_skid_data;
  // VCS sop_coverage_off end
end
//## pipe (2) valid-ready-bubble-collapse
always @(
  p2_pipe_ready
  or p2_pipe_valid
  ) begin
  p2_pipe_ready_bc = p2_pipe_ready || !p2_pipe_valid;
end
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
  if (!nvdla_core_rstn) begin
    p2_pipe_valid <= 1'b0;
  end else begin
  p2_pipe_valid <= (p2_pipe_ready_bc)? p2_skid_pipe_valid : 1'd1;
  end
end
always @(posedge nvdla_core_clk) begin
  // VCS sop_coverage_off start
  p2_pipe_data <= (p2_pipe_ready_bc && p2_skid_pipe_valid)? p2_skid_pipe_data : p2_pipe_data;
  // VCS sop_coverage_off end
end
always @(
  p2_pipe_ready_bc
  ) begin
  p2_skid_pipe_ready = p2_pipe_ready_bc;
end
//## pipe (2) output
always @(
  p2_pipe_valid
  or mul_out_prdy
  or p2_pipe_data
  ) begin
  mul_out_pvld = p2_pipe_valid;
  p2_pipe_ready = mul_out_prdy;
  mul_data_out[24:0] = p2_pipe_data;
end
//## pipe (2) assertions/testpoints
`ifndef VIVA_PLUGIN_PIPE_DISABLE_ASSERTIONS
wire p2_assert_clk = nvdla_core_clk;
`ifdef SPYGLASS_ASSERT_ON
`else
// spyglass disable_block NoWidthInBasedNum-ML 
// spyglass disable_block STARC-2.10.3.2a 
// spyglass disable_block STARC05-2.1.3.1 
// spyglass disable_block STARC-2.1.4.6 
// spyglass disable_block W116 
// spyglass disable_block W154 
// spyglass disable_block W239 
// spyglass disable_block W362 
// spyglass disable_block WRN_58 
// spyglass disable_block WRN_61 
`endif // SPYGLASS_ASSERT_ON
`ifdef ASSERT_ON
`ifdef FV_ASSERT_ON
`define ASSERT_RESET nvdla_core_rstn
`else
`ifdef SYNTHESIS
`define ASSERT_RESET nvdla_core_rstn
`else
`ifdef ASSERT_OFF_RESET_IS_X
`define ASSERT_RESET ((1'bx === nvdla_core_rstn) ? 1'b0 : nvdla_core_rstn)
`else
`define ASSERT_RESET ((1'bx === nvdla_core_rstn) ? 1'b1 : nvdla_core_rstn)
`endif // ASSERT_OFF_RESET_IS_X
`endif // SYNTHESIS
`endif // FV_ASSERT_ON
`ifndef SYNTHESIS
  // VCS coverage off 
  nv_assert_no_x #(0,1,0,"No X's allowed on control signals")      zzz_assert_no_x_3x (nvdla_core_clk, `ASSERT_RESET, nvdla_core_rstn, (mul_out_pvld^mul_out_prdy^sub_out_pvld^sub_out_prdy)); // spyglass disable W504 SelfDeterminedExpr-ML 
  // VCS coverage on
`endif
`undef ASSERT_RESET
`endif // ASSERT_ON
`ifdef SPYGLASS_ASSERT_ON
`else
// spyglass enable_block NoWidthInBasedNum-ML 
// spyglass enable_block STARC-2.10.3.2a 
// spyglass enable_block STARC05-2.1.3.1 
// spyglass enable_block STARC-2.1.4.6 
// spyglass enable_block W116 
// spyglass enable_block W154 
// spyglass enable_block W239 
// spyglass enable_block W362 
// spyglass enable_block WRN_58 
// spyglass enable_block WRN_61 
`endif // SPYGLASS_ASSERT_ON
`ifdef SPYGLASS_ASSERT_ON
`else
// spyglass disable_block NoWidthInBasedNum-ML 
// spyglass disable_block STARC-2.10.3.2a 
// spyglass disable_block STARC05-2.1.3.1 
// spyglass disable_block STARC-2.1.4.6 
// spyglass disable_block W116 
// spyglass disable_block W154 
// spyglass disable_block W239 
// spyglass disable_block W362 
// spyglass disable_block WRN_58 
// spyglass disable_block WRN_61 
`endif // SPYGLASS_ASSERT_ON
`ifdef ASSERT_ON
`ifdef FV_ASSERT_ON
`define ASSERT_RESET nvdla_core_rstn
`else
`ifdef SYNTHESIS
`define ASSERT_RESET nvdla_core_rstn
`else
`ifdef ASSERT_OFF_RESET_IS_X
`define ASSERT_RESET ((1'bx === nvdla_core_rstn) ? 1'b0 : nvdla_core_rstn)
`else
`define ASSERT_RESET ((1'bx === nvdla_core_rstn) ? 1'b1 : nvdla_core_rstn)
`endif // ASSERT_OFF_RESET_IS_X
`endif // SYNTHESIS
`endif // FV_ASSERT_ON
  // VCS coverage off 
  nv_assert_hold_throughout_event_interval #(0,1,0,"valid removed before ready")      zzz_assert_hold_throughout_event_interval_4x (nvdla_core_clk, `ASSERT_RESET, (sub_out_pvld && !sub_out_prdy), (sub_out_pvld), (sub_out_prdy)); // spyglass disable W504 SelfDeterminedExpr-ML 
  // VCS coverage on
`undef ASSERT_RESET
`endif // ASSERT_ON
`ifdef SPYGLASS_ASSERT_ON
`else
// spyglass enable_block NoWidthInBasedNum-ML 
// spyglass enable_block STARC-2.10.3.2a 
// spyglass enable_block STARC05-2.1.3.1 
// spyglass enable_block STARC-2.1.4.6 
// spyglass enable_block W116 
// spyglass enable_block W154 
// spyglass enable_block W239 
// spyglass enable_block W362 
// spyglass enable_block WRN_58 
// spyglass enable_block WRN_61 
`endif // SPYGLASS_ASSERT_ON
`endif
endmodule // HLS_cdp_ICVT_pipe_p2




// **************************************************************************************************************
// Generated by ::pipe -m -bc -rand none -is chn_data_out[8:0] (chn_out_pvld,chn_out_prdy) <= tru_dout[8:0] (mul_out_pvld,mul_out_prdy)
// **************************************************************************************************************
module HLS_cdp_ICVT_pipe_p3 (
   nvdla_core_clk
  ,nvdla_core_rstn
  ,chn_out_prdy
  ,mul_out_pvld
  ,tru_dout
  ,chn_data_out
  ,chn_out_pvld
  ,mul_out_prdy
  );
input        nvdla_core_clk;
input        nvdla_core_rstn;
input        chn_out_prdy;
input        mul_out_pvld;
input  [8:0] tru_dout;
output [8:0] chn_data_out;
output       chn_out_pvld;
output       mul_out_prdy;
reg    [8:0] chn_data_out;
reg          chn_out_pvld;
reg          mul_out_prdy;
reg    [8:0] p3_pipe_data;
reg          p3_pipe_ready;
reg          p3_pipe_ready_bc;
reg          p3_pipe_valid;
reg          p3_skid_catch;
reg    [8:0] p3_skid_data;
reg    [8:0] p3_skid_pipe_data;
reg          p3_skid_pipe_ready;
reg          p3_skid_pipe_valid;
reg          p3_skid_ready;
reg          p3_skid_ready_flop;
reg          p3_skid_valid;
//## pipe (3) skid buffer
always @(
  mul_out_pvld
  or p3_skid_ready_flop
  or p3_skid_pipe_ready
  or p3_skid_valid
  ) begin
  p3_skid_catch = mul_out_pvld && p3_skid_ready_flop && !p3_skid_pipe_ready;  
  p3_skid_ready = (p3_skid_valid)? p3_skid_pipe_ready : !p3_skid_catch;
end
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
  if (!nvdla_core_rstn) begin
    p3_skid_valid <= 1'b0;
    p3_skid_ready_flop <= 1'b1;
    mul_out_prdy <= 1'b1;
  end else begin
  p3_skid_valid <= (p3_skid_valid)? !p3_skid_pipe_ready : p3_skid_catch;
  p3_skid_ready_flop <= p3_skid_ready;
  mul_out_prdy <= p3_skid_ready;
  end
end
always @(posedge nvdla_core_clk) begin
  // VCS sop_coverage_off start
  p3_skid_data <= (p3_skid_catch)? tru_dout[8:0] : p3_skid_data;
  // VCS sop_coverage_off end
end
always @(
  p3_skid_ready_flop
  or mul_out_pvld
  or p3_skid_valid
  or tru_dout
  or p3_skid_data
  ) begin
  p3_skid_pipe_valid = (p3_skid_ready_flop)? mul_out_pvld : p3_skid_valid; 
  // VCS sop_coverage_off start
  p3_skid_pipe_data = (p3_skid_ready_flop)? tru_dout[8:0] : p3_skid_data;
  // VCS sop_coverage_off end
end
//## pipe (3) valid-ready-bubble-collapse
always @(
  p3_pipe_ready
  or p3_pipe_valid
  ) begin
  p3_pipe_ready_bc = p3_pipe_ready || !p3_pipe_valid;
end
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
  if (!nvdla_core_rstn) begin
    p3_pipe_valid <= 1'b0;
  end else begin
  p3_pipe_valid <= (p3_pipe_ready_bc)? p3_skid_pipe_valid : 1'd1;
  end
end
always @(posedge nvdla_core_clk) begin
  // VCS sop_coverage_off start
  p3_pipe_data <= (p3_pipe_ready_bc && p3_skid_pipe_valid)? p3_skid_pipe_data : p3_pipe_data;
  // VCS sop_coverage_off end
end
always @(
  p3_pipe_ready_bc
  ) begin
  p3_skid_pipe_ready = p3_pipe_ready_bc;
end
//## pipe (3) output
always @(
  p3_pipe_valid
  or chn_out_prdy
  or p3_pipe_data
  ) begin
  chn_out_pvld = p3_pipe_valid;
  p3_pipe_ready = chn_out_prdy;
  chn_data_out[8:0] = p3_pipe_data;
end
//## pipe (3) assertions/testpoints
`ifndef VIVA_PLUGIN_PIPE_DISABLE_ASSERTIONS
wire p3_assert_clk = nvdla_core_clk;
`ifdef SPYGLASS_ASSERT_ON
`else
// spyglass disable_block NoWidthInBasedNum-ML 
// spyglass disable_block STARC-2.10.3.2a 
// spyglass disable_block STARC05-2.1.3.1 
// spyglass disable_block STARC-2.1.4.6 
// spyglass disable_block W116 
// spyglass disable_block W154 
// spyglass disable_block W239 
// spyglass disable_block W362 
// spyglass disable_block WRN_58 
// spyglass disable_block WRN_61 
`endif // SPYGLASS_ASSERT_ON
`ifdef ASSERT_ON
`ifdef FV_ASSERT_ON
`define ASSERT_RESET nvdla_core_rstn
`else
`ifdef SYNTHESIS
`define ASSERT_RESET nvdla_core_rstn
`else
`ifdef ASSERT_OFF_RESET_IS_X
`define ASSERT_RESET ((1'bx === nvdla_core_rstn) ? 1'b0 : nvdla_core_rstn)
`else
`define ASSERT_RESET ((1'bx === nvdla_core_rstn) ? 1'b1 : nvdla_core_rstn)
`endif // ASSERT_OFF_RESET_IS_X
`endif // SYNTHESIS
`endif // FV_ASSERT_ON
`ifndef SYNTHESIS
  // VCS coverage off 
  nv_assert_no_x #(0,1,0,"No X's allowed on control signals")      zzz_assert_no_x_5x (nvdla_core_clk, `ASSERT_RESET, nvdla_core_rstn, (chn_out_pvld^chn_out_prdy^mul_out_pvld^mul_out_prdy)); // spyglass disable W504 SelfDeterminedExpr-ML 
  // VCS coverage on
`endif
`undef ASSERT_RESET
`endif // ASSERT_ON
`ifdef SPYGLASS_ASSERT_ON
`else
// spyglass enable_block NoWidthInBasedNum-ML 
// spyglass enable_block STARC-2.10.3.2a 
// spyglass enable_block STARC05-2.1.3.1 
// spyglass enable_block STARC-2.1.4.6 
// spyglass enable_block W116 
// spyglass enable_block W154 
// spyglass enable_block W239 
// spyglass enable_block W362 
// spyglass enable_block WRN_58 
// spyglass enable_block WRN_61 
`endif // SPYGLASS_ASSERT_ON
`ifdef SPYGLASS_ASSERT_ON
`else
// spyglass disable_block NoWidthInBasedNum-ML 
// spyglass disable_block STARC-2.10.3.2a 
// spyglass disable_block STARC05-2.1.3.1 
// spyglass disable_block STARC-2.1.4.6 
// spyglass disable_block W116 
// spyglass disable_block W154 
// spyglass disable_block W239 
// spyglass disable_block W362 
// spyglass disable_block WRN_58 
// spyglass disable_block WRN_61 
`endif // SPYGLASS_ASSERT_ON
`ifdef ASSERT_ON
`ifdef FV_ASSERT_ON
`define ASSERT_RESET nvdla_core_rstn
`else
`ifdef SYNTHESIS
`define ASSERT_RESET nvdla_core_rstn
`else
`ifdef ASSERT_OFF_RESET_IS_X
`define ASSERT_RESET ((1'bx === nvdla_core_rstn) ? 1'b0 : nvdla_core_rstn)
`else
`define ASSERT_RESET ((1'bx === nvdla_core_rstn) ? 1'b1 : nvdla_core_rstn)
`endif // ASSERT_OFF_RESET_IS_X
`endif // SYNTHESIS
`endif // FV_ASSERT_ON
  // VCS coverage off 
  nv_assert_hold_throughout_event_interval #(0,1,0,"valid removed before ready")      zzz_assert_hold_throughout_event_interval_6x (nvdla_core_clk, `ASSERT_RESET, (mul_out_pvld && !mul_out_prdy), (mul_out_pvld), (mul_out_prdy)); // spyglass disable W504 SelfDeterminedExpr-ML 
  // VCS coverage on
`undef ASSERT_RESET
`endif // ASSERT_ON
`ifdef SPYGLASS_ASSERT_ON
`else
// spyglass enable_block NoWidthInBasedNum-ML 
// spyglass enable_block STARC-2.10.3.2a 
// spyglass enable_block STARC05-2.1.3.1 
// spyglass enable_block STARC-2.1.4.6 
// spyglass enable_block W116 
// spyglass enable_block W154 
// spyglass enable_block W239 
// spyglass enable_block W362 
// spyglass enable_block WRN_58 
// spyglass enable_block WRN_61 
`endif // SPYGLASS_ASSERT_ON
`endif
endmodule // HLS_cdp_ICVT_pipe_p3



