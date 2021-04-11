library IEEE;
use IEEE.std_logic_1164.all;

ENTITY hw4 is
  PORT(clk           : IN  std_logic;
       rst           : IN  std_logic;
       left          : IN std_logic;
       right         : IN std_logic;
       haz           : in std_logic;
	   brake		 : in std_logic;
       left_tail_lt  : OUT std_logic_vector(3 downto 1);
       right_tail_lt : OUT std_logic_vector(1 to 3));
END hw4;

ARCHITECTURE behavior OF hw4 IS

  TYPE state_type IS (IDLE, LR3, L1, L2, L3, R1, R2, R3, BREAKON, bl1,bl2,bl3,br1,br2,br3,bleftidle,brightidle);
  SIGNAL present_state, next_state : state_type;
  CONSTANT leftoff : std_logic_vector(3 downto 1) := "000";
  CONSTANT left1on : std_logic_vector(3 downto 1) := "001";
  CONSTANT left2on : std_logic_vector(3 downto 1) := "011";
  CONSTANT left3on : std_logic_vector(3 downto 1) := "111";
  CONSTANT rightoff : std_logic_vector(3 downto 1) := "000";
  CONSTANT right1on : std_logic_vector(3 downto 1) := "100";
  CONSTANT right2on : std_logic_vector(3 downto 1) := "110";
  CONSTANT right3on : std_logic_vector(3 downto 1) := "111";

BEGIN

 clocked : PROCESS(clk,rst)
   BEGIN
     IF(rst='1') THEN 
       present_state <= idle;
    ELSIF(rising_edge(clk)) THEN
      present_state <= next_state;
    END IF;  
 END PROCESS clocked;
 
 nextstate : PROCESS(present_state,left,right,haz,brake)
  BEGIN
     CASE present_state IS
	 --used to make sure the sequentially blinking still has an idle phase where the light is off
	 --after the 3rd light is done flashing. to exactly mimic the sequential blinking as before.
	   WHEN bleftidle =>
		 IF(brake = '0') then
			next_state <= L1;
		 ELSIF(left = '1') then
			next_state <= bl1;
		 ELSIF(right = '1') then
			next_state <= br1;
		 ELSE
			next_state <= BREAKON;
		 end if;
	   WHEN brightidle =>
		 IF(brake = '0') then
			next_state <= R1;
		 ELSIF(left = '1') then
			next_state <= bl1;
		 ELSIF(right = '1') then
			next_state <= br1;
		 ELSE
			next_state <= BREAKON;
		 end if;
		 
		 ----------------------------------------------------------------
	   WHEN BREAKON =>
		 IF(brake = '0') then
			next_state <= idle;
		 ELSIF(left = '1') then
			next_state <= bl1;
		 ELSIF(right = '1') then
			next_state <= br1;
		 ELSE
			next_state <= BREAKON;
		end if;
		--cases for when break is on with a left turning light
	   WHEN bl1 =>
		IF(brake = '0')then
			next_state <= L2;
        ELSE			
			next_state <= bl2;
		end if;
	   When bl2 =>
	    IF(brake = '0')then
			next_state <= L3;
        ELSE			
			next_state <= bl3;
		end if;
	   WHEN bl3 =>
		IF(brake = '0')then
			next_state <= idle;
        ELSE			
			next_state <= bleftidle;
		end if;		
		--cases for when a break is on with a right turninglight
	   WHEN br1 =>
	    IF(brake = '0')then
			next_state <= R2;
        ELSE			
			next_state <= br2;
		end if;
	   WHEN br2 =>
	    IF(brake = '0')then
			next_state <= R3;
        ELSE			
			next_state <= br3;
		end if;
	   WHEN br3 =>
	    IF(brake = '0')then
			next_state <= idle;
        ELSE			
			next_state <= brightidle;
		end if;
	   --same statemachine as example 38, with a break check added into each case.
       WHEN idle =>
	     IF(brake = '1') then
			next_state <= BREAKON;
         ELSIF(haz = '1'OR (left = '1' AND right = '1')) THEN
           next_state <= LR3;
         ELSIF(left = '1') THEN
           next_state <= L1;
         ELSIF(right = '1') THEN
           next_state <= R1;
         ELSE
           next_state <= idle;
         END IF;
       WHEN LR3 =>
	     IF(brake = '1') then
			next_state <= BREAKON;
		 else
            next_state <= idle;
		 end if;		 
       WHEN L1 =>
	     IF(brake = '1') then
			next_state <= BREAKON;
         ELSIF(haz = '1') THEN
           next_state <= LR3;
         ELSE
           next_state <= L2;
         END IF;
       WHEN L2 =>
	     IF(brake = '1') then
			next_state <= BREAKON;
         ELSIF(haz = '1') THEN
           next_state <= LR3;
         ELSE
           next_state <= L3;
         END IF;
       WHEN L3 =>
	     IF(brake = '1') then
			next_state <= BREAKON;
		 else
            next_state <= idle;
		 end if;
       WHEN R1 =>
	     IF(brake = '1') then
			next_state <= BREAKON;
         ELSIF(haz = '1') THEN
           next_state <= LR3;
         ELSE
           next_state <= R2;
         END IF;
       WHEN R2 =>
	     IF(brake = '1') then
			next_state <= BREAKON;
         ELSIF(haz = '1') THEN
           next_state <= LR3;
         ELSE
           next_state <= R3;
         END IF;
       WHEN R3 =>
	     IF(brake = '1') then
			next_state <= BREAKON;
		 else
         next_state <= idle;
		 end if;
    END CASE;
  END PROCESS nextstate;

  output : PROCESS(present_state)
   BEGIN
     CASE present_state IS
	   WHEN BREAKON =>
		 left_tail_lt <= left3on;
		 right_tail_lt <= right3on;
	   WHEN bl1 =>
		 left_tail_lt <= left1on;
		 right_tail_lt <= right3on;
	   WHEN bl2 =>
		 left_tail_lt <= left2on;
		 right_tail_lt <= right3on;
	   WHEN bl3 =>
		 left_tail_lt <= left3on;
		 right_tail_lt <= right3on;
	   WHEN bleftidle =>
		 left_tail_lt <= leftoff;
		 right_tail_lt <= right3on;
	   WHEN br1 =>
		 left_tail_lt <= left3on;
		 right_tail_lt <= right1on;
	    WHEN br2 =>
		 left_tail_lt <= left3on;
		 right_tail_lt <= right2on;
	   WHEN br3 =>
		 left_tail_lt <= left3on;
		 right_tail_lt <= right3on;
	   WHEN brightidle =>
		 left_tail_lt <= left3on;
		 right_tail_lt <= rightoff;
       WHEN idle =>
         left_tail_lt <= leftoff;
         right_tail_lt <= rightoff;
       WHEN LR3 =>
         left_tail_lt <= left3on;
         right_tail_lt <= right3on;
       WHEN L1 =>
         left_tail_lt <= left1on;
         right_tail_lt <= rightoff;
       WHEN L2 =>
         left_tail_lt <= left2on;
         right_tail_lt <= rightoff;
       WHEN L3 =>
         left_tail_lt <= left3on;
         right_tail_lt <= rightoff;
       WHEN R1 =>
         left_tail_lt <= leftoff;
         right_tail_lt <= right1on;
       WHEN R2 =>
         left_tail_lt <= leftoff;
         right_tail_lt <= right2on;
       WHEN R3 =>
         left_tail_lt <= leftoff;
         right_tail_lt <= right3on;
     END CASE;
 END PROCESS output;
 
END ARCHITECTURE behavior;