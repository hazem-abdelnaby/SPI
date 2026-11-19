module SPI_Clock_Generator #(
    parameter COUNTER_WIDTH = 8
)(
    input CLK,
    input RST,
    input CLK_EN,
    input [COUNTER_WIDTH-1:0] DIV_VALUE,
    output reg SCLK,
    output wire sample_enable,
    output wire shift_enable
);

    reg half_tick;
    reg [COUNTER_WIDTH-1:0] counter;

    always @(*) begin
        if(counter == DIV_VALUE-1'b1)
            half_tick = 1'b1;
        else
            half_tick = 1'b0;
    end
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            counter <= 'b0;
            SCLK <= 1'b1;
        end 
        else 
        if(CLK_EN) 
        begin
            if(counter == DIV_VALUE-1'b1) 
            begin
                counter <= 'b0;
                SCLK <= ~SCLK;
            end
            else 
            begin
                counter <= counter + 1'b1;
            end
        end
        else
        begin
            counter <= 'b0;
            SCLK <= 1'b1;
        end
    end

    assign sample_enable = CLK_EN && half_tick && SCLK;
    assign shift_enable  = CLK_EN && half_tick && !SCLK;

endmodule
