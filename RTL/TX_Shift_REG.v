module TX_Shift_REG #(
    parameter Data_Width = 8
) (
    input CLK,
    input RST,
    input TX_EN,
    input shift_enable,
    input Count_Done,
    input [Data_Width-1:0] TX_Data,
    output reg  MOSI
);

reg [Data_Width-1:0] TX_Data_REG;

always @(posedge CLK or negedge RST)
begin
    if(!RST)
    begin
        MOSI <= 1'b0;
        TX_Data_REG <= 'b0;
    end
    else
    begin
    if(TX_EN)
    begin
        TX_Data_REG<=TX_Data;
        MOSI <= TX_Data[Data_Width-1];
    end
    else if(shift_enable&!Count_Done)
    begin
        TX_Data_REG <= TX_Data_REG << 1'b1;
        MOSI <= TX_Data_REG[Data_Width-2];
    end
    end
end

endmodule
