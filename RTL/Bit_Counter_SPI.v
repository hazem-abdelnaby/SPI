module Bit_Counter_SPI #(
    parameter Data_Width = 8

)(
    input CLK,
    input RST,
    input sample_enable,
    input Count_RST,
    output Count_Done
);
reg [$clog2(Data_Width+1)-1:0] bit_counter;
assign Count_Done = (bit_counter == Data_Width) ? 1'b1 : 1'b0;

always @(posedge CLK or negedge RST)
begin
    if(!RST)
        bit_counter <= 'b0;
    else if(Count_RST)
        bit_counter <= 'b0;
    else if(sample_enable)
        bit_counter <= bit_counter + 1'b1;
end
    
endmodule
