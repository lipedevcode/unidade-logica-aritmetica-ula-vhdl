--código do circuito em vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ULA is
    Port ( --portas logicas
        A, B          : in  std_logic_vector(3 downto 0);
        Shift		  : in  std_logic;
        Clock         : in  std_logic;
        Result        : out std_logic_vector(3 downto 0); 
        Overflow      : out std_logic;
        OpSelect      : in  std_logic_vector(2 downto 0)   
    );
end ULA;

architecture TypeArchitecture of ULA is --descreve o comportamento do circuito
begin 
	process(A, B, Shift, Clock, OpSelect) --função process define as ações sequenciais do circuito, dentro do parametro, estão as entradas que serão utilizadas para definir uma ação
		variable temp_result : std_logic_vector(3 downto 0); -- variaveis auxiliares
		variable temp_overflow : std_logic;
		variable aux_result : std_logic_vector(3 downto 0);
		
	begin
		case OpSelect is --seletor de operações
			when "000" => --soma
				temp_result := std_logic_vector(unsigned(A) + unsigned(B)); 
				if to_integer(unsigned(A)) + to_integer(unsigned(B)) > 15 then --soma de a e b > 1111
					temp_overflow := '1';
				else 
					temp_overflow := '0';
				end if;
			when "001" => --subtração
				if unsigned(A) < unsigned(B) then
					temp_result := std_logic_vector(unsigned(B) - unsigned(A));
					temp_overflow := '1'; --sinal negativo
				else
					temp_result := std_logic_vector(unsigned(A) - unsigned(B));
					temp_overflow := '0';
				end if;
			when "010" => --and
				temp_result := A AND B;
				temp_overflow := '0';
			when "011" => --or
				temp_result := A OR B;
				temp_overflow := '0';
			when "100" => --not (porta A)
				temp_result := NOT A;
				temp_overflow := '0';
			when "101" => --deslocamento à esquerda (porta A)
				if Shift = '1' then
					if aux_result = "UUUU" then --inicializa variaveis auxiliares, caso estejam undefined.
						aux_result := A(3 downto 0);
						temp_result := A(3 downto 0);
					end if;
					if rising_edge(Clock) then --clock borda de subida
						for i in 0 to 2 loop
							temp_result(i+1) := aux_result(i);
						end loop;
						temp_result(0) := '0';
					else
						aux_result := temp_result(3 downto 0); --atualizo a variavel aux_result para um possivel proximo deslocamento
					end if;
				else
					temp_result := A(3 downto 0);
					aux_result := "UUUU";
				end if;
			when "110" => --deslocamento à direita
				if Shift = '1' then
					if aux_result = "UUUU" then
						aux_result := A(3 downto 0);
						temp_result := A(3 downto 0);
					end if;
					if rising_edge(CLock) then
						for i in 0 to 2 loop
							temp_result(2-i) := aux_result(3-i);
						end loop;
						temp_result(3) := '0';
					else
						aux_result := temp_result(3 downto 0);
					end if;
				else
					temp_result := A(3 downto 0);
					aux_result := "UUUU";
				end if;
			when others => --para valores que não sejam igual a nenhum dos códigos de operação
				temp_result :=(others => '0');
		end case;
		Result <= temp_result (3 downto 0);
		Overflow <= temp_overflow;
		
	end process;
end TypeArchitecture;
