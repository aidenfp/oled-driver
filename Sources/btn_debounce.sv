module btn_debounce(input wire clk,
                    input wire rst,
                    input wire [3:0] btn_in,
                    output logic [3:0] btn_out);
    
    logic [19:0] count [3:0];
    logic [3:0] new_input;

    always_ff @(posedge clk) begin
        if(rst) begin
            for (int i = 0; i < 4; i++) 
                count[i] <= 0;
            new_input <= btn_in;
        end else begin
            for (int i = 0; i < 4; i++) begin
                if(btn_in[i] != new_input[i]) begin
                    new_input[i] <= btn_in[i];
                    count[i] <= 0;
                end else if (count[i] == 1000000) btn_out[i] <= new_input[i];
                else count[i] <= count[i] + 1;
            end
        end
    end

endmodule
             
