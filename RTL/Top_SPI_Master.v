
module Top_SPI_Master #(
    parameter Data_Width = 8,
              number_of_slaves = 3,
              COUNTER_WIDTH = 8
)(
    input CLK,
    input RST,
    input TX_Valid,
    input [COUNTER_WIDTH-1:0] DIV_VALUE,
    input [Data_Width-1:0] TX_Data,
    input [$clog2(number_of_slaves)-1:0] slave_select,
    input MISO,
    output wire [Data_Width-1:0] RX_Data,
    output wire Invalid_Slave_Select,
    output wire busy,
    output wire RX_Valid,
    output wire [2:0] SS,
    output wire MOSI,
    output wire SCLK
);

wire Count_Done;
wire Count_RST;
wire TX_EN;
wire RX_EN;
wire CLK_EN;
wire sample_enable;
wire shift_enable;



SPI_Master_FSM #(
    .Data_Width(Data_Width),
    .number_of_slaves(number_of_slaves)
) FSM (
    .CLK(CLK),
    .RST(RST),

    .Count_Done(Count_Done),
    .TX_Valid(TX_Valid),
    .slave_select(slave_select),
    .shift_enable(shift_enable),

    .Invalid_Slave_Select(Invalid_Slave_Select),
    .TX_EN(TX_EN),
    .Count_RST(Count_RST),

    .SS_0(SS[0]),
    .SS_1(SS[1]),
    .SS_2(SS[2]),

    .RX_EN(RX_EN),
    .busy(busy),
    .RX_Valid(RX_Valid),
    .CLK_EN(CLK_EN)
);

Bit_Counter_SPI #(
    .Data_Width(Data_Width)
) Bit_Counter (
    .CLK(CLK),
    .RST(RST),
    .sample_enable(sample_enable),
    .Count_RST(Count_RST),
    .Count_Done(Count_Done)
);

TX_Shift_REG #(
    .Data_Width(Data_Width)
) TX_Shift (
    .CLK(CLK),
    .RST(RST),

    .TX_EN(TX_EN),
    .shift_enable(shift_enable),
    .Count_Done(Count_Done),
    .TX_Data(TX_Data),

    .MOSI(MOSI)
);


RX_Shift_REG #(
    .Data_Width(Data_Width)
) RX_Shift (
    .CLK(CLK),
    .RST(RST),

    .RX_EN(RX_EN),
    .sample_enable(sample_enable),
    .MISO(MISO),

    .RX_Data(RX_Data)
);

SPI_Clock_Generator #(
    .COUNTER_WIDTH(COUNTER_WIDTH)
) Clock_Generator (
    .CLK(CLK),
    .RST(RST),
    .CLK_EN(CLK_EN),
    .DIV_VALUE(DIV_VALUE),
    .SCLK(SCLK),
    .sample_enable(sample_enable),
    .shift_enable(shift_enable)
);

endmodule
