-------------------------------------------------------
--! @file
--! @brief RISCV Testbench
--         This testbench simulates a core with a 
--         generic IO hardware and a Timer     
--
-------------------------------------------------------

  
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--use work.decoder_types.all;


-------------------------------------
ENTITY tb_fir IS
     generic(
        N_coefficients: integer := 4 ;
        N_bits_registers : integer := 4
    );
END ENTITY tb_fir;
------------------------------


ARCHITECTURE logic OF tb_fir IS
    
    -- declaraÃ§Ã£o de sinais
    signal datain : signed (N_bits_registers-1 downto 0);
    signal clk  : std_logic;
    signal rst  : std_logic;
    signal dataout : signed (2*N_bits_registers-1 downto 0);
    
BEGIN  -- inicio do corpo da arquitetura
    dut:  entity work.fir_filt
            generic map(
                N_coefficients => N_coefficients ,
                N_bits_registers => N_bits_registers
            )
            port map (
            clk => clk,
            rst => rst,
            datain => datain,
            dataout => dataout         
            );
         
        --! gera uma forma de onda repetitiva e regular: clocks   
        process
        begin
            clk <= '0';
            wait for 10 ns;
            clk <= '1'; 
            wait for 10 ns;  
        end process;
        
        process
        begin 
            rst <= '1';
            wait for 20 ns;
            rst<='0';
            datain <= to_signed(0,datain'length);
            wait for 20 ns; --! Não pode deixar esses caras em fase (COM CLOCK DE NAO PODE DEIXAR O DADO DE ENTRADA E SAÍDA EM FASE NA MESMA BORDA)
            --rst <= '0';
            datain <= to_signed(5,datain'length);
            wait for 20 ns; -- p/ testar a maxima prioridade do sclr_n
            --rst <= '0';
            datain <= to_signed(-6,datain'length);
            wait for 20 ns;
            --rst <= '0';
            datain <= to_signed(-1,datain'length);
            wait for 20 ns;  
        end process;
    
               
END ARCHITECTURE logic;





