library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ascon_types.ALL;

entity tb_aead_stream is
--  Port ( );
end tb_aead_stream;

architecture Behavioral of tb_aead_stream is
    component aead_stream is
        Port (clk: in STD_LOGIC;
          resetn: in STD_LOGIC;

          s_axis_tdata:  in STD_LOGIC_VECTOR(63 downto 0);
          s_axis_tvalid: in STD_LOGIC;
          s_axis_tready: out STD_LOGIC;
          s_axis_tlast:  in STD_LOGIC;

          m_axis_tdata:  out STD_LOGIC_VECTOR(63 downto 0);
          m_axis_tvalid: out STD_LOGIC;
          m_axis_tready: in STD_LOGIC;
          m_axis_tlast:  out STD_LOGIC;

          key:    in STD_LOGIC_VECTOR(127 downto 0);
          iv:     in STD_LOGIC_VECTOR(127 downto 0);
          enc_dec:in STD_LOGIC;
          assoc_data:in STD_LOGIC;
          status: out STD_LOGIC_VECTOR(3 downto 0);
          decryption_valid:  out STD_LOGIC);
    end component;

    signal clk: STD_LOGIC;
    signal resetn: STD_LOGIC;
    signal s_axis_tdata: STD_LOGIC_VECTOR(63 downto 0);
    signal s_axis_tvalid: STD_LOGIC;
    signal s_axis_tready: STD_LOGIC;
    signal s_axis_tlast: STD_LOGIC;

    signal m_axis_tdata:  STD_LOGIC_VECTOR(63 downto 0);
    signal m_axis_tvalid: STD_LOGIC;
    signal m_axis_tready: STD_LOGIC;
    signal m_axis_tlast:  STD_LOGIC;

    signal key:    STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
    signal iv:     STD_LOGIC_VECTOR(127 downto 0) := (others => '0');

    signal enc_dec: STD_LOGIC := '0';
    signal assoc_data: STD_LOGIC := '1';
    signal status:  STD_LOGIC_VECTOR(3 downto 0);
    signal decryption_valid: STD_LOGIC;
begin
    DUT: aead_stream
    port map (
        clk => clk,
        resetn => resetn,
        s_axis_tdata => s_axis_tdata,
        s_axis_tvalid => s_axis_tvalid,
        s_axis_tready => s_axis_tready,
        s_axis_tlast => s_axis_tlast,
        m_axis_tdata => m_axis_tdata,
        m_axis_tvalid => m_axis_tvalid,
        m_axis_tready => m_axis_tready,
        m_axis_tlast => m_axis_tlast,
        key => key,
        iv => iv,
        enc_dec => enc_dec,
        assoc_data => assoc_data,
        status => status,
        decryption_valid => decryption_valid
    );
    clk_gen: process is
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;
    reset_gen: process is
    begin
        resetn <= '0';
        wait for 20 ns;
        resetn <= '1';
        wait;
    end process;

    m_axis_tready <= '1';

    main: process is
    begin
        s_axis_tdata <= (0 => '1', others => '0');
        s_axis_tvalid <= '0';
        s_axis_tlast <= '0';
        wait until resetn = '1';
        wait until rising_edge(clk);
        s_axis_tvalid <= '1';
        wait until s_axis_tready = '1';
        wait until rising_edge(clk);
        s_axis_tvalid <= '0';

        wait until s_axis_tready = '1';
        s_axis_tdata <= (1 => '1', others => '0');
        s_axis_tvalid <= '1';
        s_axis_tlast <= '1';
        wait until rising_edge(clk);
        s_axis_tvalid <= '0';
        s_axis_tlast <= '0';

        wait until s_axis_tready = '1';
        s_axis_tdata <= (2 => '1', others => '0');
        s_axis_tvalid <= '1';
        wait until rising_edge(clk);
        s_axis_tvalid <= '0';

        wait until s_axis_tready = '1';
        s_axis_tdata <= (3 => '1', others => '0');
        s_axis_tvalid <= '1';
        s_axis_tlast <= '1';
        wait until rising_edge(clk);
        s_axis_tvalid <= '0';
        s_axis_tlast <= '0';
        wait;
    end process;
end Behavioral;
