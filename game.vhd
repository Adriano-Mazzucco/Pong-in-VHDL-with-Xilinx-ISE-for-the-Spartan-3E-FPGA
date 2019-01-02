library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USe IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity game is
	Port ( 
	clk		: in STD_LOGIC;
	H			: out STD_LOGIC;
	V			: out STD_LOGIC;
	DAC_CLK	: out STD_LOGIC;
	Rout		: out STD_LOGIC_VECTOR(7 downto 0);
	Gout		: out STD_LOGIC_VECTOR(7 downto 0);
	Bout		: out STD_LOGIC_VECTOR(7 downto 0);
	SW0		: in STD_LOGIC;
	SW1		: in STD_LOGIC;
	SW2		: in STD_LOGIC;
	SW3		: in STD_LOGIC
	);
end game;

architecture Behavioral of game is
--declaration of all required signals
signal horizontal, vertical, wait1 : Integer := 0;
signal ball_x  : Integer :=312;
signal ball_y : Integer := 232;
signal ball_xmove, ball_ymove : Integer := 2;
signal lefttop, righttop : Integer := 158;
signal clock : std_logic;

BEGIN
--
PROCESS (clk)
BEGIN
	IF (rising_edge(clk)) THEN
		IF (clock = '1') THEN
			clock <= '0';
		ELSE
			clock <= '1';
		END IF;
	END IF;
END PROCESS;
DAC_CLK <= clock;
PROCESS(clock)
BEGIN
-- cycle through pixel on clock rising edge
IF (rising_edge(clock)) THEN
	IF (horizontal = 800) THEN
		vertical <= vertical + 1;
		horizontal <= 0;
	ELSE
		horizontal <= horizontal + 1;
	END IF;	
	IF (vertical = 524) THEN
		vertical <= 0;
	END IF;

	IF (horizontal >= 656 AND horizontal <= 751) THEN
		H <= '0';
	ELSE
		H <= '1'; 
	END IF;
	IF (vertical >= 490 AND vertical <= 491) THEN
		V <= '0'; 
	ELSE
		V <= '1'; 
	END IF;
END IF;
END PROCESS;

PROCESS (clock, horizontal, vertical)
BEGIN

IF (rising_edge(clock)) THEN

	--White border
	if((horizontal > 12 AND horizontal <= 628 AND vertical > 12 AND vertical <= 20)
		OR (horizontal > 12 AND horizontal <= 20 AND vertical > 20 AND vertical <= 96)
		OR (horizontal > 620 AND horizontal <= 628 AND vertical > 20 AND vertical <= 96)
		OR (horizontal > 12 AND horizontal <= 628 AND vertical > 464 AND vertical <= 472)
		OR (horizontal > 12 AND horizontal <= 20 AND vertical > 388 AND vertical <= 472)
		OR (horizontal > 620 AND horizontal <= 628 AND vertical > 388 AND vertical <= 472)) THEN
		ROUT <= "11111111";
		GOUT <= "11111111";
		BOUT <= "11111111";
		
-- Left Paddle
	elsif(horizontal > 44 AND horizontal <=60 AND vertical> lefttop AND vertical<= lefttop + 117) THEN
		ROUT <= "11111111";
		GOUT <= "00000000";
		BOUT <= "11111111";

--	Right paddle
	elsif(horizontal > 580 AND horizontal <=596 AND vertical> righttop AND vertical<= righttop + 117) THEN
		ROUT <= "00000000";
		GOUT <= "11111111";
		BOUT <= "11111111";

-- BALL		
	elsif(horizontal > ball_x AND horizontal <= ball_x+20 AND vertical > ball_y AND vertical <= (ball_y+20)) THEN
		if((ball_x = 36 OR ball_x+20 = 604) AND (ball_y > 90 AND ball_y < 400)) THEN
			ROUT <= "11111111";
			GOUT <= "00000000";
			BOUT <= "00000000";
			if (wait1 = 4000) then
				ball_x <= 312;
				ball_y <= 232;
				wait1 <= 0;
			else 
				wait1 <= wait1 + 1;
			End if;
		else
			ROUT <= "11111111";
			GOUT <= "11111111";
			BOUT <= "11111111";
		end if;

--MIDDLE DASHED LINE		
	elsif(horizontal > 316 AND horizontal <=324
		AND ((vertical>30 AND vertical<=90) 
		OR (vertical>120 AND vertical<=170) 
		OR (vertical>200 AND vertical<=260)
		OR (vertical>290 AND vertical<=350)
		OR (vertical>380 AND vertical<=440))) THEN
			ROUT <= "11111111";
			GOUT <= "11111111";
			BOUT <= "11111111";
	
	-- background
	elsif(horizontal > 0 AND horizontal <= 640 AND vertical > 0 AND vertical <= 480) THEN
		ROUT <= "00000000";
		GOUT <= "00000000";
		BOUT <= "00000000";
	
	END IF;
	
	if(horizontal = 639 AND vertical = 479)THEN

		--ball collision
		if(ball_x <= 20 OR ball_x+20 >= 620) THEN
			if(ball_y > 96 AND ball_y < 388) THEN

			else
				if(ball_x <= 20) THEN
					ball_xmove <= 2;
				else
					ball_xmove <= -2;
				end if;
			end if;
		end if;
				if(ball_y <= 20) THEN
			ball_ymove <= 2;
		end if;
		if(ball_y+20 = 464) THEN
			ball_ymove <= -2;
		end if;
		
		--paddle collision
		if((ball_x <= 60 AND ball_x+20 >=44) AND (ball_y+20 > lefttop AND ball_y < lefttop+117)) THEN
			ball_xmove <= 2;
		end if;
		
		if((ball_x+20 >= 581 AND ball_x<=597) AND(ball_y+20 > righttop AND ball_y < righttop+117)) THEN
			ball_xmove <= -2;
		end if;
		
		-- paddle controls
		if ((SW2 XOR SW3) = '1') then		
			if (SW2 = '1' AND righttop > 37) then 
				righttop <= righttop - 2;
			elsif (SW3 = '1' AND righttop + 117 <= 447) then  
				righttop <= righttop + 2;
			end if;
		end if;
		if ((SW0 XOR SW1) = '1') then		
			if (SW0 = '1' AND lefttop > 37) then 
				lefttop <= lefttop - 2;
			elsif (SW1 = '1' AND lefttop + 117 <= 447) then  
				lefttop <= lefttop + 2;
			end if;
		end if;
		if(NOT((ball_x = 36 OR ball_x+20 = 604) AND (ball_y > 96 AND ball_y < 388))) THEN
			ball_x <= ball_x + ball_xmove;
			ball_y <= ball_y + ball_ymove;
		end if;
	end if;
End IF;
END PROCESS;	
end Behavioral;