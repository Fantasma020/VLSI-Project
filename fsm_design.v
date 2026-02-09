module fsm(clk,reset,cash_inserted,selection,cashval,dispense);
	//port declaration
input  clk;
input  reset;
input  cash_inserted;
input  [1:0] selection;
input  [3:0] cashval;

output dispense;
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

always @(posedge clk) begin
  if (reset)begin
    state <= IDLE;
	balance = 4'b0000;
end
  else
    state <= nextstate;
end
//balance register
always @(posedge clk)begin
	if(reset)
	balance<=4'd0;
	else if (state ==IDLE)
	balance <=4'd0;
	else if (state ==CASH && cash_inserted)begin
	if (balance+cashval >=4'd5) balance <= 4'd5;
	else 
	balance <= balance + cashval;
	end
end
	  
//next state logic. this is what needs to be worked on the most
always @(*) begin
  nextstate = state;
  case (state)
    IDLE: begin
	if (cash_inserted )//once cash is inserted then we go into the next state
    nextstate = CASH;
	end
    CASH: begin
		if(!cash_inserted) //we stopped putting in money //How do we make sure this doesnt eat any input, is cash_inserted boolean? cash_inserted is boolean 
        nextstate = VERIFY;
    end
    VERIFY: begin		//What happens when the user inputs more money during the verify state and balance hasnt been updated yet because it hasnt went to CASH state? ex: put $5, how does line 35 trigger again, This should be "if it means the minimum, then selection is available" otherwise  return change and 
		if(balance < 4'd5 )		//When balance is < 5, Insufficient funds, needs to go back to CASH until minimum is met
        nextstate = CASH;  
		else 	       //Balance meets minimum and doesnt breach limit, proceed with SELECTION
	nextstate = SELECTION; 
    end
	SELECTION: begin
		if(selection == 2'b01) // first selection
        nextstate = SEL1;
		else if(selection == 2'b10) // user chose second selection
        nextstate = SEL2;
		else if (selection == 2'b11) // user chooses third selection
        nextstate = SEL3;
      else                // otherwise the user must choose a proper selection
        nextstate = SELECTION;
    end

	  //after each selection we got to dispense no matter what
    SEL1: begin
      nextstate = DISPENSE;
    end
    SEL2: begin
      nextstate = DISPENSE;
    end
    SEL3: begin
      nextstate = DISPENSE;
    end
	  //We "dispense" the item the user selected then go back to idle
    DISPENSE: begin
      nextstate = IDLE;
    end

    default: begin
      nextstate = IDLE;
    end
  endcase
end

assign dispense = (state ==DISPENSE);

endmodule
