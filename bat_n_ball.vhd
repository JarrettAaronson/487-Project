LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY falling_block IS
    PORT (
        v_sync      : IN  STD_LOGIC;
        pixel_row   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x       : IN  STD_LOGIC_VECTOR (10 DOWNTO 0);
        reset_block : IN  STD_LOGIC;
        board_in    : IN  STD_LOGIC_VECTOR(149 DOWNTO 0); 
        block_count : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        red         : OUT STD_LOGIC;
        green       : OUT STD_LOGIC;
        blue        : OUT STD_LOGIC;
        falling     : OUT STD_LOGIC;
        landed_row  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        landed_col  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        board_out   : OUT STD_LOGIC_VECTOR(149 DOWNTO 0)
    );
END falling_block;

ARCHITECTURE Behavioral OF falling_block IS
    CONSTANT bat_w : INTEGER := 20;
    CONSTANT bat_h : INTEGER := 20;
    CONSTANT SCREEN_BOTTOM : INTEGER := 600;
    CONSTANT LEFT_PLAY_AREA : INTEGER := 200;
    CONSTANT RIGHT_PLAY_AREA : INTEGER := 600;
    CONSTANT CELL_SIZE : INTEGER := 40;
    CONSTANT COLS : INTEGER := 10;
    CONSTANT ROWS : INTEGER := 15;

    SIGNAL bat_y : UNSIGNED(10 DOWNTO 0) := TO_UNSIGNED(bat_h, 11);
    SIGNAL bat_on : STD_LOGIC;
    SIGNAL block_falling : STD_LOGIC := '1';

    CONSTANT fall_speed : UNSIGNED(10 DOWNTO 0) := TO_UNSIGNED(2,11);

    SIGNAL cell_row_s, cell_col_s : INTEGER := 0;
    SIGNAL board_reg : STD_LOGIC_VECTOR(149 DOWNTO 0) := (OTHERS => '0');
BEGIN
    falling <= block_falling;
    board_out <= board_reg;

    -- Initialize board_reg from board_in on every frame
    process(v_sync)
    begin
        if rising_edge(v_sync) then
            board_reg <= board_in;
        end if;
    end process;

    -- Determine if current pixel is on the block
    PROCESS (bat_x, bat_y, pixel_row, pixel_col)
        VARIABLE bx, by, prow, pcol : INTEGER;
    BEGIN
        prow := TO_INTEGER(UNSIGNED(pixel_row));
        pcol := TO_INTEGER(UNSIGNED(pixel_col));
        bx := TO_INTEGER(UNSIGNED(bat_x));
        by := TO_INTEGER(bat_y);

        IF (pcol >= (bx - bat_w)) AND (pcol <= (bx + bat_w)) AND
           (prow >= (by - bat_h)) AND (prow <= (by + bat_h)) THEN
            bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;
    END PROCESS;

    -- Color logic: Alternate color based on block_count
    PROCESS(pixel_col, bat_on, block_count)
        VARIABLE pcol : INTEGER;
        VARIABLE even_block : BOOLEAN;
    BEGIN
        pcol := TO_INTEGER(UNSIGNED(pixel_col));
        even_block := (TO_INTEGER(UNSIGNED(block_count)) MOD 2 = 0);

        IF (pcol >= LEFT_PLAY_AREA) AND (pcol <= RIGHT_PLAY_AREA) THEN
            IF bat_on = '1' THEN
                IF even_block THEN
                    -- Red block
                    red <= '1'; green <= '0'; blue <= '0';
                ELSE
                    -- Green block
                    red <= '0'; green <= '1'; blue <= '0';
                END IF;
            ELSE
                -- White background
                red <= '1'; green <= '1'; blue <= '1';
            END IF;
        ELSE
            -- Black outside area
            red <= '0'; green <= '0'; blue <= '0';
        END IF;
    END PROCESS;

    -- Calculate current cell position of the block
    PROCESS(bat_x, bat_y)
        VARIABLE bx, by : INTEGER;
    BEGIN
        bx := TO_INTEGER(UNSIGNED(bat_x));
        by := TO_INTEGER(bat_y);
        cell_row_s <= (by - bat_h) / CELL_SIZE;
        cell_col_s <= (bx - LEFT_PLAY_AREA) / CELL_SIZE;
    END PROCESS;

    landed_row <= STD_LOGIC_VECTOR(TO_UNSIGNED(cell_row_s,4));
    landed_col <= STD_LOGIC_VECTOR(TO_UNSIGNED(cell_col_s,4));

    -- Vertical motion and board update
    move_block : PROCESS
        VARIABLE next_y : INTEGER;
        VARIABLE next_row : INTEGER;
        VARIABLE idx : INTEGER;
    BEGIN
        WAIT UNTIL rising_edge(v_sync);

        IF reset_block = '1' THEN
            -- Reset block to the top
            bat_y <= TO_UNSIGNED(bat_h, 11);
            block_falling <= '1';
        ELSIF block_falling = '1' THEN
            next_y := TO_INTEGER(bat_y) + TO_INTEGER(fall_speed);
            next_row := (next_y - bat_h) / CELL_SIZE;

            IF (next_y + bat_h) >= SCREEN_BOTTOM THEN
                -- Land at bottom
                bat_y <= TO_UNSIGNED(SCREEN_BOTTOM - bat_h, 11);
                block_falling <= '0';

                -- Update board immediately
                IF cell_row_s>=0 AND cell_row_s<ROWS AND cell_col_s>=0 AND cell_col_s<COLS THEN
                    idx := cell_row_s*COLS + cell_col_s;
                    board_reg(idx) <= '1';
                END IF;
            ELSE
                -- Check the cell below
                IF (cell_col_s >=0 AND cell_col_s < COLS AND next_row >=0 AND next_row < ROWS) THEN
                    idx := next_row*COLS + cell_col_s;
                    IF board_reg(idx) = '1' THEN
                        -- Land just above this occupied cell
                        bat_y <= TO_UNSIGNED((cell_row_s*CELL_SIZE)+bat_h, 11);
                        block_falling <= '0';
                        -- Update board immediately
                        idx := cell_row_s*COLS + cell_col_s;
                        board_reg(idx) <= '1';
                    ELSE
                        bat_y <= TO_UNSIGNED(next_y, 11);
                    END IF;
                ELSE
                    bat_y <= TO_UNSIGNED(next_y, 11);
                END IF;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;


