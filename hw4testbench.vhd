library ieee;
use ieee.std_logic_1164.all;

entity hw4testbench is
end hw4testbench;

architecture behavior of hw4testbench is

  signal clk_sig : std_logic := '0';
  signal rst_sig : std_logic := '0';
  signal left_sig,right_sig,haz_sig,brake_sig : std_logic;
  constant Tperiod : time := 10 ns;
  
  begin
  
    process(clk_sig)
      begin
        clk_sig <= not clk_sig after Tperiod/2;
    end process;
  
  rst_sig <= '0', '1' after 2 ns, '0' after 4 ns;
  
  left_sig <= '0', '1' after 20 ns, '0' after 100 ns;
  
  right_sig <= '0', '1' after 100 ns, '0' after 200 ns;
  
  haz_sig <= '0', '1' after 200 ns;
                    
      
    -- this is the component instantiation for the
    -- DUT - the device we are testing
    DUT : entity work.hw4(behavior)
      port map(clk => clk_sig, rst => rst_sig,
               left => left_sig, right => right_sig,
               haz => haz_sig, brake => brake_sig);

    
end behavior;