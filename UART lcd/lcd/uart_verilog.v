module uart_verilog (
        input wire clk_50M,             //aiaoiyy oaeoiaay ?anoioa
        input wire key,                 //eiiiea aey caionea ia?aaa?e iaiiai aaeoa
        input wire [7:0]in_data,        //ia yoe ii?ee onoaiaaeeaa?ony i?aaiacia?aiiua
										//aey ia?aaa?e aaiiua - iaei aaeo
        output reg [7:0]led,            //naaoiaeiau aey eiaeeaoee iieo?aaiuo aaiiuo
        input wire uart_rx,             //i?e?iiee UART
        output reg uart_tx,              //ia?aaao?ee UART
        output reg uart_rx_dr
);
parameter MAIN_CLK = (50_000_000);      //50MHz - aiaoiy oaeoiaay
parameter UART_CLK = (9600);            //nei?inou UART

///ia?aiaiiua, ioiinyueany e ia?aaao?eeo
reg clk_9600;                           //?anoioa aey UART - 9600Hz
reg [9:0]uart_tx_reg = 10'b1xxxxxxxx0; //eieoeaeecaoey ?aaeno?a UART (StartBit - 0, StopBit - 1, aeou aaiiuo - ia aa?ii)
reg [3:0]uart_tx_cur_bit =4'b0;         //iiia? ia?aaaaaaiiai aeoa
reg uart_tx_send = 0;                   //aoia aey caionea ia?aaa?e aaiiuo
reg uart_tx_send_pulse = 0;             //eiioeun, ii eioi?iio ia?eiaaony ia?aaa?a aaiiuo
reg uart_tx_busy = 0;                   //ninoiyiea ia?aaao?eea (1 - ea?o ia?aaa?a, 0 - i?inoie)
///ia?aiaiiua, ioiinyueany e i?e?iieeo
reg [7:0]uart_rx_byte =8'b0;            //?aaeno? aey o?aiaiey i?eiyoiai aaeoa
reg [3:0]uart_rx_cur_bit =4'b0;         //eiaaen n?eouaaaiiai aeoa
reg uart_rx_data_ready = 0;             //eiioeun, iiiaaua?uee i caaa?oaiee i?e?ia aaiiuo
reg uart_rx_busy = 0;                   //ninoiyiea i?e?iieea (1 - ea?o i?e?i, 0 - i?inoie)

/// yoe a?aiaiiua ?aaeno?u
reg [13:0]clkr_9600 = 14'b0;            //n??o?ee aaia?aoi?a ?anoiou aey 9600Ao
reg uart_tx_send_prev = 0;              //a?aiaiiay ia?aiaiiay aey iienea o?iioa uart_tx_send


initial begin                           //ia?aeuiay onoaiiaea (ia aa?uoa oai, eoi aiai?eo, ?oi initial ?aaioaao oieuei aey neioeyoee)
        uart_tx = 1;                            //onoaiiaea eeiee ia?aaao?eea a 1 (IDLE) i?e noa?oa
        uart_rx_dr = uart_rx_data_ready;
end

always @(posedge clk_50M) begin : send_byte
/*Caanu aie?ai auou eia aey oeeuo?aoee a?aaacaa eiioaeoia*/
        uart_tx_send = ~key;                 //onoaiaaeeaaai uart_tx_send a 1 eiaaa ia?aoa e?aeiyy eiiiea e a 0 - eiaaa io?aoa
end


always @(posedge clk_50M) begin : baud_rate_generator
        ///reg [13:0]clkr_9600 = 14'b0;            //n??o?ee aaia?aoi?a ?anoiou aey 9600Ao
        clkr_9600 = clkr_9600 + 14'b1;          //eie?aiaio n?o?eea
        if(clkr_9600 == (MAIN_CLK/UART_CLK/2)) begin
                clkr_9600 = 14'b0;              //na?in n??o?eea
                clk_9600 = ~clk_9600;           //oi?ie?iaaiea o?iioa ?anoiou 9600Ao
        end
end

always @(posedge uart_tx_send_pulse) begin : init_uart_tx_buf
        uart_tx_reg[8:1] = in_data;                 //caienu ioi?aaeyaiiai cia?aiey a uart rx register
end

always @(negedge clk_9600) begin : uart_tx_start_pulse_generator //aaia?aoi? noa?o-eiioeuna, ?aaioa ii io?eoaoaeuiiio o?iioo, ?oi au ai a?aiy iiei?eoaeuiiai iaoiaeouny  aa?aioe?iaaiiii ninoiyiee 1, eee 0
        //reg uart_tx_send_prev = 0;              //a?aiaiiay ia?aiaiiay aey iienea o?iioa uart_tx_send
        if((uart_tx_send_prev == 0) && (uart_tx_send == 1)) begin //anee iaeaai iiei?eoaeuiue o?iio
                uart_tx_send_pulse <= 1;        //oi?ie?oai iiei?eoaeuiue o?iio uart_tx_send_pulse
        end
        if(uart_tx_send_pulse == 1)
                uart_tx_send_pulse <= 0;        //a neaao?uai oeeea ?anoiou 9600 oi?ie?oai io?eoaoaeuiue o?iio uart_tx_send_pulse
        else
                uart_tx_send_prev = uart_tx_send;       //nio?aiyai ninoiyiea uart_tx_send oieuei anee ia oi?ie?iaaee oieuei ?oi eiioeun
end

always @(posedge clk_9600) begin : uart_transmitter
        if(uart_tx_cur_bit > 9) begin : uart_tx_done                    //aaeo ioi?aaeai, ia?aoiaei a ?aouaa ninoiyiea
                uart_tx = 1;                                            //onoaiiaea eeiee ia?aaao?eea a 1 (IDLE)
                uart_tx_cur_bit = 0;
                uart_tx_busy = 0;
        end else if(uart_tx_busy == 1) begin : uart_tx_set_cur_bit      //anee ea?o ia?aaa?a
                uart_tx = uart_tx_reg[uart_tx_cur_bit];                 //aunoaaeyai neaao?uee aeo
                uart_tx_cur_bit = uart_tx_cur_bit + 4'b0001;            //oaaee?eaaai cia?aiea n??o?eea aeo
        end else if(uart_tx_send_pulse == 1) begin : uart_tx_start      //anee o?aaoaony ia?aaaou aaiiua
                uart_tx_busy = 1;                                       //ia?eiaai ia?aaa?o ia neaao?uai oaeoa ?anoiou 9600
        end
end


always @(posedge clk_9600) begin : uart_receiver
        if((uart_rx_busy == 0)&&(uart_rx == 0)) begin : uart_new_byte   //anee ia a ninoiyiee i?e?ia aaiiuo e eeiey rx ia a IDLE
                uart_rx_busy = 1;                                       //ia?aoiaei a ninoiyiea i?e?ia aaiiuo
                uart_rx_cur_bit = 0;                                    //onoaiaaeeaaai n??o?ee i?eiyouo aeo a 0
        end else if (uart_rx_cur_bit < 8) begin
                uart_rx_byte[uart_rx_cur_bit] = uart_rx;                //nio?aiyai oaeouee aeo a ?aaeno?
                uart_rx_cur_bit = uart_rx_cur_bit + 4'b0001;            //oaaee?eaaai n??o?ee n?eoaiiuo aeo
        end else begin
                uart_rx_busy = 0;                                       //aaiiua n?eoaiu, ia?aoiaei a ?a?ei i?eaaiey (ooo aie?ia auou i?iaa?ea noii-aeoa)
        end
end

always @(negedge clk_9600) begin : uart_rx_data_ready_pulse_generator
        if(uart_rx_cur_bit == 4'd8) begin       //anee aaeo iieiinou? i?eiyo
                uart_rx_data_ready <= 1;
                uart_rx_dr = 1;        //oi?ie?oai iiei?eoaeuiue o?iio uart_rx_data_ready 
                led = uart_rx_byte;             //ioia?a?aai n?eoaiiue aaeo ia naaoiaeiaao
        end
        if(uart_rx_data_ready == 1)
                uart_rx_data_ready <= 0;        //a neaao?uai oeeea ?anoiou 9600 oi?ie?oai io?eoaoaeuiue o?iio uart_rx_data_ready
end

endmodule