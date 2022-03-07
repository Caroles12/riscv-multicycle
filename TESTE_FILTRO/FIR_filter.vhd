library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filt is
    generic(
        N_coefficients   : integer := 4; -- Número de coeficientes do filtro.
        N_bits_registers : integer := 4 --Número de bits dos registradores
    );

    port(
        clk     : in  std_logic;
        rst     : in  std_logic;
        datain  : in  signed(N_bits_registers - 1 downto 0);
        dataout : out signed(2 * N_bits_registers - 1 downto 0)
    );
end entity fir_filt;

architecture RTL of fir_filt is
                                    
    type registers is array (N_coefficients - 2 downto 0) of signed(N_bits_registers - 1 downto 0); -- registradores é um array de 3 bits de 4 registradores(1 bit de sinalizaçao).

    type coefficients is array (N_coefficients - 1 downto 0) of signed(N_bits_registers - 1 downto 0); --coeficientes é um array de 4 bits de 4 registradores.

    signal reg : registers;

    constant coef : coefficients := ("0001", "0010", "0011", "0100"); -- 1,2,3,4

   -----------------Sinais para debbugar ----------------------------------------
    signal coeficientes  : coefficients;
    signal registradores : registers;

    signal produto : signed(2 * N_bits_registers - 1 downto 0);
    signal soma    : signed(2 * N_bits_registers - 1 downto 0);
    --y[0] = 1 * 0 = 0
    --y[1] = y[0] + y[1] = 0 + 2*3 = 6
    --y[2] = y[0] + y[1] + y[2] = 0 + 6 + 3*2 = 12
    --y[3] = y[0] + y[1] + y[2] + y[3] = 0 + 6 + 6 + 4*1 = 16
    
 ------------------------------------------------------------------------------------

begin
    process(clk, rst)
        variable sum, prod : signed(2 * N_bits_registers - 1 downto 0) := (others => '0'); -- produto e somador tem um tamanho de 8 posiçoes.
        variable sign      : std_logic;  -- Tratamento de overflow
    begin
        if rst = '1' then
            for i in N_coefficients - 2 downto 0 loop     -- Zera todo mundo.
                for j in N_bits_registers - 1 downto 0 loop
                    reg(i)(j) <= '0';
                end loop;
            end loop;
        elsif rising_edge(clk) then
            coeficientes  <= coef;
            sum          := coef(0) * datain;   -- Primeiro coeficiente -> primeiro parâmetro do somador.
            for i in 1 to N_coefficients - 1 loop  
                sign    := sum (2 * N_bits_registers - 1); --Sign recebe a ultima posição da soma.
                prod    := coef(i) * reg(N_coefficients - 1 - i); -- coef(1) * reg(2)  // coef(2) * reg(1)  // coef(3) *
                sum     := sum + prod;
                produto <= prod;
                soma    <= sum;
                if (sign = prod(prod'left)) AND (sum(sum'left) /= sign) then
                    sum := (sum'left => sign, others => not sign);
                end if;
            end loop;
            reg           <= datain & reg(N_coefficients- 2 downto 1); -- datain & reg(3 downto 0);
            --registradores <= reg;
        end if;
        dataout <= sum;

    end process;

end architecture RTL;
