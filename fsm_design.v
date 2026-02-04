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
always @(posedge clk or posedge reset) begin
  if (reset)
    state <= IDLE;
  else
    state <= nextstate;
end
//next state logic. this is what needs to be worked on the most
always @(*) begin
  nextstate = state;
  case (state)
    IDLE: begin
      if (cash_inserted || card_inserted)
        nextstate = CASH;  
    end

    default: begin
      nextstate = IDLE;
    end
  endcase
end

endmodule
