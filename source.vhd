library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;

        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic;

        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end project_reti_logiche;

architecture behavioral of project_reti_logiche is
    type S is (WAIT_START, READ_CHANNEL, READ_W, ASK_MEM, SAVE_DATA, PRINT);
    signal curr_state: S;
    signal channel : std_logic_vector(1 downto 0);
    signal addr : std_logic_vector(15 downto 0) := (others => '0');
    signal data_reg : std_logic_vector(31 downto 0) := (others => '0');
    constant GROUND : std_logic_vector(7 downto 0) := (others => '0');
    begin
        o_mem_we <= '0';
        fsm : process(i_clk, i_rst)
        begin
            o_mem_en<= '1';
            o_z0 <= GROUND;
            o_z1 <= GROUND;
            o_z2 <= GROUND;
            o_z3 <= GROUND;
            o_done <= '0';
            if i_rst = '1' then
                curr_state <= WAIT_START;
            elsif rising_edge(i_clk) then
                case curr_state is
                    when WAIT_START =>
                        if i_start = '1' then
                            channel(1) <= i_w;
                            addr <= GROUND & GROUND;
                            curr_state <= READ_CHANNEL;
                        end if;
                    when READ_CHANNEL => 
                        channel(0) <= i_w;
                        curr_state <= READ_W;
                    when READ_W =>
                        if i_start = '1' then
                            addr <= addr (14 downto 0) & i_w;
                        elsif i_start = '0' then
                            o_mem_addr <= addr;
                            curr_state <= ASK_MEM;
                        end if;
                    when ASK_MEM =>
                        curr_state <= SAVE_DATA;
                    when SAVE_DATA => 
                        curr_state <= PRINT;
                    when PRINT => 
                        o_z0 <= data_reg(31 downto 24);
                        o_z1 <= data_reg(23 downto 16);
                        o_z2 <= data_reg(15 downto 8);
                        o_z3 <= data_reg(7 downto 0);
                        o_done <= '1';
                        curr_state <= WAIT_START;
                    end case;
                end if;
            end process;

        data_reg_proc : process(i_clk, i_rst, curr_state)
                begin  
                if rising_edge (i_clk) then
                 if i_rst = '1' then      
                        data_reg <= GROUND & GROUND & GROUND & GROUND;
                    end if;  
                 if curr_state = SAVE_DATA then
                     case channel is
                        when "00" => 
                            data_reg(31 downto 24) <= i_mem_data;
                        when "01" => 
                            data_reg(23 downto 16) <= i_mem_data;
                        when "10" => 
                            data_reg(15 downto 8) <= i_mem_data;
                        when "11" => 
                            data_reg(7 downto 0) <= i_mem_data;
                        when others =>
                    end case;
                end if;
              end if;
            end process;
    end architecture;