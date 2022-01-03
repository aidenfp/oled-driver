module image_memory(input wire clk,
                    input wire rst,
                    input wire next, 
                    output logic [3:0] byte_count,
                    output logic [119:0] d_out); // can send 15 bytes at once

    // 96 x 64 display
    // color depth of 16 bits
    // r, g, b color maps of 8 bit width and 256 bit depth
    // total memory = 96 * 64 * 8 + 3 * (8 * 256) = 55296 bits

    logic [12:0] addr;      // log2(6144) = 13 bit address
    logic [7:0] cm_addr;    // each color map has 256 entries = 8 bit address
    logic [7:0] rom_out, red_out, green_out, blue_out;
    image_rom rom(.addra(addr), .clka(clk), .douta(rom_out));
    image_red_cm rcm(.addra(cm_addr), .clka(clk), .douta(red_out));
    image_green_cm gcm(.addra(cm_addr), .clka(clk), .douta(green_out));
    image_blue_cm bcm(.addra(cm_addr), .clka(clk), .douta(blue_out));

    always @(posedge clk) begin
        if(rst) begin
            byte_count <= 0;
            d_out <= 0;
            addr <= 0;
            cm_addr <= 0;
        end else begin
            if(next) begin
                d_out <= {red_out[7:3], green_out[7:2], blue_out[7:3], 104'b0};
                byte_count <= 2;
                cm_addr <= rom_out;
                addr <= (addr + 1) % 6144;
            end else byte_count <= 0;
        end
    end

endmodule
