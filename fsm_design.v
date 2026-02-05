module fsm(
  input  logic       clk,
  input  logic       reset,
  input  logic       cash_inserted,
  input  logic       card_inserted,
  input  logic [1:0] selection,
  input  logic [3:0] cashval,
  output logic       dispense
);

parameter [3:0]
  IDLE      = 4'b0000,
  CASH      = 4'b0001,
  VERIFY    = 4'b0010,
  BALANCE   = 4'b0011,
  SELECTION = 4'b0100,
  SEL1      = 4'b0101,
  SEL2      = 4'b0110,
  SEL3      = 4'b0111,
  DISPENSE  = 4'b1000;

reg [3:0] state, nextstate;
//state register: basically remembers what state we're in
  reg [3:0] balance; // most the user can insert is $15
always @(posedge clk or posedge reset) begin
  if (reset)
    state <= IDLE;
  else
    state <= nextstate;
end
//cash insertion counting
  always @(posedge clk or posedge reset) begin
    if(reset)
      balance <= 4'b0000;
    else if(state == CASH && cash_inserted)
      balance <= cashval + balance;
    else if(state == IDLE)
      balance <= 4'b0000;
  end
  
//next state logic. this is what needs to be worked on the most
always @(*) begin
  nextstate = state;
  case (state)
    IDLE: begin
      if (cash_inserted || card_inserted)
        nextstate = CASH;
      else
        nextstate = IDLE;
    end
    CASH: begin
      if(!cash_inserted) //we stopped putting in money
        nextstate = VERIFY;
      else
        nextstate = CASH;
    end
    VERIFY: begin
      if(balance < 5 || balance > 15) // needs $5 to operate and must be below $15 to operate
        nextstate = DISPENSE;
      else
        nextstate = SELECTION;
    end
    SELECTION: begin
      if(selection = 2'b00) // first selection
        nextstate = SEL1;
      else if(selection = 2'b01) // user chose second selection
        nextstate = SEL2;
      else if (selection = 2'b10) // user chooses third selection
        nextstate = SEL3;
      else                // otherwise the user must choose a proper selection
        nextstate = SELECTION;
    end
    SEL1: begin
      nextstate = DISPENSE;
    end
    SEL2: begin
      nextstate = DISPENSE;
    end
    SEL3: begin
      nextstate = DISPENSE;
    end
    DISPENSE: begin
      nextstate = IDLE;
    end

    default: begin
      nextstate = IDLE;
    end
  endcase
end

endmodule
