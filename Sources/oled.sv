`default_nettype none
module oled(input wire clk,
            input wire rst,
            input wire data_type_in,        // LOW for commands, HIGH for data
            input wire [3:0] byte_count_in,
            input wire [119:0] send_bytes_in,
            output logic spi_done,
            output logic cs,
            output logic mosi,
            output logic sclk,
            output logic d_c,
            output logic rst_out,
            output logic vcc_en,
            output logic pmod_en);

    enum {INITIAL, STARTUP, ACTIVE} state;

    logic internal_spi_done, data_type;
    logic [3:0] internal_byte_count, byte_count;
    logic [119:0] internal_send_bytes, send_bytes;
    oled_spi spi(.clk(clk), .rst(rst), .data_type(data_type),
       .byte_count(byte_count), .send_bytes(send_bytes), .cs(cs),
       .mosi(mosi), .sclk(sclk), .d_c(d_c), .done(internal_spi_done));

   oled_startup s_comm(.command(command_count), .comm_length(internal_byte_count),
       .comm_data(internal_send_bytes));

    always_comb begin
        case(state)
            INITIAL: begin
                data_type = 1'b0;
                byte_count = 1'b0;
                send_bytes = 120'b0;
                spi_done = 1'b0;
            end
            STARTUP: begin
                data_type = 1'b0;
                byte_count = internal_byte_count;
                send_bytes = internal_send_bytes;
                spi_done = 1'b0;
            end
            ACTIVE: begin
                data_type  = data_type_in;
                byte_count = byte_count_in;
                send_bytes = send_bytes_in;
                spi_done = internal_spi_done;
            end
            default: begin
                data_type = 1'b0;
                byte_count = 4'b0;
                send_bytes = 120'b0;
                spi_done = 1'b0;
            end
        endcase
    end
    
    logic vcc_en_wait;
    logic [4:0] command_count;
    logic [24:0] cycle_count;
    always_ff @(posedge clk) begin
        if(rst) begin
            state <= INITIAL;
            command_count <= 0;
            cycle_count <= 0;
            rst_out <= 1'b1;
            vcc_en <= 1'b0;
            pmod_en <= 1'b1;
            vcc_en_wait <= 1'b1;
        end else begin
            case(state)
                INITIAL: begin
                    if(rst_out && cycle_count > 2000000)
                        rst_out <= 1'b0; // delay 20ms after bringing pmod_en to high to reset
                    else if(~rst_out && cycle_count > 2000300) begin
                        rst_out <= 1'b1; // delay 3us after reset for reset to complete
                        state <= STARTUP;
                        cycle_count <= 0;
                    end else cycle_count <= cycle_count + 1;
                end
                STARTUP: begin
                    if(command_count < 25) begin
                        if(internal_spi_done || (vcc_en_wait && command_count == 23)) begin
                            if(command_count == 23) begin
                                vcc_en <= 1'b1;
                                if(cycle_count > 2500000) begin
                                    vcc_en_wait <= 1'b0;
                                    command_count <= command_count + 1;
                                    cycle_count <= 0;
                                end else cycle_count <= cycle_count + 1;
                            end else 
                                command_count <= command_count + 1;
                        end
                    end else if(cycle_count > 10000000) state <= ACTIVE; // delay 100ms until drawing
                    else cycle_count <= cycle_count + 1;
                end
            endcase
        end
    end

endmodule
