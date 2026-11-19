module SPI_Master_FSM #(
    parameter Data_Width = 8,
              number_of_slaves = 3

) (
    input CLK,RST,
    input Count_Done,
    input TX_Valid,
    input [$clog2(number_of_slaves)-1:0] slave_select,
    input shift_enable,
    output reg Invalid_Slave_Select,
    output reg TX_EN,
    output reg Count_RST,
    output reg SS_0,
    output reg SS_1,
    output reg SS_2,
    output reg RX_EN,
    output reg busy,
    output reg RX_Valid,
    output reg CLK_EN
);
reg [4:0] cur_state;
reg [4:0] nxt_state;
reg [$clog2(number_of_slaves)-1:0] slave_select_reg;

// State Encoding --> one hot

localparam IDLE = 5'b00001;
localparam LOAD = 5'b00010;
localparam ASSERT_SS = 5'b00100;
localparam TRANSFER = 5'b01000;
localparam DONE = 5'b10000;

always @(*)
begin
    busy = 1'b0;
    TX_EN = 1'b0;
    Count_RST = 1'b0;
    Invalid_Slave_Select = 1'b0;
    RX_Valid = 1'b0;
    nxt_state = IDLE;
    CLK_EN = 1'b0;
    RX_EN = 1'b0;  
    case(cur_state)
        IDLE: begin
            busy = 1'b0;
            if(TX_Valid)
            begin
                nxt_state = LOAD;
            end
            else
            begin
                nxt_state = IDLE;
            end
        end
        LOAD: begin
            TX_EN = 1'b1;
            Count_RST = 1'b1;
            nxt_state = ASSERT_SS;
        end
        ASSERT_SS: begin
        busy = 1'b1;
        if (slave_select_reg < number_of_slaves)
            nxt_state = TRANSFER;
        else 
        begin
            Invalid_Slave_Select = 1'b1;
            nxt_state = IDLE;
        end
        end
        TRANSFER:
        begin
        CLK_EN = 1'b1;
        RX_EN = 1'b1;
        busy = 1'b1;
        if(Count_Done& shift_enable)
            nxt_state = DONE;
        else
            nxt_state = TRANSFER;
        end
        DONE: begin
            nxt_state = IDLE;
            RX_Valid = 1'b1;
            busy = 1'b0;
        end
        default: 
        begin
            nxt_state = IDLE;
        end
    endcase
end

always @(posedge CLK or negedge RST)
begin
    if(!RST)
        cur_state <= IDLE;
    else
        cur_state <= nxt_state;
end

always @(posedge CLK or negedge RST)
begin
    if (!RST)
        slave_select_reg <= 'b0;
    else if (cur_state == LOAD)
        slave_select_reg <= slave_select;
end

always @(*)
begin
    SS_0 = 1'b1;
    SS_1 = 1'b1;
    SS_2 = 1'b1;
    if (cur_state == ASSERT_SS || cur_state == TRANSFER)
    begin
        case(slave_select_reg)
            2'b00: SS_0 = 1'b0;
            2'b01: SS_1 = 1'b0;
            2'b10: SS_2 = 1'b0;
            default: begin
                SS_0 = 1'b1;
                SS_1 = 1'b1;
                SS_2 = 1'b1;
            end
        endcase
    end
end

endmodule
