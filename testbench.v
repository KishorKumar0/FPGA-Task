module tb_uart_rx();

  // Testbench uses a 25 MHz clock
  // Want to interface to 115200 baud UART
  // 25000000 / 115200 = 217 Clocks Per Bit.
  parameter c_CLOCK_PERIOD_NS = 40;
  parameter c_CLKS_PER_BIT    = 217;
  parameter c_BIT_PERIOD      = 8600;
  
  reg r_Clock = 0;
  reg r_RX_Serial = 1;
  wire [7:0] w_RX_Byte;
  wire       w_RX_DV;
  wire [255:0] o_Decoded_Byte;
  wire [255:0] pwm_out; 
  
  // Define UART_WRITE_BYTE task
  task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer ii;
    begin
      // Send Start Bit
      r_RX_Serial <= 1'b0;
      #(c_BIT_PERIOD);
      #10;
      
      // Send Data Byte
      for (ii = 0; ii < 8; ii = ii + 1) begin
        r_RX_Serial <= i_Data[ii];
        #(c_BIT_PERIOD);
      end
      
      // Send Stop Bit
      r_RX_Serial <= 1'b1;
      #(c_BIT_PERIOD);
    end
  endtask
  
  // Instantiate UART receiver module
  uart_rx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_INST (
    .i_Clock(r_Clock),
    .i_RX_Serial(r_RX_Serial),
    .o_RX_DV(w_RX_DV),
    .o_RX_Byte(w_RX_Byte)
  );
  
  // Instantiate decoder module
  decoder_8_to_256 decoder_inst(
    .in(w_RX_Byte),
    .out(o_Decoded_Byte)
  );
  
  // Instantiate PWM generator module
  pwm_gen pwm_inst(
    .clk(r_Clock),
    .input_signal(o_Decoded_Byte),
    .out(pwm_out)
  );

  
  always #(c_CLOCK_PERIOD_NS/2) r_Clock = !r_Clock;

  
  initial begin
    
    @(posedge r_Clock);
    UART_WRITE_BYTE(8'd255);
    @(posedge r_Clock);
            
    
    if (w_RX_Byte == 8'd255)
      $display("Test Passed - Correct Byte Received");
    else
      $display("Test Failed - Incorrect Byte Received");
    #10

    $monitor("Time=%0t: Decoded_Byte=%d ", $time, o_Decoded_Byte);

    $finish();
  end
   
  
endmodule
