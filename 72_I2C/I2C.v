// ================================================================
// Simple I2C Master (Fundamental RTL Wrapper)
// ------------------------------------------------
// Features:
//  - START -> ADDRESS (7-bit) + WRITE bit -> DATA byte -> STOP
//  - Parameterizable clock divider for SCL
//  - No tri-state IOBUF (SDA is open-drain modeled via sda_oe)
//  - For tutorials / testbenches — not a full I2C IP
// ================================================================
module i2c_master_simple #(
  parameter integer CLK_FREQ_HZ = 50_000_000,   // system clock
  parameter integer I2C_FREQ_HZ = 100_000       // target SCL (standard mode)
)(
  input  wire clk,
  input  wire rst_n,
  input  wire start,              // start transaction
  input  wire [6:0] addr,         // 7-bit slave address
  input  wire [7:0] data_wr,      // data byte to send
  output reg        busy,         // high while running
  output reg        done,         // 1-cycle pulse after stop
  // I2C signals
  output reg        scl,          // SCL line
  output reg        sda_oe        // drive SDA low when 1 (open-drain)
);

  // Clock divider for SCL generation
  localparam integer DIVIDER = CLK_FREQ_HZ / (I2C_FREQ_HZ * 4); // 4 phases per bit
  localparam integer CW = $clog2(DIVIDER+1);

  reg [CW-1:0] div_cnt;
  reg [1:0]    scl_phase;   // 00: low, 01: rising, 10: high, 11: falling

  // SCL generator
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      div_cnt <= 0; scl_phase <= 0; scl <= 1'b1;
    end else begin
      if (div_cnt == DIVIDER) begin
        div_cnt <= 0;
        scl_phase <= scl_phase + 1'b1;
        scl <= (scl_phase[1] == 1'b0); // half-cycle toggle
      end else div_cnt <= div_cnt + 1'b1;
    end
  end

  // FSM for start/address/data/stop
  typedef enum logic [3:0] {
    IDLE=0, START_COND, SEND_ADDR, SEND_DATA, STOP_COND, DONE
  } state_t;
  state_t st;
  reg [7:0] shifter;
  reg [3:0] bit_cnt;

  // transaction FSM
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= IDLE; busy <= 1'b0; done <= 1'b0;
      sda_oe <= 1'b0; bit_cnt <= 0; shifter <= 8'd0;
    end else begin
      done <= 1'b0;
      case (st)
        IDLE: begin
          busy <= 1'b0; sda_oe <= 1'b0;
          if (start) begin
            st <= START_COND;
            busy <= 1'b1;
          end
        end

        START_COND: begin
          // SDA goes low while SCL high -> start condition
          sda_oe <= 1'b1;
          if (scl_phase == 2'b10) begin
            shifter <= {addr, 1'b0}; // 7-bit address + write bit
            bit_cnt <= 4'd8;
            st <= SEND_ADDR;
          end
        end

        SEND_ADDR: begin
          // shift out 8 bits MSB-first
          if (scl_phase == 2'b00) begin
            sda_oe <= ~shifter[7]; // drive low if bit=0
          end
          if (scl_phase == 2'b10) begin
            shifter <= {shifter[6:0],1'b0};
            bit_cnt <= bit_cnt - 1'b1;
            if (bit_cnt == 1) begin
              shifter <= data_wr;
              bit_cnt <= 4'd8;
              st <= SEND_DATA;
            end
          end
        end

        SEND_DATA: begin
          if (scl_phase == 2'b00) sda_oe <= ~shifter[7];
          if (scl_phase == 2'b10) begin
            shifter <= {shifter[6:0],1'b0};
            bit_cnt <= bit_cnt - 1'b1;
            if (bit_cnt == 1) st <= STOP_COND;
          end
        end

        STOP_COND: begin
          // SDA goes high while SCL high -> stop condition
          if (scl_phase == 2'b00) sda_oe <= 1'b1;
          else if (scl_phase == 2'b10) begin
            sda_oe <= 1'b0;
            st <= DONE;
          end
        end

        DONE: begin
          busy <= 1'b0; done <= 1'b1;
          st <= IDLE;
        end

      endcase
    end
  end
endmodule
