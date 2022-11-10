module fsm_lcd_parallel(
    CLK_400Hz, // тактовый сигнал - 400 Гц
    resetn,    // сигнал сброса, подключаем к кнопке
    // ЧЧ:ММ:СС, каждая из цифр представлена в двоично-десятичном коде
    characterIN, addressIN,// 
    LCD_ON, // вывод для управления подачей питания на дисплей
    LCD_BLON, 
    LCD_RS, // Select registers, 0 - обращаемся к регистру команд, 
    // 1 - обращаемся к регистру данных
    LCD_EN, // Start data read/write - строб, для записи/чтения нужно 
    // последовательно установить в 1 и сбросить в 0
    LCD_RW, // Select read or write, 0 - запись, 1 - чтение. 
    LCD_DATA // 8-bit Data bus - 8-битная шина данных
);

    // определение направления передачи и разрядности данных
    input CLK_400Hz, resetn;
    input[7:0] characterIN, addressIN;// 0 -адрес 1 - символ
    output LCD_ON, LCD_BLON, LCD_RS, LCD_EN, LCD_RW;
    output[7:0] LCD_DATA;

    // объявление вспомогательных переменных
    reg[5:0] p_state, n_state; // регистры для хранения текущего и следующего
    // состояния, соответственно
    reg LCD_EN, LCD_RS; // регистры, дублирующие входные линии внутри блока
    reg[7:0] LCD_DATA_VALUE;

    // перечисление всех состояний автомата
    parameter[5:0] reset1 = 1, toggle_e1 = 2, reset2 = 3, toggle_e2 = 4, 
        reset3 = 5, toggle_e3 = 6, func_set = 7, toggle_e4 = 8, 
        display_off = 9, toggle_e5 = 10, display_clear = 11, toggle_e6 = 12,
        display_on = 13, toggle_e7 = 14, mode_set = 15, toggle_e8 = 16, 
        write_address = 17, toggle_e9 = 18, write_char = 19, toggle_e10 = 20;/*,
        write_char3 = 21, toggle_e11 = 22, write_char4 = 23, toggle_e12 = 24,
        write_char5 = 25, toggle_e13 = 26, write_char6 = 27, toggle_e14 = 28,
        write_char7 = 29, toggle_e15 = 30, write_char8 = 31, toggle_e16 = 32,
        return_home = 33, toggle_e17 = 34;*/
    assign LCD_ON = 1; // включаем дисплей
    assign LCD_BLON = 0;
    assign LCD_RW = 0; // настраиваем работу дисплея только в режиме записи
    // если настроен режим чтения, перевести выводы ПЛИС, подключенные 
    // к дисплею, в высокоимпедансное состояние
    assign LCD_DATA = LCD_RW ? 8'bzzzzzzzz: LCD_DATA_VALUE;

    // настройка последовательности смены состояний автомата
    // выполнять каждый раз при изменении значения p_state
    always @(p_state) begin
        case (p_state)
            // начальная инициализация дисплея
            reset1: begin 
                n_state = toggle_e1; // следующее состояние - toggle_e1
                // запись команды, устанавливаем стробирующий сигнал LCD_EN в 1
                {LCD_EN, LCD_RS} = 2'b10;
                // Function set: DL=1, N=1, F=0 - 8-битный обмен данными, 
                // 2 строки, символы размером 5*8
                LCD_DATA_VALUE = 8'h38; 
            end


            toggle_e1 : begin
                n_state = reset2;
                // запись команды: устанавливаем стробирующий сигнал 
                // LCD_EN в 0, сигнал LCD_RS в 0 (обращаемся к регистру 
                // команд дисплея)
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
                // Display off: D=0, C=0, B=0 (выключен дисплей, курсор 
                // и мигание курсора)
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
                // Display on: D=1, C=0, B=0 (включен дисплей, выключены курсор 
                // и мигание курсора)
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
                // Entry mode set: I/D=1, S=0 (при наборе номер позиции будет
                // увеличиваться, сдвига экрана нет)
                LCD_DATA_VALUE = 8'h06; 
            end
            toggle_e8 : begin
                n_state = write_address;
                {LCD_EN, LCD_RS} = 2'b00; 
                LCD_DATA_VALUE = 8'h06; 
            end

            write_address : begin
                n_state = toggle_e9;
                // запись команды: устанавливаем стробирующий сигнал 
                // LCD_EN в 0, сигнал LCD_RS в 1 (обращаемся к регистру 
                // данных дисплея)
                {LCD_EN, LCD_RS} = 2'b10;
                // для цифр от 0 до 9 старший ниббл 0011,
                // младший ниббл - соответствующий двоичный код
                // запись старшей цифры часов
                LCD_DATA_VALUE = addressIN; 
            end
            toggle_e9 : begin
                n_state = write_char;
                {LCD_EN, LCD_RS} = 2'b00; 
                LCD_DATA_VALUE = addressIN; 
            end // закончили запись старшей цифры часов

            write_char : begin
                n_state = toggle_e10;
                {LCD_EN, LCD_RS} = 2'b11;
                // запись младшей цифры часов
                LCD_DATA_VALUE = characterIN;
            end
            toggle_e10 : begin
                n_state = write_address;
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = characterIN; 
            end // закончили запись младшей цифры часов


            /*write_char3 : begin
                n_state = toggle_e11;
                {LCD_EN, LCD_RS} = 2'b11; 
                LCD_DATA_VALUE = 8'h3a; // выводим символ ":"
            end
            toggle_e11 : begin
                n_state = write_char4;
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = 8'h3a; 
            end // закончили вывод символа ":"

            write_char4 : begin
                n_state = toggle_e12;
                {LCD_EN, LCD_RS} = 2'b11;
                // запись старшей цифры минут
                LCD_DATA_VALUE = { 4'b0011, bcd_mind1};
            end
            toggle_e12 : begin
                n_state = write_char5;
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = { 4'b0011, bcd_mind1};
            end // закончили запись старшей цифры минут

            write_char5 : begin
                n_state = toggle_e13;
                {LCD_EN, LCD_RS} = 2'b11;
                // запись младшей цифры минут
                LCD_DATA_VALUE = { 4'b0011, bcd_mind0};
            end
            toggle_e13 : begin
                n_state = write_char6; 
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = { 4'b0011, bcd_mind0}; 
            end // закончили запись младшей цифры минут

            write_char6 : begin
                n_state = toggle_e14;
                {LCD_EN, LCD_RS} = 2'b11; 
                LCD_DATA_VALUE = 8'h3a; // выводим символ ":"
            end
            toggle_e14 : begin
                n_state = write_char7;
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = 8'h3a; 
            end // закончили вывод символа ":"

            write_char7 : begin
                n_state = toggle_e15;
               {LCD_EN, LCD_RS} = 2'b11; 
               // запись старшей цифры секунд
               LCD_DATA_VALUE = { 4'b0011, bcd_secd1};
            end
            toggle_e15 : begin
                n_state = write_char8;
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = { 4'b0011, bcd_secd1}; 
            end // закончили запись старшей цифры секунд





            write_char8 : begin
                n_state = toggle_e16;
                {LCD_EN, LCD_RS} = 2'b11; 
                // запись младшей цифры секунд
                LCD_DATA_VALUE = { 4'b0011, bcd_secd0};
            end
            toggle_e16 : begin
                n_state = return_home; 
                {LCD_EN, LCD_RS} = 2'b01; 
                LCD_DATA_VALUE = { 4'b0011, bcd_secd0}; 
            end // закончили запись младшей цифры секунд

            return_home : begin
                n_state = toggle_e17;
                {LCD_EN, LCD_RS} = 2'b10;// запись команды
                // Set DDRAM address - устанавливаем адрес равным 
                // 00h - начало первой строки
                LCD_DATA_VALUE = 8'h80; 
            end
            toggle_e17 : begin
                n_state = write_char1; // зацикливаем вывод данных на дисплей
                {LCD_EN, LCD_RS} = 2'b00; 
                LCD_DATA_VALUE = 8'h80;
            end*/
        endcase
    end

// основной цикл смены состояний
    always @ (posedge CLK_400Hz, negedge resetn) begin
        if (resetn == 0) begin
            p_state <= reset1;
        end
        else
            p_state <= n_state;
    end
endmodule
