module RX_Shift_REG#(
    parameter Data_Width = 8
    )
 (
    input CLK,
    input RST,
    input sample_enable,
    input RX_EN,
    input MISO,
    output [Data_Width-1:0] RX_Data
);
reg [Data_Width-1:0] RX_Data_REG;
assign RX_Data = RX_Data_REG;

always @(posedge CLK or negedge RST)
begin
    if(!RST)
    begin
        RX_Data_REG <= 'b0;
    end
    else
    begin
        if(RX_EN & sample_enable)
        begin
            RX_Data_REG <= {RX_Data_REG[Data_Width-2:0], MISO};
        end
    end
end
    


endmodule
