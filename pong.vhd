LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pong IS
    PORT (
        clk_in : IN STD_LOGIC; 
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); 
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        btnl : IN STD_LOGIC;
        btnr : IN STD_LOGIC;
        btn0 : IN STD_LOGIC;  
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    ); 
END pong;

ARCHITECTURE Behavioral OF pong IS
    SIGNAL pxl_clk : STD_LOGIC := '0';
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);

    SIGNAL S_red, S_green, S_blue : STD_LOGIC; 
    SIGNAL draw_red, draw_green, draw_blue : STD_LOGIC; 

    SIGNAL batpos : STD_LOGIC_VECTOR (10 DOWNTO 0) := std_logic_vector(to_unsigned(400,11)); 
    SIGNAL count : unsigned(20 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL display : std_logic_vector (15 DOWNTO 0);
    SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0);

    CONSTANT LEFT_PLAY_AREA  : INTEGER := 200;
    CONSTANT RIGHT_PLAY_AREA : INTEGER := 600;
    CONSTANT BLOCK_HALF_WIDTH : INTEGER := 20;
    CONSTANT LEFT_BOUND  : INTEGER := LEFT_PLAY_AREA + BLOCK_HALF_WIDTH;  
    CONSTANT RIGHT_BOUND : INTEGER := RIGHT_PLAY_AREA - BLOCK_HALF_WIDTH; 
    CONSTANT MOVE_STEP : INTEGER := 40;
    CONSTANT ROWS : INTEGER := 15;
    CONSTANT COLS : INTEGER := 10;
    CONSTANT CELL_SIZE : INTEGER := 40;

    SIGNAL falling : STD_LOGIC;
    SIGNAL landed_row : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL landed_col : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL btnl_prev, btnr_prev : STD_LOGIC := '0';

    SIGNAL reset_block_sig : STD_LOGIC := '1';  
    SIGNAL was_falling : STD_LOGIC := '0';
    SIGNAL reset_comb : STD_LOGIC;

    SIGNAL block_count : unsigned(3 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL spawn_in_progress : STD_LOGIC := '1'; 

    SIGNAL board_in, board_out : STD_LOGIC_VECTOR(149 DOWNTO 0) := (OTHERS => '0');

    COMPONENT falling_block IS
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
    END COMPONENT;

    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT clk_wiz_0 IS
        PORT (
            clk_in1  : IN std_logic;
            clk_out1 : OUT std_logic
        );
    END COMPONENT;

    COMPONENT leddec16 IS
        PORT (
            dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT; 
BEGIN
    led_mpx <= std_logic_vector(count(19 DOWNTO 17));
    reset_comb <= reset_block_sig OR btn0;

    add_bb : falling_block
    PORT MAP(
        v_sync => S_vsync,
        pixel_row => S_pixel_row,
        pixel_col => S_pixel_col,
        bat_x => batpos,
        reset_block => reset_comb,
        board_in => board_in,
        block_count => std_logic_vector(block_count),
        red => S_red,
        green => S_green,
        blue => S_blue,
        falling => falling,
        landed_row => landed_row,
        landed_col => landed_col,
        board_out => board_out
    );

    board_in <= board_out;

    vga_driver : vga_sync
    PORT MAP(
        pixel_clk => pxl_clk, 
        red_in => (others => draw_red),
        green_in => (others => draw_green),
        blue_in => (others => draw_blue),
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync => VGA_hsync, 
        vsync => S_vsync
    );
    VGA_vsync <= S_vsync;

    clk_wiz_0_inst : clk_wiz_0
    PORT MAP (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );

    led1 : leddec16
    PORT MAP(
      dig => led_mpx, 
      data => display, 
      anode => SEG7_anode, 
      seg => SEG7_seg
    );

    
    PROCESS(S_pixel_col, S_pixel_row, board_out, S_red, S_green, S_blue, falling)
        VARIABLE pcol, prow : INTEGER;
        VARIABLE cell_c, cell_r : INTEGER;
        VARIABLE idx : INTEGER;
    BEGIN
        prow := to_integer(unsigned(S_pixel_row));
        pcol := to_integer(unsigned(S_pixel_col));

        --black backkground
        draw_red   <= '0';
        draw_green <= '0';
        draw_blue  <= '0';

        IF (pcol >= LEFT_PLAY_AREA) AND (pcol < RIGHT_PLAY_AREA) AND (prow < 600) THEN
            -- white gameboard
            draw_red <= '1';
            draw_green <= '1';
            draw_blue <= '1';
            -- drawing placed blocks
            cell_c := (pcol - LEFT_PLAY_AREA)/CELL_SIZE;
            cell_r := prow/CELL_SIZE;
            IF (cell_r >=0 AND cell_r < ROWS AND cell_c>=0 AND cell_c<COLS) THEN
                idx := cell_r*COLS + cell_c;
                IF board_out(idx) = '1' THEN
                    draw_red <= '0';
                    draw_green <= '1';
                    draw_blue <= '1';
                END IF;
            END IF;
        END IF;

        --top boundary line
        IF (pcol >= LEFT_PLAY_AREA AND pcol < RIGHT_PLAY_AREA AND prow = 100) THEN
            draw_red <= '1';
            draw_green <= '0';
            draw_blue <= '0';
        END IF;

        
        IF falling='1' THEN
            IF ((S_red='1' AND S_green='0' AND S_blue='0') OR
                (S_red='0' AND S_green='1' AND S_blue='0')) THEN
                draw_red <= S_red;
                draw_green <= S_green;
                draw_blue <= S_blue;
            END IF;
        END IF;
    END PROCESS;

    pos : PROCESS (clk_in)
        VARIABLE newpos : INTEGER;
    BEGIN
        IF rising_edge(clk_in) THEN
            count <= count + 1;
            -- horizontal movement
            IF falling = '1' THEN
                newpos := to_integer(unsigned(batpos));
                IF (btnl = '1' AND btnl_prev = '0') THEN
                    newpos := newpos - MOVE_STEP;
                ELSIF (btnr = '1' AND btnr_prev = '0') THEN
                    newpos := newpos + MOVE_STEP;
                END IF;

                IF newpos < LEFT_BOUND THEN
                    newpos := LEFT_BOUND;
                ELSIF newpos > RIGHT_BOUND THEN
                    newpos := RIGHT_BOUND;
                END IF;

                batpos <= std_logic_vector(to_unsigned(newpos,11));
            END IF;

            --spawn logic for new block
            IF was_falling='1' AND falling='0' THEN
                reset_block_sig <= '1';
                block_count <= block_count + 1;
                spawn_in_progress <= '1';
            END IF;

            
            IF spawn_in_progress='1' AND falling='1' THEN
                reset_block_sig <= '0';
                spawn_in_progress <= '0';
            END IF;

            was_falling <= falling;
            btnl_prev <= btnl;
            btnr_prev <= btnr;
        END IF;
    END PROCESS;

END Behavioral;

