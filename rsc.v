// RSC Block
`timescale 1 ns / 1 ns

module rsc(clk, bin_in, bin_x_out, bin_z_out, enable, rst_N, mode);
   //ADDED mode as input in order to indicate transmission bits
   input clk, bin_in, enable, rst_N,mode;
   output bin_x_out, bin_z_out;

   wire   clk, bin_in, rst_N;   // 1-bit wide
   wire   bin_x_out, bin_z_out;       // 1-bit wide

   reg [3:0] thisState;
   reg [3:0] nextState;
   reg       count = 2'd0;
   reg       tmp_x_out;
   reg       tmp_out;
   reg [5:0] tmp_tail_out;

   localparam STATE_0 = 4'd0,
      STATE_1  = 4'd1,
      STATE_2  = 4'd2,
      STATE_3  = 4'd3,
      STATE_4  = 4'd4,
      STATE_5  = 4'd5,
      STATE_6  = 4'd6,
      STATE_7  = 4'd7,
      STATE_8  = 4'd8,
      STATE_9  = 4'd9,
      STATE_10 = 4'd10,
      STATE_11 = 4'd11,
      STATE_12 = 4'd12,
      STATE_13 = 4'd13,
      STATE_14 = 4'd14,
      STATE_15 = 4'd15;


   always @(posedge clk) begin
      //in termination, no change in state
      if (~mode)
         thisState <= nextState;
   end

   always @(thisState or rst_N or mode or enable) begin
      nextState = 4'dx;
      if (rst_N) begin
         nextState = STATE_0;
         tmp_x_out = 1'b0;
         tmp_out = 1'b0;
         tmp_tail_out = 6'd0;
         count = 2'd0;
      end
      else begin
         if (~mode) begin
            tmp_x_out = bin_in;
            case(thisState)
               STATE_0 : begin    // 0 0 0 0
                  tmp_out = 1'b0;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_0; // 0 0 0 0
                  end
                  else
                     begin
                        nextState = STATE_8; // 1 0 0 0
                     end
               end
               STATE_1 : begin  // 0 0 0 1.
                  tmp_out = 1'b0;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_0; // 0 0 0 0
                  end
                  else begin
                     nextState = STATE_8; // 1 0 0 0
                  end
               end
               STATE_2 : begin    // 0 0 1 0
                  tmp_out = 1'b1;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_1; // 0 0 0 1

                  end
                  else begin
                     nextState = STATE_9; // 1 0 0 1
                  end
               end
               STATE_3 : begin // 0 0 1 1
                  tmp_out = 1'b1;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_1; // 0 0 0 1
                  end
                  else begin
                     nextState = STATE_9; // 1 0 0 1
                  end
               end
               STATE_4 : begin // 0 1 0 0
                  tmp_out = 1'b1;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_2; // 0 0 1 0
                  end
                  else begin
                     nextState = STATE_10; // 1 0 1 0
                  end
               end
               STATE_5 : begin // 0 1 0 1
                  tmp_out = 1'b1;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_2; // 0 0 1 0
                  end
                  else begin
                     nextState = STATE_10; // 1 0 1 0
                  end
               end
               STATE_6 : begin // 0 1 1 0
                  tmp_out = 1'b0;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_3; // 0 0 1 1
                  end
                  else begin
                     nextState = STATE_11; // 1 0 1 1
                  end
               end
               STATE_7 : begin // 0 1 1 1
                  tmp_out = 1'b0;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_3; // 0 0 1 1
                  end
                  else begin
                     nextState = STATE_11; // 1 0 1 1
                  end
               end
               STATE_8 : begin  // 1 0 0 0
                  tmp_out = 1'b1;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_4; // 0 1 0 0
                  end
                  else begin
                     nextState = STATE_12; // 1 1 0 0
                  end
               end
               STATE_9 : begin // 1 0 0 1
                  tmp_out = 1'b1;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_4; // 0 1 0 0
                  end
                  else begin
                     nextState = STATE_12; // 1 1 0 0
                  end
               end
               STATE_10 : begin // 1 0 1 0
                  tmp_out = 1'b0;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_5; // 0 1 0 1
                  end
                  else begin
                     nextState = STATE_13; // 1 1 0 1
                  end
               end
               STATE_11 : begin // 1 0 1 1
                  tmp_out = 1'b0;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_5; // 0 1 0 1
                  end
                  else begin
                     nextState = STATE_13; // 1 1 0 1
                  end
               end
               STATE_12 : begin // 1 1 0 0
                  tmp_out = 1'b0;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_6;  // 0 1 1 0
                  end
                  else begin
                     nextState = STATE_14; // 1 1 1 0
                  end
               end
               STATE_13 : begin // 1 1 0 1
                  tmp_out = 1'b0;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_6; // 0 1 1 0
                  end
                  else begin
                     nextState = STATE_14; // 1 1 1 0
                  end
               end
               STATE_14 : begin // 1 1 1 0
                  tmp_out = 1'b1;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_7; // 0 1 1 1
                  end
                  else begin
                     nextState = STATE_15; // 1 1 1 1
                  end
               end
               STATE_15 : begin // 1 1 1 1
                  tmp_out = 1'b1;
                  if(bin_in == 1'b0) begin
                     nextState = STATE_7; // 0 1 1 1
                  end
                  else begin
                     nextState = STATE_15; // 1 1 1 1
                  end
               end
            endcase
         end
         else begin
            if (count == 2'd0) begin
               case(thisState)
                  STATE_0 : begin    // 0 0 0 0
                     tmp_tail_out = 6'b000000;
                  end
                  STATE_1 : begin  // 0 0 0 1.
                     tmp_tail_out = 6'b110111;
                  end
                  STATE_2 : begin    // 0 0 1 0
                     tmp_tail_out = 6'b101011;
                  end
                  STATE_3 : begin // 0 0 1 1
                     tmp_tail_out = 6'b011100;
                  end
                  STATE_4 : begin // 0 1 0 0
                     tmp_tail_out = 6'b101100;
                  end
                  STATE_5 : begin // 0 1 0 1
                     tmp_tail_out = 6'b011011;
                  end
                  STATE_6 : begin // 0 1 1 0
                     tmp_tail_out = 6'b000111;
                  end
                  STATE_7 : begin // 0 1 1 1
                     tmp_tail_out = 6'b110000;
                  end
                  STATE_8 : begin  // 1 0 0 0
                     tmp_tail_out = 6'b011011;
                  end
                  STATE_9 : begin // 1 0 0 1
                     tmp_tail_out = 6'b101100;
                  end
                  STATE_10 : begin // 1 0 1 0
                     tmp_tail_out = 6'b110000;
                  end
                  STATE_11 : begin // 1 0 1 1
                     tmp_tail_out = 6'b000111;
                  end
                  STATE_12 : begin // 1 1 0 0
                     tmp_tail_out = 6'b110111;
                  end
                  STATE_13 : begin // 1 1 0 1
                     tmp_tail_out = 6'b000000;
                  end
                  STATE_14 : begin // 1 1 1 0
                     tmp_tail_out = 6'b011100;
                  end
                  STATE_15 : begin // 1 1 1 1
                     tmp_tail_out = 6'b101011;
                  end
               endcase
                  tmp_x_out = tmp_tail_out[0];
                  tmp_out = tmp_tail_out[1];
                  count = count + 1;
            end
            else if (count == 3'd1) begin
                  tmp_x_out = tmp_tail_out[2];
                  tmp_out = tmp_tail_out[3];
                  count = count + 1;
            end
            else if (count == 3'd2)begin
                  tmp_x_out = tmp_tail_out[4];
                  tmp_out = tmp_tail_out[5];
                  count = count + 1;
            end
         end
      end
   end

   assign bin_x_out = tmp_x_out;
   assign bin_z_out = tmp_out;

endmodule
