module fsm_tbm;
  reg clk;
  reg reset;
  reg cash_inserted;
  reg [1:0] selection;
  reg [3:0] cashval;
  wire dispense;

  fsm dut(
    .clk(clk), 
    .reset(reset), 
    .cash_inserted(cash_inserted), 
    .selection(selection), 
    .cashval(cashval), 
    .dispense(dispense));

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    reset =1;
    cash_inserted = 0;
    cashval = 0;
    selection = 2'b00;
    
    #10 reset = 0;
    #10 cash_inserted = 1;
        cashval = 5;
    #10 cash_inserted = 0;
    #10 selection = 2'b01;
    #20;

    #10 reset = 1;
    #10 reset = 0;
    #10 cash_inserted = 1;
        cashval = 1;
    #10 cashval = 4;
    #10 cash_inserted = 0;
    #20;
    $finish;
  end
endmodule
