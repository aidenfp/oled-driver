module oled_spi(input wire clk,
                input wire rst,
                input wire data_type,           // LOW for command, HIGH for data
                input wire [3:0] byte_count,    // send up to 15 bytes at once
                input wire [119:0] send_bytes,
                output logic cs,
                output logic mosi,
                output logic sclk,
                output logic d_c,
                output logic done);

    logic [1:0] state, next_state;
    localparam  IDLE = 2'b00,
                STARTING = 2'b01,
                SENDING = 2'b11;
    always_comb begin
        case(state)
            IDLE: next_state = byte_count != 0 ? STARTING : IDLE;
            STARTING: next_state = ~sclk && prev_sclk ? SENDING : STARTING; // start on falling edge to meet setup time constraint
            SENDING: next_state = bytes_left == 0 && cycle_count == 15 ? IDLE : SENDING; // ensures hold time constraint for last bit is met
            default: next_state = IDLE;
        endcase
    end

    logic clk_5mhz;
    assign clk_5mhz = cycle_count < 10 ? 1'b0 : 1'b1;
    //clk_wiz_5mhz sclk_wiz(.clk_in1(clk), .clk_out1(clk_5mhz));

    logic send_type;
    //logic prev_sclk [1:0];
    logic prev_sclk;
    logic [3:0] bytes_left, bit_count;
    logic [4:0] cycle_count;
    logic [119:0] data;
    always_ff @(posedge clk) begin
        if(rst) begin
            mosi <= 1'b0;
            done <= 1'b0;
            state <= IDLE;
            send_type <= 1'b0;
            bit_count <= 3'h0;
            cycle_count <= 5'h0;
            bytes_left <= 4'h0;
            data <= 120'h0;
        end else begin
            cycle_count <= (cycle_count + 1) % 20; // every 20 100mhz clk cycles = 1 5mhz clk cycle
            state <= next_state;
            prev_sclk <= sclk;
            //prev_sclk[0] <= sclk;
            //prev_sclk[1] <= prev_sclk[0];
            case(state)
                IDLE: begin
                    done <= 1'b0;
                    if(next_state == STARTING) begin
                        send_type <= data_type;
                        bit_count <= 0;
                        cycle_count <= 0;
                        bytes_left <= byte_count;
                        data <= send_bytes;
                    end
                end
                STARTING: begin
                end
                SENDING: begin
                    //cycle_count <= (cycle_count + 1) % 20; // every 20 100mhz clk cycles = 1 5mhz clk cycle
                    if(bytes_left > 0) begin
                        if(cycle_count == 4) begin
                            mosi <= data[119];
                            data <= data << 1;
                            if(bit_count == 7) begin
                                bit_count <= 0;
                                bytes_left <= bytes_left - 1;
                            end else bit_count <= bit_count + 1;
                        end
                    end
                    if(next_state == IDLE) 
                        done <= 1'b1;
                end
            endcase
        end
    end

    always_comb begin
        sclk = clk_5mhz;
        cs = state != SENDING;
        d_c = send_type;
    end

endmodule
