module fsm_lcd_parallel(
    CLK_400Hz, // �������� ������ - 400 ��
    resetn,    // ������ ������, ���������� � ������
    // ��:��:��, ������ �� ���� ������������ � �������-���������� ����
    characterIN, addressIN,// 
    LCD_ON, // ����� ��� ���������� ������� ������� �� �������
    LCD_BLON, 
    LCD_RS, // Select registers, 0 - ���������� � �������� ������, 
    // 1 - ���������� � �������� ������
    LCD_EN, // Start data read/write - �����, ��� ������/������ ����� 
    // ��������������� ���������� � 1 � �������� � 0
    LCD_RW, // Select read or write, 0 - ������, 1 - ������. 
    LCD_DATA // 8-bit Data bus - 8-������ ���� ������
);

    // ����������� ����������� �������� � ����������� ������
    input CLK_400Hz, resetn;
    input[7:0] characterIN, addressIN;// 0 -����� 1 - ������
    output LCD_ON, LCD_BLON, LCD_RS, LCD_EN, LCD_RW;
    output[7:0] LCD_DATA;

    // ���������� ��������������� ����������
    reg[5:0] p_state, n_state; // �������� ��� �������� �������� � ����������
    // ���������, ��������������
    reg LCD_EN, LCD_RS; // ��������, ����������� ������� ����� ������ �����
    reg[7:0] LCD_DATA_VALUE;

    // ������������ ���� ��������� ��������
    parameter[5:0] reset1 = 1, toggle_e1 = 2, reset2 = 3, toggle_e2 = 4, 
        reset3 = 5, toggle_e3 = 6, func_set = 7, toggle_e4 = 8, 
        display_off = 9, toggle_e5 = 10, display_clear = 11, toggle_e6 = 12,
        display_on = 13, toggle_e7 = 14, mode_set = 15, toggle_e8 = 16, 
        write_address = 17, toggle_e9 = 18, write_char = 19, toggle_e10 = 20;/*,
        write_char3 = 21, toggle_e11 = 22, write_char4 = 23, toggle_e12 = 24,
        write_char5 = 25, toggle_e13 = 26, write_char6 = 27, toggle_e14 = 28,
        write_char7 = 29, toggle_e15 = 30, write_char8 = 31, toggle_e16 = 32,
        return_home = 33, toggle_e17 = 34;*/
    assign LCD_ON = 1; // �������� �������
    assign LCD_BLON = 0;
    assign LCD_RW = 0; // ����������� ������ ������� ������ � ������ ������
    // ���� �������� ����� ������, ��������� ������ ����, ������������ 
    // � �������, � ����������������� ���������
    assign LCD_DATA = LCD_RW ? 8'bzzzzzzzz: LCD_DATA_VALUE;

    // ��������� ������������������ ����� ��������� ��������
    // ��������� ������ ��� ��� ��������� �������� p_state
    always @(p_state) begin
        case (p_state)
            // ��������� ������������� �������
            reset1: begin 
                n_state = toggle_e1; // ��������� ��������� - toggle_e1
                // ������ �������, ������������� ������������ ������ LCD_EN � 1
                {LCD_EN, LCD_RS} = 2'b10;
                // Function set: DL=1, N=1, F=0 - 8-������ ����� �������, 
                // 2 ������, ������� �������� 5*8
                LCD_DATA_VALUE = 8'h38; 
            end


            toggle_e1 : begin
                n_state = reset2;
                // ������ �������: ������������� ������������ ������ 
                // LCD_EN � 0, ������ LCD_RS � 0 (���������� � �������� 
                // ������ �������)
                {LCD_EN, LCD_RS} = 2'b00;
                LCD_DATA_VALUE = 8'h38; 
            end

            reset2 : begin
                n_state = toggle_e2;
                {LCD_EN, LCD_RS} = 2'b10; 
                LCD_DATA_VALUE = 8'h38; // Function set: DL=1, N=1, F=0
            end
            toggle_e2 : begin
                n_state = reset3;
                {LCD_EN, LCD_RS} = 2'b00; 
                LCD_DATA_VALUE = 8'h38; // Function set: DL=1, N=1, F=0
            end

            reset3 : begin
                n_state = toggle_e3;
                {LCD_EN, LCD_RS} = 2'b10; 
                LCD_DATA_VALUE = 8'h38; // Function set: DL=1, N=1, F=0
            end
            toggle_e3 : begin
                n_state = func_set;
                {LCD_EN, LCD_RS} = 2'b00; 
                LCD_DATA_VALUE = 8'h38; 
            end

            func_set : begin
                n_state = toggle_e4;
                {LCD_EN, LCD_RS} = 2'b10; 
                LCD_DATA_VALUE = 8'h38; // Function set: DL=1, N=1, F=0
            end
            toggle_e4 : begin
                n_state = display_off;
                {LCD_EN, LCD_RS} = 2'b00; 
                LCD_DATA_VALUE = 8'h38; 
            end

            display_off : begin
                n_state = toggle_e5;
                {LCD_EN, LCD_RS} = 2'b10;
                // Display off: D=0, C=0, B=0 (�������� �������, ������ 
                // � ������� �������)
                LCD_DATA_VALUE = 8'h08;
            end
            toggle_e5 : begin
                n_state = display_clear;
                {LCD_EN, LCD_RS} = 2'b00;
                LCD_DATA_VALUE = 8'h08;
            end

            display_clear: begin
                n_state = toggle_e6;
                {LCD_EN, LCD_RS} = 2'b10; 
                LCD_DATA_VALUE = 8'h01; // Display clear
            end


            toggle_e6 : begin
                n_state = display_on;
                {LCD_EN, LCD_RS} = 2'b00; 
                LCD_DATA_VALUE = 8'h01; 
            end

            display_on : begin
                n_state = toggle_e7;
                {LCD_EN, LCD_RS} = 2'b10;
                // Display on: D=1, C=0, B=0 (������� �������, ��������� ������ 
                // � ������� �������)
                LCD_DATA_VALUE = 8'h0c; 
            end
            toggle_e7 : begin
                n_state = mode_set;
                {LCD_EN, LCD_RS} = 2'b00; 
                LCD_DATA_VALUE = 8'h0c; 
            end

            mode_set : begin
                n_state = toggle_e8;
                {LCD_EN, LCD_RS} = 2'b10;
                // Entry mode set: I/D=1, S=0 (��� ������ ����� ������� �����
                // �������������, ������ ������ ���)
                LCD_DATA_VALUE = 8'h06; 
            end
            toggle_e8 : begin
                n_state = write_address;
                {LCD_EN, LCD_RS} = 2'b00; 
                LCD_DATA_VALUE = 8'h06; 
            end

            write_address : begin
                n_state = toggle_e9;
                // ������ �������: ������������� ������������ ������ 
                // LCD_EN � 0, ������ LCD_RS � 1 (���������� � �������� 
                // ������ �������)
                {LCD_EN, LCD_RS} = 2'b10;
                // ��� ���� �� 0 �� 9 ������� ����� 0011,
                // ������� ����� - ��������������� �������� ���
                // ������ ������� ����� �����
                LCD_DATA_VALUE = addressIN; 
            end
            toggle_e9 : begin
                n_state = write_char;
                {LCD_EN, LCD_RS} = 2'b00; 
                LCD_DATA_VALUE = addressIN; 
            end // ��������� ������ ������� ����� �����

            write_char : begin
                n_state = toggle_e10;
                {LCD_EN, LCD_RS} = 2'b11;
                // ������ ������� ����� �����
                LCD_DATA_VALUE = characterIN;
            end
            toggle_e10 : begin
                n_state = write_address;
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = characterIN; 
            end // ��������� ������ ������� ����� �����


            /*write_char3 : begin
                n_state = toggle_e11;
                {LCD_EN, LCD_RS} = 2'b11; 
                LCD_DATA_VALUE = 8'h3a; // ������� ������ ":"
            end
            toggle_e11 : begin
                n_state = write_char4;
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = 8'h3a; 
            end // ��������� ����� ������� ":"

            write_char4 : begin
                n_state = toggle_e12;
                {LCD_EN, LCD_RS} = 2'b11;
                // ������ ������� ����� �����
                LCD_DATA_VALUE = { 4'b0011, bcd_mind1};
            end
            toggle_e12 : begin
                n_state = write_char5;
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = { 4'b0011, bcd_mind1};
            end // ��������� ������ ������� ����� �����

            write_char5 : begin
                n_state = toggle_e13;
                {LCD_EN, LCD_RS} = 2'b11;
                // ������ ������� ����� �����
                LCD_DATA_VALUE = { 4'b0011, bcd_mind0};
            end
            toggle_e13 : begin
                n_state = write_char6; 
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = { 4'b0011, bcd_mind0}; 
            end // ��������� ������ ������� ����� �����

            write_char6 : begin
                n_state = toggle_e14;
                {LCD_EN, LCD_RS} = 2'b11; 
                LCD_DATA_VALUE = 8'h3a; // ������� ������ ":"
            end
            toggle_e14 : begin
                n_state = write_char7;
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = 8'h3a; 
            end // ��������� ����� ������� ":"

            write_char7 : begin
                n_state = toggle_e15;
               {LCD_EN, LCD_RS} = 2'b11; 
               // ������ ������� ����� ������
               LCD_DATA_VALUE = { 4'b0011, bcd_secd1};
            end
            toggle_e15 : begin
                n_state = write_char8;
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = { 4'b0011, bcd_secd1}; 
            end // ��������� ������ ������� ����� ������





            write_char8 : begin
                n_state = toggle_e16;
                {LCD_EN, LCD_RS} = 2'b11; 
                // ������ ������� ����� ������
                LCD_DATA_VALUE = { 4'b0011, bcd_secd0};
            end
            toggle_e16 : begin
                n_state = return_home; 
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = { 4'b0011, bcd_secd0}; 
            end // ��������� ������ ������� ����� ������

            return_home : begin
                n_state = toggle_e17;
                {LCD_EN, LCD_RS} = 2'b10;// ������ �������
                // Set DDRAM address - ������������� ����� ������ 
                // 00h - ������ ������ ������
                LCD_DATA_VALUE = 8'h80; 
            end
            toggle_e17 : begin
                n_state = write_char1; // ����������� ����� ������ �� �������
                {LCD_EN, LCD_RS} = 2'b00; 
                LCD_DATA_VALUE = 8'h80;
            end*/
        endcase
    end

// �������� ���� ����� ���������
    always @ (posedge CLK_400Hz, negedge resetn) begin
        if (resetn == 0) begin
            p_state <= reset1;
        end
        else
            p_state <= n_state;
    end
endmodule
