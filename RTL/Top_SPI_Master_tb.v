
`timescale 1ns/1ps

module Top_SPI_Master_tb ;

parameter Data_Width = 8;

reg CLK, RST, TX_Valid;
reg [3:0] DIV_VALUE;
reg [Data_Width-1:0] TX_Data;
reg [1:0] slave_select;
reg MISO;

wire [Data_Width-1:0] RX_Data;
wire Invalid_Slave_Select, busy, RX_Valid;
wire [2:0] SS;
wire MOSI, SCLK;

reg [7:0] Expected_RX;
integer i;

// DUT
Top_SPI_Master #(
    .Data_Width(8),
    .number_of_slaves(3),
    .COUNTER_WIDTH(4)
) DUT (
    .CLK(CLK),
    .RST(RST),
    .TX_Valid(TX_Valid),
    .DIV_VALUE(DIV_VALUE),
    .TX_Data(TX_Data),
    .slave_select(slave_select),
    .MISO(MISO),
    .RX_Data(RX_Data),
    .Invalid_Slave_Select(Invalid_Slave_Select),
    .busy(busy),
    .RX_Valid(RX_Valid),
    .SS(SS),
    .MOSI(MOSI),
    .SCLK(SCLK)
);

// Clock: 10 ns period
initial CLK = 0;
always #5 CLK = ~CLK;

initial begin

    // Initial values
    RST = 0;
    TX_Valid = 0;
    TX_Data = 8'hA5;
    Expected_RX = 8'h3C;
    slave_select = 0;
    DIV_VALUE = 4;
    MISO = 0;

    // Reset
    #20;
    RST = 1;

    // Prepare first received bit
    MISO = Expected_RX[7];

    // Start transaction
    @(negedge CLK);
    TX_Valid = 1;

    @(negedge CLK);
    TX_Valid = 0;

    // Wait until slave 0 is selected
    wait(SS[0] == 0);

    // Check TX and drive RX
    for (i = 7; i >= 0; i = i - 1) begin

        @(negedge SCLK);
        #1;

        if (MOSI !== TX_Data[i])
            $display("TX ERROR: Bit %0d", i);
        else
            $display("TX PASS: Bit %0d", i);

        if (i > 0)
            MISO = Expected_RX[i-1];

    end

    // Wait for transaction completion
    wait(RX_Valid == 1);
    #1;

    // Check received data
    if (RX_Data == Expected_RX)
        $display("RX PASS: %h", RX_Data);
    else
        $display("RX ERROR: Expected %h, Received %h",
                  Expected_RX, RX_Data);

    // Check slave release
    if (SS == 3'b111)
        $display("SS RELEASE PASS");
    else
        $display("SS RELEASE ERROR");

    if (Invalid_Slave_Select == 0)
        $display("SLAVE SELECT PASS");

    $display("SPI TEST FINISHED");

    #20;
    $finish;

end

endmodule
