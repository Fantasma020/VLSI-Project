// fsm_scaled_fixed.v
module fsm(
    input         clk,
    input         reset,
    input         cash_inserted,
    input  [1:0]  selection,
    input  [11:0] cashval,          // CHANGED: cents (wider than 4 bits)
    input         cancel,           // ADDED: cancel/refund
    output        dispense,
    output reg    change_valid,     // ADDED: change/refund pulse
    output reg [11:0] change_amount // ADDED: change/refund amount (cents)
);

parameter [3:0]
  IDLE      = 4'b0000,
  CASH      = 4'b0001,
  VERIFY    = 4'b0010,
  BALANCE   = 4'b0011,  // used as "vend item 0" state (selection 00)
  SELECTION = 4'b0100,
  SEL1      = 4'b0101,
  SEL2      = 4'b0110,
  SEL3      = 4'b0111,
  DISPENSE  = 4'b1000,
  CHANGE    = 4'b1001;  // ADDED: change/refund state

reg [3:0]  state, nextstate;

// CHANGED: widened for cents
reg [11:0] balance, balance_n;

// ADDED: timeout counter
reg [15:0] timeout_cnt;

// Prices (cents)
localparam [11:0] PRICE0    = 12'd199; // $1.99
localparam [11:0] PRICE1    = 12'd599; // $5.99
localparam [11:0] PRICE2    = 12'd399; // $3.99
localparam [11:0] PRICE3    = 12'd499; // $4.99
localparam [11:0] MIN_PRICE = 12'd199;

localparam [15:0] TIMEOUT_MAX = 16'd200;
wire timeout_hit = (timeout_cnt >= TIMEOUT_MAX);

// ----------------------
// State register
// ----------------------
always @(posedge clk) begin
  if (reset)
    state <= IDLE;
  else
    state <= nextstate;
end

// ----------------------
// Balance register (CHANGED: uses balance_n)
// ----------------------
always @(posedge clk) begin
  if (reset)
    balance <= 12'd0;
  else
    balance <= balance_n;
end

// ----------------------
// Timeout counter (ADDED)
// ----------------------
always @(posedge clk) begin
  if (reset)
    timeout_cnt <= 16'd0;
  else if (state == IDLE)
    timeout_cnt <= 16'd0;
  else if (cash_inserted || cancel)
    timeout_cnt <= 16'd0;               // ADDED: reset on activity
  else
    timeout_cnt <= timeout_cnt + 16'd1; // ADDED: increments while active
end

// ----------------------
// Next-state + next-balance logic
// ----------------------
always @(*) begin
  // defaults (prevents latches)
  nextstate     = state;
  balance_n     = balance;
  change_valid  = 1'b0;
  change_amount = 12'd0;

  case (state)

    IDLE: begin
      balance_n = 12'd0; // keep original behavior: clear in IDLE
      if (cash_inserted)
        nextstate = CASH;
      else
        nextstate = IDLE;
    end

    CASH: begin
      // CHANGED: add literal cents while cash_inserted is high
      if (cash_inserted) begin
        balance_n = balance + cashval;
        nextstate = CASH;
      end else begin
        nextstate = VERIFY;
      end
    end

    VERIFY: begin
      if (balance < MIN_PRICE)
        nextstate = IDLE;
      else
        nextstate = SELECTION;
    end

    SELECTION: begin
      // Keep your original SEL1–SEL3 names, and use BALANCE as the 4th item state
      if (selection == 2'b00)
        nextstate = BALANCE;
      else if (selection == 2'b01)
        nextstate = SEL1;
      else if (selection == 2'b10)
        nextstate = SEL2;
      else if (selection == 2'b11)
        nextstate = SEL3;
      else
        nextstate = SELECTION;
    end

    // COMPROMISE: these states now do price check + balance update (not pass-through)
    BALANCE: begin // item0
      if (balance >= PRICE0) begin
        balance_n = balance - PRICE0;
        nextstate = DISPENSE;
      end else begin
        nextstate = CASH;
      end
    end

    SEL1: begin // item1
      if (balance >= PRICE1) begin
        balance_n = balance - PRICE1;
        nextstate = DISPENSE;
      end else begin
        nextstate = CASH;
      end
    end

    SEL2: begin // item2
      if (balance >= PRICE2) begin
        balance_n = balance - PRICE2;
        nextstate = DISPENSE;
      end else begin
        nextstate = CASH;
      end
    end

    SEL3: begin // item3
      if (balance >= PRICE3) begin
        balance_n = balance - PRICE3;
        nextstate = DISPENSE;
      end else begin
        nextstate = CASH;
      end
    end

    DISPENSE: begin
      // After vend: if you can still afford the cheapest item, allow multi-purchase
      // If leftover > 0 but < cheapest item, return change
      if (balance >= MIN_PRICE)
        nextstate = SELECTION;
      else if (balance > 12'd0)
        nextstate = CHANGE;
      else
        nextstate = IDLE;
    end

    CHANGE: begin
      // Return leftover balance
      change_valid  = 1'b1;
      change_amount = balance;
      balance_n     = 12'd0;
      nextstate     = IDLE;
    end

    default: begin
      nextstate = IDLE;
    end
  endcase

  // ADDED/CHANGED: TRUE PRIORITY override so cancel/timeout always wins
  // (Prevents the earlier issue where case-assignments could overwrite it.)
  if ((cancel || timeout_hit) && (state != IDLE) && (balance != 12'd0)) begin
    nextstate = CHANGE;
  end
end

assign dispense = (state == DISPENSE);

endmodule
