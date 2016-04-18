// Input block - also does the interleaving.
//CURRENTLY THE VALID BIT SWITCHES ON FOR A SMALL TIME IN THE BEGINNING BEFORE BEING VALID
`timescale 1 ns / 1 ns
module input_block(clk, bin_in, bin_out, bin_int_out, reset, valid, mode);
   input clk, bin_in, reset;
   output bin_out, bin_int_out,valid,mode;

   wire   clk, bin_in, valid, bin_out, bin_int_out;   // 1-bit wide
   //reg [11:0] rom [0:4095];  // 12-bit wide


   // Internal Variables
   reg        current_block;
   reg        mode;//renamed Term_En to mode
   reg        validReg;
   reg [11:0] counter;     // Input counter
   reg [2:0]  Term_Counter; // Termination Counter

   // Sram Interface variables
   reg        RdWr0, RdWr1, DevEn0, DevEn1, Dev0_State, Dev1_State;
   reg [11:0] addr1, addr2;
   wire [11:0] addr1_tmp, addr2_tmp; 

   // Instantiate Srams
   SRAM10T Buffer_0(.clk(!clk), .addr1(addr1_tmp), .addr2(addr2), .readLine1(bin_out),.readLine2(bin_int_out), .writeLine(bin_in), .RdWr(RdWr0), .DevEn(DevEn0));
   SRAM10T Buffer_1(.clk(!clk), .addr1(addr1_tmp), .addr2(addr2), .readLine1(bin_out),.readLine2(bin_int_out), .writeLine(bin_in), .RdWr(RdWr1), .DevEn(DevEn1));
   AddrEncoder ROM (.clk(!clk), .in(counter+1),  .out(addr2_tmp));  

   // Populate ROM
   //initial begin
   //   $readmemh("rom.txt",rom);
   //end


   always @(posedge clk) begin
      
      if(reset) begin 
         counter = 12'd4095; 
         mode    = 1'b0; 
         Term_Counter  = 3'd0;
         current_block = 1'b1;
         RdWr0         = ~current_block;     // Block 0 (Write Mode - High, Read Mode - Low) ; Reset - Read Mode
         RdWr1         =  current_block;     // Block 1 (Write Mode - High, Read Mode - Low) ; Reset - Write Mode
         validReg      = 1'b0;
         DevEn1        = 1'b1;               // Disable Block 1
         DevEn0        = 1'b1;               // Disable Block 0
      end

      // Increment Counter if not in Termination Bit Stage
      if(mode == 1'b0 & !reset) begin
         counter = counter + 1;               // @Reset Counter = 0.
         if(current_block == 1'b0) begin 
            DevEn0 = 1'b0; 
         end else begin 
            DevEn1 = 1'b0; 
         end
      end

      // If counter has overflowed, Enable Termination Bit Stage
      if(counter == 12'd4095 & !reset) begin
         mode       = 1'b1;
      end

      // Termination Bit Stage
      // Need to freeze the counter for 2 clock period.  Disable Both Buffers.
      if (mode) begin

         Term_Counter = Term_Counter + 1;
         if(Term_Counter == 3'd2) begin 
            validReg = 1'b0; 
            Dev0_State = DevEn0;
            Dev1_State = DevEn1;
            DevEn0 = 1'b1;
            DevEn1 = 1'b1;
         end


         if(Term_Counter == 3'd6) begin
            DevEn0 = Dev0_State;
            DevEn1 = Dev1_State;
            counter = 12'd0;
            mode = 1'b0;
            current_block = ~current_block;  // Flips between 0 and 1
            RdWr0         = ~current_block;  // Low for Read, High for Write: cb = 0 -> block 0 is writing. cb = 1 -> block0 is reading.
            RdWr1         =  current_block;  // Low for Read, High for Write: cb = 0 -> block 1 is reading. cb = 1 -> block1 is writing.
            Term_Counter = 3'd0;
            validReg = 1'b1; 
         end
      end

      //addr1_tmp = counter;         
   end


   always @(counter or reset or DevEn0 or DevEn1) begin

      if(reset == 1'b1) begin
         //counter       = 12'd4095;
         //Term_Counter  = 2'd0;
         //current_block = 1'b1;
         //validReg      = 1'b0;
         //mode          = 1'b0;
         //DevEn1        = 1'b1;               // Disable Block 1
         //DevEn0        = 1'b1;               // Disable Block 0
         addr1         = 12'd0;
         addr2         = 12'd0;
         //RdWr0         = ~current_block;     // Block 0 (Write Mode - High, Read Mode - Low) ; Reset - Read Mode
         //RdWr1         =  current_block;     // Block 1 (Write Mode - High, Read Mode - Low) ; Reset - Write Mode
      end
      else begin
         if(current_block == 1'b0) begin // Write to Block 0 // Read for Block 1.
            addr1[11:6]    = counter[11:6]; // Store Input into Block 0
            addr1[5:0]    = counter[5:0]; // Store Input into Block 0
            if(mode == 1'b0) begin
               //DevEn0   = 1'b0;
            end
            if(DevEn1 ==  1'b0) begin // Read from block 1 if it is ready.
               //validReg = 1'b1; 
               //addr2 = rom[counter];
               addr2 = addr2_tmp; 
            end
         end
         else if(current_block == 1'b1) begin // Write to Block 1 // Read from Block 0
            addr1[11:6]    = counter[11:6]; // Store Input into Block 0
            addr1[5:0]    = counter[5:0]; // Store Input into Block 0
            if(mode == 1'b0) begin
               //DevEn1   = 1'b0;
            end
            if(DevEn0  == 1'b0) begin         // Read from block 0 if it is ready.
               //validReg = 1'b1; 
               //addr2 = rom[counter];
               addr2 = addr2_tmp; 
            end
         end
      end
   end


   assign valid = validReg;
   assign addr1_tmp = counter; 

endmodule
