module calc(
    input wire [3:0] number,
    input wire clk,
    input wire btn_latch,
    input wire btn_dup,
    input wire btn_plus,
    input wire btn_reset,
    output wire [8:0] seg_led1,
    output wire [8:0] seg_led2
);

    localparam STATE_WAIT_BTN_DOWN = 1'b0;
    localparam STATE_WAIT_BTN_UP = 1'b1;

    reg [7:0] A;
    reg [7:0] B;
    
    reg state;
    
    wire btn_latch_d;
    wire btn_dup_d;
    wire btn_plus_d;
    wire btn_reset_d;

    segment7 seg_lo(
        .seg_data(A[3:0]),
        .seg_led(seg_led1)
    );
    
    segment7 seg_hi(
        .seg_data(A[7:4]),
        .seg_led(seg_led2)
    );
    
    debounce db1(
        btn_latch,
        clk,
        btn_latch_d
    );
    
    debounce db2(
        btn_dup,
        clk,
        btn_dup_d
    );
    
    debounce db3(
        btn_plus,
        clk,
        btn_plus_d
    );
    
    debounce db4(
        btn_reset,
        clk,
        btn_reset_d
    );
    
    initial begin
        A <= 8'd0;
        B <= 8'd0;
        state <= STATE_WAIT_BTN_DOWN;
    end
    
    always @(posedge clk) begin
        case (state)
        STATE_WAIT_BTN_DOWN: begin
            if (btn_latch_d || btn_dup_d || btn_plus_d || btn_reset_d)
                state <= STATE_WAIT_BTN_UP;
            if (btn_latch_d)
                A <= {4'd0, number};
            if (btn_dup_d)
                B <= A;
            if (btn_plus_d)
                A <= A + B;
            if (btn_reset_d) begin
                A <= 8'd0;
                B <= 8'd0;
            end
        end
        STATE_WAIT_BTN_UP:
            if (!btn_latch_d && !btn_dup_d && !btn_plus_d && !btn_reset_d)
                state <= STATE_WAIT_BTN_DOWN;
        endcase
    end
endmodule