module oled_startup(input wire [4:0] command,
                    output logic [3:0] comm_length,
                    output logic [119:0] comm_data);

    always_comb begin
        case(command) 
            0: begin // unlock command
                comm_length = 2;
                comm_data = {8'hFD, 8'h12, 104'b0};
            end
            1: begin // display off
                comm_length = 1;
                comm_data = {8'hAE, 112'b0};
            end
            2: begin // remap and display format
                comm_length = 2;
                comm_data = {8'hA0, 2'b01, 3'b100, 3'b000, 104'b0};
            end
            3: begin // set start line
                comm_length = 2;
                comm_data = {8'hA1, 8'h00, 104'b0};
            end
            4: begin // set display offset
                comm_length = 2;
                comm_data = {8'hA2, 8'h00, 104'b0};
            end
            5: begin // set display mode
                comm_length = 1;
                comm_data = {8'hA4, 112'b0};
            end
            6: begin // set multiplex ratio
                comm_length = 2;
                comm_data = {8'hA8, 8'h3F, 104'b0};
            end
            7: begin // set master config to use required external vcc supply
                comm_length = 2;
                comm_data = {8'hAD, 8'h8E, 104'b0};
            end
            8: begin // disable power saving mode
                comm_length = 2;
                comm_data = {8'hB0, 8'h0, 104'b0};
            end
            9: begin // set phase length of oled pixel charge/discharge
                comm_length = 2;
                comm_data = {8'hB1, 8'h74, 104'b0};
            end
            10: begin // set d_clk divide ratio and oscillator freq
                comm_length = 2;
                comm_data = {8'hB3, 8'hD0, 104'b0};
            end
            11: begin // color a precharge
                comm_length = 2;
                comm_data = {8'h8A, 8'h80, 104'b0};
            end
            12: begin // color b precharge
                comm_length = 2;
                comm_data = {8'h8B, 8'h80, 104'b0};
            end
            13: begin // color c precharge
                comm_length = 2;
                comm_data = {8'h8C, 8'h80, 104'b0};
            end
            14: begin // set precharge voltage command
                comm_length = 2;
                comm_data = {8'hBB, 8'h3E, 104'b0};
            end
            15: begin // set comh deselect level
                comm_length = 2;
                comm_data = {8'hBE, 8'h3E, 104'b0};
            end
            16: begin // set master current attenuation factor
                comm_length = 2;
                comm_data = {8'h87, 8'h0F, 104'b0};
            end
            17: begin // set color a contrast
                comm_length = 2;
                comm_data = {8'h81, 8'hFF, 104'b0};
            end
            18: begin // set color b contrast
                comm_length = 2;
                comm_data = {8'h82, 8'hFF, 104'b0};
            end
            19: begin // set color c contrast 
                comm_length = 2;
                comm_data = {8'h83, 8'hFF, 104'b0};
            end
            20: begin // disable scrolling 
                comm_length = 1;
                comm_data = {8'h2E, 112'b0};
            end
            21: begin // set column address
                comm_length = 3;
                comm_data = {8'h15, 8'h00, 8'h5F, 96'b0};
            end
            22: begin // set row address
                comm_length = 3;
                comm_data = {8'h75, 8'h00, 8'h3F, 96'b0};
            end
            23: begin // clear screen
                comm_length = 5;
                comm_data = {8'h25, 8'h0, 8'h0, 8'h5F, 8'h3F, 80'b0};
            end
            24: begin // display on
                comm_length = 1;
                comm_data = {8'hAF, 112'b0};
            end
            default: begin
                comm_length = 0;
                comm_data = 0;
            end
        endcase
    end

endmodule
