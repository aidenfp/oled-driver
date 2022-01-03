`default_nettype none

module top_level(   input wire clk_100mhz,
                    input wire [3:0] btn,
                    input wire [3:0] sw,
                    output logic led0_r,
                    output logic led0_g,
                    output logic led0_b,
                    output logic [3:0] led,
                    output logic [7:0] ja);

    assign led = sw;

    logic rst;
    assign rst = btn[0];

    logic [3:0] btn_out;
    btn_debounce db(.clk(clk_100mhz), .rst(rst), .btn_in({btn[3:1], 1'b0}), .btn_out(btn_out));

    always_comb begin
        led0_r = rst | btn_out[1];
        led0_g = rst | btn_out[2];
        led0_b = rst | btn_out[3];
    end

    logic [3:0] mem_count;
    logic [119:0] mem_out;
    image_memory mem(.clk(clk_100mhz), .rst(rst), .next(btn1_rise || spi_done),
        .byte_count(mem_count), .d_out(mem_out));

    logic btn1_rise, btn1_prev;
    assign btn1_rise = btn_out[1] && ~btn1_prev; 
    logic spi_done;
    logic [7:0] send_byte;
    oled oled_controller(.clk(clk_100mhz), .rst(rst), .data_type_in(1'b1), .byte_count_in(mem_count),
        .send_bytes_in(mem_out), .spi_done(spi_done), .mosi(ja[1]), .cs(ja[0]), .sclk(ja[3]),
        .d_c(ja[4]), .rst_out(ja[5]), .vcc_en(ja[6]), .pmod_en(ja[7])); 
    
    always_ff @(posedge clk_100mhz) begin
        if(rst) begin
            send_byte <= 8'h0;
            btn1_prev <= 1'b0;
        end else begin
            btn1_prev <= btn_out[1];
            if (btn_out[2]) send_byte[3:0] <= sw;
            else if (btn_out[3]) send_byte[7:4] <= sw;
        end
    end
endmodule 

`default_nettype wire
