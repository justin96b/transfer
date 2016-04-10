`timescale 1 ns / 1 ns

/*
 Input value should change every 12 clock cycles.
 Holds input values into buffer (2 write cycles)
 Read to output from buffer (after 2 write cycle delay)
 Holds output values for 8 clock cycles.
 */

module output_block(in, clk, reset, mode, validIn, out0, out1, valid);

   // Ports
   input [3:0]        in;  // in[0] = x; in[1] = z; in[2] = z'; in[3] = x';
   wire [3:0]         in;
   input              clk, reset, mode, validIn;  // When Load is High, new input has arrived at the input port.
   wire               clk, reset, mode, validIn;  // Mode = 0 : Normal Mode; Mode = 1 : Termination Mode.
   output             out0, out1, valid;
   wire               out0, out1, valid;

   // Internal Variables
   reg [4:0]          counter;          // Counts up to 12.
   reg                RdStart;          // Read Start Flag - Turned on when enough bits have been written to buffer.
   reg [3:0]          WrIndex;          // Write Index - buffer index to which input bit is written.
   reg [3:0]          RdIndex;          // Read Index  - buffer index from which bit is read.
   reg                ValidFlag;        // Valid Flag  - Turned on when outputs are valid.
   reg                TmpOut0, TmpOut1; // Stores output values and drives out0 and out1 wires.

   // SRAM Interface variables
   reg                RdWr, DevEn, DevEn1, WriteLine;
   wire               readLine1, readLine2;
   reg [3:0]          addr1, addr2;

   // Instantiate Buffers
   SRAM10T_16B Buffer(.clk(!clk), .addr1(addr1), .addr2(addr2), .readLine1(readLine1), .readLine2(readLine2), .writeLine(WriteLine), .RdWr(RdWr), .DevEn(DevEn));



   always @(posedge clk) begin
      counter = counter + 1;

      // Reset counter @ 24
      if(counter == 5'd24) begin
         counter = 3'd0;
         RdStart = 1'b1; // Start Reading now.
      end
   end



   always @(counter or reset) begin

      if(reset) begin
         counter       = 5'd31;
         RdStart       = 1'b0;
         DevEn         = 1'b1;
         addr1         = 3'd0;
         addr2         = 3'd0;
         RdWr          = 1'b0;
         WrIndex       = 4'd0;
         RdIndex       = 4'd0;
         ValidFlag     = 1'b0;
      end
      else begin

         // Write when counter @ 0,1,2,3  then 12,13,14,17
         if(validIn == 1) begin
            if(counter == 5'd0) begin
               RdWr      = 1'b1;
               DevEn     = 1'b0;
               WriteLine = in[0];
               addr1     = WrIndex;
               WrIndex   = WrIndex + 1;
            end

            if(counter == 5'd1) begin
               RdWr      = 1'b1;
               WriteLine = in[1];
               addr1     = WrIndex;
               if(mode)
                  WrIndex   = WrIndex + 5;
               else
                  WrIndex   = WrIndex + 1;
            end

            if(counter == 5'd2) begin
               RdWr      = 1'b1;
               WriteLine = in[2];
               addr1     = WrIndex;
               WrIndex   = WrIndex + 1;
            end

            if(counter == 5'd3 & mode) begin
               RdWr      = 1'b1;
               WriteLine = in[3];
               addr1     = WrIndex;
               WrIndex   = WrIndex - 5;
            end

            if(counter == 5'd12) begin
               RdWr      = 1'b1;
               WriteLine = in[0];
               addr1     = WrIndex;
               WrIndex   = WrIndex + 1;
            end

            if(counter == 5'd13) begin
               RdWr      = 1'b1;
               WriteLine = in[1];
               addr1     = WrIndex;
               if(mode)
                  WrIndex  = WrIndex + 5;
               else
                  WrIndex  = WrIndex + 1;
            end

            if(counter == 5'd14) begin
               RdWr      = 1'b1;
               WriteLine = in[2];
               addr1     = WrIndex;
               WrIndex   = WrIndex + 1;
            end

            if(counter == 5'd17 & mode) begin // 17 instead of 13 to avoid overlap with read operations
               RdWr      = 1'b1;
               WriteLine = in[3];
               addr1     = WrIndex;
               WrIndex   = WrIndex - 5;
            end
         end


         // Read Operations when counter == 0, 8, 16
         // Latch RdWr  when counter == 23, 7, 15
         if(RdStart) begin
            if(counter == 5'd23) begin
               RdWr      = 1'b0;
               addr1     = RdIndex;
               addr2     = RdIndex+1;
            end

            if(counter == 5'd0 & ValidFlag) begin
               TmpOut0   = readLine1;
               TmpOut1   = readLine2;
               RdIndex   = RdIndex + 2;
            end

            if(counter == 5'd7) begin
               RdWr      = 1'b0;
               addr1     = RdIndex;
               addr2     = RdIndex+1;
            end

            if(counter == 5'd8) begin
               ValidFlag = 1'b1;
               TmpOut0   = readLine1;
               TmpOut1   = readLine2;
               RdIndex   = RdIndex + 2;
            end

            if(counter == 5'd15) begin
               RdWr      = 1'b0;
               addr1     = RdIndex;
               addr2     = RdIndex+1;
            end

            if(counter == 5'd16) begin
               TmpOut0   = readLine1;
               TmpOut1   = readLine2;
               RdIndex   = RdIndex + 2;
            end
         end
      end
   end

   assign valid   = ValidFlag;
   assign out0    = TmpOut0;
   assign out1    = TmpOut1;

endmodule
