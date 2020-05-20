library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ascon_types.ALL;

entity aead_stream is
    Port (clk: in STD_LOGIC;
          resetn: in STD_LOGIC;

          s_axis_tdata:  in STD_LOGIC_VECTOR(63 downto 0);
          s_axis_tvalid: in STD_LOGIC;
          s_axis_tready: out STD_LOGIC := '0';
          s_axis_tlast:  in STD_LOGIC;

          m_axis_tdata:  out STD_LOGIC_VECTOR(63 downto 0);
          m_axis_tvalid: out STD_LOGIC := '0';
          m_axis_tready: in STD_LOGIC;
          m_axis_tlast:  out STD_LOGIC := '0';

          key: in STD_LOGIC_VECTOR(127 downto 0);
          iv:  in STD_LOGIC_VECTOR(127 downto 0);

          enc_dec:    in STD_LOGIC;
          assoc_data: in STD_LOGIC;
          status:  out STD_LOGIC_VECTOR(3 downto 0);
          decryption_valid:  out STD_LOGIC);
end aead_stream;

architecture Behavioral of aead_stream is
    component ascon_permutation_loop
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;

        state_in : in STD_LOGIC_VECTOR (319 downto 0);
        round_count : in STD_LOGIC_VECTOR (3 downto 0);
        state_out : out STD_LOGIC_VECTOR (319 downto 0);

        start : in STD_LOGIC;
        busy : out STD_LOGIC;
        out_valid : out STD_LOGIC
    );
    end component;

    type AEAD_FSM_STATE is (IDLE, INIT,
        ASSOC_DATA_RECV, ASSOC_DATA_PROC,
        INPUT_DATA_RECV, INPUT_DATA_PROC,
        FINALIZE);
    signal aead_fsm: AEAD_FSM_STATE := IDLE;

    signal reset: STD_LOGIC;

    signal round_count_input: STD_LOGIC_VECTOR (3 downto 0);
    constant round_count_a: STD_LOGIC_VECTOR (3 downto 0) := std_logic_vector(to_unsigned(12, 4));
    constant round_count_b: STD_LOGIC_VECTOR (3 downto 0) := std_logic_vector(to_unsigned(6, 4));

    signal current_state: ASCON_STATE;
    signal new_state: ASCON_STATE;
    signal new_state_vec: STD_LOGIC_VECTOR (319 downto 0);
    signal start_round_update: STD_LOGIC := '0';
    signal round_calculating: STD_LOGIC;
    signal out_valid: STD_LOGIC;
    signal round_done: STD_LOGIC;

    signal next_phase: STD_LOGIC := '0';
begin
    combinational_trivialities: block
    begin
        reset <= not resetn;
        new_state <= vec_to_state(new_state_vec);
        round_done <= out_valid and not start_round_update;
        -- Temp remove
        m_axis_tvalid <= '0';
        --m_axis_tready: in STD_LOGIC;
        decryption_valid <= '0';
    end block combinational_trivialities;
    round_component: ascon_permutation_loop
        port map(
            clk => clk,
            reset => reset,
            state_in => state_to_vec(current_state),
            round_count => round_count_input,
            state_out => new_state_vec,
            start => start_round_update,
            busy => round_calculating,
            out_valid => out_valid
        );
    
    main_fsm: process(clk) is
        variable public_sponge: STD_LOGIC_VECTOR(63 downto 0);
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                aead_fsm <= IDLE;
                s_axis_tready <= '0';
                next_phase <= '0';
            else
                case aead_fsm is
                    when IDLE =>
                        start_round_update <= '0';
                        s_axis_tready <= '0';
                        next_phase <= '0';
                        if s_axis_tvalid = '1' then
                            -- ASCON128 IV_{k,r,a,b}
                            current_state(0) <= x"80400c0600000000";
                            current_state(1) <= key(127 downto 64);
                            current_state(2) <= key(63 downto 0);
                            current_state(3) <= iv(127 downto 64);
                            current_state(4) <= iv(63 downto 0);
                            round_count_input <= round_count_a;
                            start_round_update <= '1';
                            aead_fsm <= INIT;
                        end if;
                    when INIT =>
                        start_round_update <= '0';
                        s_axis_tready <= '0';
                        if round_done = '1' then
                            current_state(0 to 2) <= new_state(0 to 2);
                            current_state(3) <= new_state(3) xor key(127 downto 64);
                            current_state(4) <= new_state(4) xor key(63 downto 0);
                            if assoc_data = '1' then
                                aead_fsm <= ASSOC_DATA_RECV;
                            else
                                current_state(4)(0) <= (not new_state(4)(0)) xor key(0);
                                aead_fsm <= INPUT_DATA_RECV;
                            end if;
                            s_axis_tready <= '1';
                        end if;
                    when ASSOC_DATA_RECV =>
                        round_count_input <= round_count_b;
                        s_axis_tready <= '1';
                        if s_axis_tvalid = '1' then
                            current_state(0) <= current_state(0) xor s_axis_tdata;
                            s_axis_tready <= '0';
                            start_round_update <= '1';
                            next_phase <= s_axis_tlast;
                            aead_fsm <= ASSOC_DATA_PROC;
                        end if;
                    when ASSOC_DATA_PROC =>
                        start_round_update <= '0';
                        if round_done = '1' then
                            current_state(0 to 4) <= new_state(0 to 4);
                            if next_phase = '1' then
                                s_axis_tready <= '1';
                                current_state(4)(0) <= not new_state(4)(0);
                                aead_fsm <= INPUT_DATA_RECV;
                            else
                                s_axis_tready <= '1';
                                aead_fsm <= ASSOC_DATA_RECV;
                            end if;
                        end if;
                    when INPUT_DATA_RECV =>
                        s_axis_tready <= '1';
                        if s_axis_tvalid = '1' then
                            public_sponge := current_state(0) xor s_axis_tdata;
                            if enc_dec = '0' then
                                current_state(0) <= public_sponge;
                            else
                                current_state(0) <= s_axis_tdata;
                            end if;
                            -- TODO properly do M_AXIS protocol
                            m_axis_tdata <= public_sponge;
                            s_axis_tready <= '0';
                            start_round_update <= '1';
                            next_phase <= s_axis_tlast;
                            aead_fsm <= INPUT_DATA_PROC;
                        end if;
                    when INPUT_DATA_PROC =>
                        start_round_update <= '0';
                        if round_done = '1' then
                            current_state(0 to 4) <= new_state(0 to 4);
                            if next_phase = '1' then
                                current_state(1) <= new_state(1) xor key(127 downto 64);
                                current_state(2) <= new_state(2) xor key(63 downto 0);
                                round_count_input <= round_count_a;
                                start_round_update <= '1';
                                aead_fsm <= FINALIZE;
                            else
                                s_axis_tready <= '1';
                                aead_fsm <= INPUT_DATA_RECV;
                            end if;
                        end if;
                    when FINALIZE =>
                        start_round_update <= '0';
                        if round_done = '1' then
                            aead_fsm <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- fpsl assert always (aead_fsm=ASSOC_DATA_PROCESS -> s_axis_tready = '0') @(rising_edge(clk))

    status_mapping: process(aead_fsm) is
    begin
        case aead_fsm is
            when IDLE=>status <= std_logic_vector(to_unsigned(0,4));
            when INIT=>status <= std_logic_vector(to_unsigned(1,4));
            when ASSOC_DATA_RECV=>status <= std_logic_vector(to_unsigned(2,4));
            when ASSOC_DATA_PROC=>status <= std_logic_vector(to_unsigned(2,4));
            when INPUT_DATA_RECV=>status <= std_logic_vector(to_unsigned(3,4));
            when INPUT_DATA_PROC=>status <= std_logic_vector(to_unsigned(3,4));
            when FINALIZE=>status <= std_logic_vector(to_unsigned(4,4));
        end case;
    end process;
end Behavioral;