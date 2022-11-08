// ������ ��� ������ ������� � ������� ��:��:��
// ���������� ����������
module fsm_lcd(
	CLK_400Hz, 		// �������� ������ - 400 ��
	resetn, 			// ������ ������, ���������� � ������
	bcd_hrd1, bcd_hrd0, bcd_mind1, bcd_mind0, bcd_secd1, bcd_secd0, // ��:��:��, 
	// ������ �� ���� ������������ � �������-���������� ����
	LCD_ON, // ����� ��� ���������� ������� ������� �� �������
	LCD_RS, // Select registers, 0 - ���������� � �������� ������, 1 - ���������� � �������� ������
	LCD_EN, // Start data read/write - �����, ��� ������/������ ����� ��������������� ���������� � 1 � �������� � 0
	LCD_RW, // Select read or write, 0 - ������, 1 - ������. ������ ������������ ������ �����
	LCD_DATA // 8-bit Data bus - 8-������ ���� ������
	); 
	
	// ����������� ����������� �������� � ����������� ������
	input CLK_400Hz, resetn; 
	input [3:0] bcd_hrd1, bcd_hrd0, bcd_mind1, bcd_mind0, bcd_secd1, bcd_secd0; 
	output LCD_ON, LCD_RS, LCD_EN, LCD_RW; 
	output [7:0] LCD_DATA; 
	
	// ���������� ��������������� ����������
	reg [5:0] p_state, n_state; // �������� ��� �������� �������� � ���������� ���������, ��������������
	reg LCD_EN, LCD_RS; // ��������, ����������� ������� ����� ������ �����
	reg [7:0] LCD_DATA_VALUE; 
	// ������������ ���� ��������� ��������
	parameter [5:0] reset1=1, reset2=2, reset3=3, FUNC_SET=4, 
		display_off=5, display_clear=6, 
		display_on=7, mode_set=8, write_char1=9, 
		write_char2=10, write_char3=11, write_char4=12,
		write_char5=13, write_char6=14, write_char7=15,
		write_char8=16, write_char9=17, write_char10=18, 
		return_home=19, 
		toggle_e1=20,toggle_e2=21, toggle_e3=22, toggle_e4=23, 
		toggle_e5=24,toggle_e6=25, toggle_e7=26, toggle_e8=27, 
		toggle_e9=28,toggle_e10=29, toggle_e11=30, toggle_e12=31, 
		toggle_e13=32,toggle_e14=33, toggle_e15=34, toggle_e16=35, 
		toggle_e17=36,toggle_e18=37, toggle_e19=38, w_address=39, write_w=40,
		toggle_e20=41, toggle_e21=42, char1_address=43, write_e=44; 
	assign LCD_ON=1; // �������� �������
	assign LCD_RW=0; // ����������� ������ ������� ������ � ������ ������
	// ���� ������� ����� ������, ��������� ������ ����, ������������ � �������,
	// � ����������������� ���������
	assign LCD_DATA = LCD_RW? 8'bzzzzzzzz: LCD_DATA_VALUE;
	
	// ��������� ������������������ ����� ��������� ��������
	always @(p_state) // ��������� ������ ��� ��� ��������� �������� p_state
	begin
		case (p_state) 
			reset1:  // ��������� ������������� �������
			begin 
				n_state = toggle_e1; // ��������� ��������� - toggle_e1
				{LCD_EN, LCD_RS}=2'b10; // ������ �������, ������������� ������������ ������ LCD_EN � 1
				LCD_DATA_VALUE = 8'h38; // Function set: DL=1, N=1, F=0 - 8-������ ����� �������, 
												// 2 ������, ������� �������� 5*8
			end 
			toggle_e1: 
			begin 
				n_state = reset2; 
				{LCD_EN, LCD_RS}=2'b00; // ������ �������, ������������� ������������ ������ LCD_EN � 0
				LCD_DATA_VALUE = 8'h38; 
			end 
			reset2: 
			begin 
				n_state = toggle_e2; 
				{LCD_EN, LCD_RS}=2'b10; 
				LCD_DATA_VALUE = 8'h38; // Function set: DL=1, N=1, F=0
			end  
			toggle_e2: 
			begin 
				n_state = reset3; 
				{LCD_EN, LCD_RS}=2'b00; 
				LCD_DATA_VALUE = 8'h38; // Function set: DL=1, N=1, F=0
			end  
			reset3: 
			begin 
				n_state = toggle_e3; 
				{LCD_EN, LCD_RS}=2'b10; 
				LCD_DATA_VALUE = 8'h38; // Function set: DL=1, N=1, F=0
			end 
			toggle_e3: 
			begin 
				n_state = FUNC_SET; 
				{LCD_EN, LCD_RS}=2'b00; 
				LCD_DATA_VALUE = 8'h38; 
			end  
			FUNC_SET: 
			begin 
				 n_state = toggle_e4; 
				 {LCD_EN, LCD_RS}=2'b10; 
				 LCD_DATA_VALUE = 8'h38; // Function set: DL=1, N=1, F=0
			end 
			toggle_e4: 
			begin 
				 n_state = display_off; 
				 {LCD_EN, LCD_RS}=2'b00; 
				 LCD_DATA_VALUE = 8'h38; 
			end  
			display_off: 
			begin 
				 n_state = toggle_e5; 
				 {LCD_EN, LCD_RS}=2'b10; 
				 LCD_DATA_VALUE = 8'h08; // Display off: D=0, C=0, B=0 (�������� �������, ������ � ������� �������)
			end 
			toggle_e5: 
			begin 
				 n_state = display_clear; 
				 {LCD_EN, LCD_RS}=2'b00; 
				 LCD_DATA_VALUE = 8'h08; 
			end  
			display_clear: 
			begin 
				n_state = toggle_e6; 
				{LCD_EN, LCD_RS}=2'b10; 
				LCD_DATA_VALUE = 8'h01; // Display clear
			end  
			toggle_e6: 
			begin 
				 n_state = display_on; 
				 {LCD_EN, LCD_RS}=2'b00; 
				 LCD_DATA_VALUE = 8'h01; 
			end  
			display_on: 
			begin 
				 n_state = toggle_e7; 
				 {LCD_EN, LCD_RS}=2'b10; 
				 LCD_DATA_VALUE = 8'h0c; // Display on: D=1, C=0, B=0 (������� �������, ��������� ������ � ������� �������)
			end  
			toggle_e7: 
			begin 
				 n_state = mode_set; 
				 {LCD_EN, LCD_RS}=2'b00; 
				 LCD_DATA_VALUE = 8'h0c; 
			end  
			mode_set: 
			begin 
				 n_state = toggle_e8; 
				 {LCD_EN, LCD_RS}=2'b10; 
				 LCD_DATA_VALUE = 8'h06; // Entry mode set: I/D=1, S=0 (��� ������ ����� ������� ����� �������������, ������ ������ ���)
			end  
			toggle_e8: 
			begin 
				 n_state = write_char1; 
				 {LCD_EN, LCD_RS}=2'b00; 
				 LCD_DATA_VALUE = 8'h06; 
			end 
			
			
			write_char1: 
			begin 
				 n_state = toggle_e9; 
				 {LCD_EN, LCD_RS}=2'b11; // ������ ������, ������������� ������������ ������ LCD_EN � 1
				 LCD_DATA_VALUE = {4'b0011, bcd_hrd1}; // ��� ���� �� 0 �� 9 ������� ����� 0011,
																	// ������� ����� - ��������������� �������� ���
			end  
			toggle_e9: 
			begin 
				 n_state = write_char2; 
				 {LCD_EN, LCD_RS}=2'b01; 
				 LCD_DATA_VALUE = {4'b0011, bcd_hrd1}; // ��������� ������ ������� ����� �����
			end  
			write_char2: 
			begin 
				 n_state = toggle_e10; 
				 {LCD_EN, LCD_RS}=2'b11; 
				 LCD_DATA_VALUE = {4'b0011, bcd_hrd0}; // ������ ������� ����� �����
			end 
			toggle_e10: 
			begin 
				 n_state = write_char3; 
				 {LCD_EN, LCD_RS}=2'b01; 
				 LCD_DATA_VALUE = {4'b0011, bcd_hrd0}; 
			end   
			write_char3:  
			begin 
				 n_state = toggle_e11; 
				 {LCD_EN, LCD_RS}=2'b11; 
				 LCD_DATA_VALUE = 8'h3a; // ������ ������ ":"
			end   
			toggle_e11: 
			begin 
				 n_state = write_char4; 
				 {LCD_EN, LCD_RS}=2'b01; 
				 LCD_DATA_VALUE = 8'h3a; 
			end   
			write_char4: 
			begin 
				 n_state = toggle_e12; 
				 {LCD_EN, LCD_RS}=2'b11; 
				 LCD_DATA_VALUE = {4'b0011, bcd_mind1}; // ������ ������� ����� �����
			end   
			toggle_e12: 
			begin 
				 n_state = write_char5; 
				 {LCD_EN, LCD_RS}=2'b01; 
				 LCD_DATA_VALUE = {4'b0011, bcd_mind1};
			end   
			write_char5: 
			begin 
				 n_state = toggle_e13; 
				 {LCD_EN, LCD_RS}=2'b11; 
				 LCD_DATA_VALUE = {4'b0011, bcd_mind0}; // ������ ������� ����� �����
			end    
			toggle_e13: 
			begin 
				 n_state = write_char6; 
				 {LCD_EN, LCD_RS}=2'b01; 
				 LCD_DATA_VALUE = {4'b0011, bcd_mind0}; 
			end    
			write_char6: 
			begin 
				 n_state = toggle_e14; 
				 {LCD_EN, LCD_RS}=2'b11; 
				 LCD_DATA_VALUE = 8'h3a; // ������ ������ ":"
			end   
			toggle_e14: 
			begin 
				 n_state = write_char7; 
				 {LCD_EN, LCD_RS}=2'b01; 
				 LCD_DATA_VALUE = 8'h3a; 
			end   
			write_char7: 
			begin 
				 n_state = toggle_e15; 
				 {LCD_EN, LCD_RS}=2'b11; 
				 LCD_DATA_VALUE ={4'b0011, bcd_secd1}; // ������ ������� ����� ������
			end   
			toggle_e15: 
			begin 
				 n_state = write_char8; 
				 {LCD_EN, LCD_RS}=2'b01; 
				 LCD_DATA_VALUE ={4'b0011, bcd_secd1}; 
			end   
			write_char8:  
			begin 
				 n_state = toggle_e16; 
				 {LCD_EN, LCD_RS}=2'b11; 
				 LCD_DATA_VALUE ={4'b0011, bcd_secd0}; // ������ ������� ����� ������
			end   
			toggle_e16: 
			begin 
				 n_state = return_home;//w_address; 
				 {LCD_EN, LCD_RS}=2'b01; 
				 LCD_DATA_VALUE ={4'b0011, bcd_secd0}; 
			end   
			return_home:  
			begin 
				 n_state = toggle_e21; 
				 {LCD_EN, LCD_RS}=2'b10; // ������ �������
				 LCD_DATA_VALUE =8'h80; // Set DDRAM address - ������������� ����� ������ 
												// 00h - ������ ������ ������
			end  
			toggle_e21: 
			begin 
				 n_state = write_char1; // ����������� ����� ������ �� �������
				 {LCD_EN, LCD_RS}=2'b00; 
				 LCD_DATA_VALUE =8'h80;
			end   
		endcase 
	end
	
	// �������� ���� ����� ���������
	always @ (posedge CLK_400Hz, negedge resetn) 
	begin 
		if (resetn == 0) 
		begin 
			p_state <= reset1; 
		end 
		else 
			p_state <= n_state; 
	end 
endmodule