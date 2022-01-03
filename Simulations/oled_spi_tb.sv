`timescale 1ns / 1ps
module spi_tb;
        
    logic clk, rst, data_type, done;
    logic mosi, cs, sclk, d_c;
    logic [3:0] byte_count;
    logic [119:0] send_bytes;

    oled_spi uut(.clk(clk), .rst(rst), .data_type(data_type),
        .byte_count(byte_count), .send_bytes(send_bytes), .mosi(mosi),
        .cs(cs), .sclk(sclk), .d_c(d_c), .done(done));

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        data_type = 0;
        byte_count = 0;
        send_bytes = 0;

        #100;
        rst = 1;
        #10;
        rst = 0;
        #2000;
        data_type = 1'b1;
        byte_count = 4'h1;
        send_bytes = {8'h5E, 112'b0};
        #10;
        data_type = 1'b0;
        byte_count = 4'h0;
        send_bytes = 0;
        #2000;

        $finish;
    end
endmodule
