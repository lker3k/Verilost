	component vga is
		port (
			clk_clk                 : in  std_logic                     := 'X';             -- clk
			end_p_end_p             : in  std_logic                     := 'X';             -- end_p
			face_select_face_select : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- face_select
			filter_mode_filter_mode : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- filter_mode
			in_data_in_data         : in  std_logic_vector(11 downto 0) := (others => 'X'); -- in_data
			mic_en_mic_en           : in  std_logic                     := 'X';             -- mic_en
			reset_reset_n           : in  std_logic                     := 'X';             -- reset_n
			start_p_start_p         : in  std_logic                     := 'X';             -- start_p
			vga_CLK                 : out std_logic;                                        -- CLK
			vga_HS                  : out std_logic;                                        -- HS
			vga_VS                  : out std_logic;                                        -- VS
			vga_BLANK               : out std_logic;                                        -- BLANK
			vga_SYNC                : out std_logic;                                        -- SYNC
			vga_R                   : out std_logic_vector(7 downto 0);                     -- R
			vga_G                   : out std_logic_vector(7 downto 0);                     -- G
			vga_B                   : out std_logic_vector(7 downto 0);                     -- B
			vga_face_0_reset_reset  : in  std_logic                     := 'X';             -- reset
			vga_ready_vga_ready     : out std_logic;                                        -- vga_ready
			pitch_pitch             : in  std_logic_vector(15 downto 0) := (others => 'X')  -- pitch
		);
	end component vga;

	u0 : component vga
		port map (
			clk_clk                 => CONNECTED_TO_clk_clk,                 --              clk.clk
			end_p_end_p             => CONNECTED_TO_end_p_end_p,             --            end_p.end_p
			face_select_face_select => CONNECTED_TO_face_select_face_select, --      face_select.face_select
			filter_mode_filter_mode => CONNECTED_TO_filter_mode_filter_mode, --      filter_mode.filter_mode
			in_data_in_data         => CONNECTED_TO_in_data_in_data,         --          in_data.in_data
			mic_en_mic_en           => CONNECTED_TO_mic_en_mic_en,           --           mic_en.mic_en
			reset_reset_n           => CONNECTED_TO_reset_reset_n,           --            reset.reset_n
			start_p_start_p         => CONNECTED_TO_start_p_start_p,         --          start_p.start_p
			vga_CLK                 => CONNECTED_TO_vga_CLK,                 --              vga.CLK
			vga_HS                  => CONNECTED_TO_vga_HS,                  --                 .HS
			vga_VS                  => CONNECTED_TO_vga_VS,                  --                 .VS
			vga_BLANK               => CONNECTED_TO_vga_BLANK,               --                 .BLANK
			vga_SYNC                => CONNECTED_TO_vga_SYNC,                --                 .SYNC
			vga_R                   => CONNECTED_TO_vga_R,                   --                 .R
			vga_G                   => CONNECTED_TO_vga_G,                   --                 .G
			vga_B                   => CONNECTED_TO_vga_B,                   --                 .B
			vga_face_0_reset_reset  => CONNECTED_TO_vga_face_0_reset_reset,  -- vga_face_0_reset.reset
			vga_ready_vga_ready     => CONNECTED_TO_vga_ready_vga_ready,     --        vga_ready.vga_ready
			pitch_pitch             => CONNECTED_TO_pitch_pitch              --            pitch.pitch
		);

