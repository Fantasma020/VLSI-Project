// fsm_tb_simple.v  (simplified like yours)
module fsm_tbm;
  reg clk;
  reg reset;
  reg cash_inserted;
  reg [1:0] selection;
  reg [11:0] cashval;
  reg cancel;

  wire dispense;
  wire change_valid;
  wire [11:0] change_amount;

  fsm dut(
    .clk(clk),
    .reset(reset),
    .cash_inserted(cash_inserted),
    .selection(selection),
    .cashval(cashval),
    .cancel(cancel),
    .dispense(dispense),
    .change_valid(change_valid),
    .change_amount(change_amount)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period
  end

  initial begin
    // init
    reset = 1;
    cash_inserted = 0;
    cashval = 0;
    selection = 2'b00;
    cancel = 0;

    #10 reset = 0;

    // -------------------------
    // TEST 1: Insert 600 cents, buy $5.99 (sel=01) -> leftover 1 cent -> CHANGE
    // -------------------------
    #10 cash_inserted = 1; cashval = 12'd600;
    #20 cash_inserted = 0; cashval = 12'd0;   // hold long enough to cross a posedge

    #10 selection = 2'b01; // $5.99
    #80;

    // -------------------------
    // TEST 2: Insert 1000 cents, buy $3.99 (sel=10) -> leftover can still buy -> multi-purchase path
    // -------------------------
    #10 reset = 1;
    #10 reset = 0;

    #10 cash_inserted = 1; cashval = 12'd1000;
    #20 cash_inserted = 0; cashval = 12'd0;

    #10 selection = 2'b10; // $3.99
    #80;

    $finish;
  end
endmodule
