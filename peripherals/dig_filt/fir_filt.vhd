library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filt is
    generic(
        MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10"; -- ver depois
        MY_WORD_ADDRESS   : unsigned(15 downto 0)        := x"00D0"; -- ver depois
        DADDRESS_BUS_SIZE : integer                      := 32; -- Tamanho
        N_coefficients    : integer                      := 4; --
        N_bits_registers  : integer                      := 32 --
    );

    port(
        clk            : in  std_logic;
        rst            : in  std_logic;
        -- datain   : in  signed(N_bits_registers - 1 downto 0);
        --dataout  : out signed(2 * N_bits_registers - 1 downto 0);
        -- Core data bus signals
        -- ToDo: daddress shoud be unsgined
        daddress       : in  unsigned(DADDRESS_BUS_SIZE - 1 downto 0);
        ddata_w        : in  std_logic_vector(31 downto 0);
        ddata_r        : out std_logic_vector(31 downto 0);
        d_we           : in  std_logic;
        d_rd           : in  std_logic;
        dcsel          : in  std_logic_vector(1 downto 0); --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask          : in  std_logic_vector(3 downto 0); --! Byte enable mask

       -- data_in_enable : out std_logic;
        data_out       : out signed(2 * N_bits_registers - 1 downto 0);
        -- hardware input/output signals    
        data_in        : in  std_logic_vector(N_bits_registers - 1 downto 0)
    );
end entity fir_filt;

architecture RTL of fir_filt is

    type registers is array (N_coefficients - 2 downto 0) of signed(N_bits_registers - 1 downto 0); -- registradores ï¿½ um array de 3 bits de 4 registradores(1 bit de sinalizaï¿½ao).

    -- type coefficients is array (N_coefficients - 1 downto 0) of signed(N_bits_registers - 1 downto 0); --coeficientes ï¿½ um array de 4 bits de 4 registradores.

    -- Build a 2-D array type for the RAM
    subtype word_t is std_logic_vector(31 downto 0);
    type memory_t is array (0 to 3) of word_t;

    signal reg : registers;

    --signal coef : coefficients;

    signal coef : memory_t;

    signal data_ena : std_logic_vector(31 downto 0);

    signal data_reset : std_logic_vector(31 downto 0);

    signal data_out_c : signed(2 * N_bits_registers - 1 downto 0);

    signal load_coef : std_logic_vector(3 downto 0);
    -- signal data_out : signed(N_bits_registers - 1 downto 0);

begin
   -- data_in_enable <= data_ena(0);
    data_ena(0)    <= load_coef(0) and load_coef(1) and load_coef(2) and load_coef(3);
    data_out       <= data_out_c;
    -- Process give input value -- processo leitura barramento Barramento
    leitura_de_barramento : process(clk, rst)
    begin
        if rst = '1' then               --! Significa q eu nï¿½o vou fazer nada;
            --data_ena   <= (others => '0');
            data_reset <= (others => '0');
            load_coef  <= (others => '0');
        else

            if rising_edge(clk) then
                if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = (MY_WORD_ADDRESS) then
                        --data_ena <= ddata_w;
                        coef(0)      <= ddata_w;
                        load_coef(0) <= '1';
                    --data_ena <= ddata_w;
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS) + 1 then -- O MY WORD ï¿½ A ORDEM DOS DADOS NA STRUCT.
                        --data_reset <= ddata_w;
                        coef(1)      <= ddata_w;
                        load_coef(1) <= '1';
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS) + 2 then -- RECEBENDO OS COEFICIENTES
                        --coef(0) <= signed(ddata_w);
                        --coef(0) <= ddata_w;
                        coef(2)      <= ddata_w;
                        load_coef(2) <= '1';
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS) + 3 then
                        --coef(1) <= signed(ddata_w);
                        --coef(1) <= ddata_w;
                        coef(3)      <= ddata_w;
                        load_coef(3) <= '1';
                        --  elsif daddress(15 downto 0) = (MY_WORD_ADDRESS) + 4 then
                        --coef(2) <= signed(ddata_w);
                        --    coef(2) <= ddata_w;
                        -- elsif daddress(15 downto 0) = (MY_WORD_ADDRESS) + 5 then
                        --coef(3) <= signed(ddata_w);
                        --coef(3) <= ddata_w;
                    end if;
                end if;
            end if;
        end if;
    end process;

    FIR_filter : process(clk, rst)
        variable sum, prod : signed(2 * N_bits_registers - 1 downto 0) := (others => '0'); -- produto e somador tem um tamanho de 8 posiï¿½oes.
        --variable sum, prod : signed(N_bits_registers - 1 downto 0) := (others => '0');
        variable sign      : std_logic; -- Tratamento de overflow
    begin
        if rst = '1' then
            for i in N_coefficients - 2 downto 0 loop -- Zera todo mundo.
                for j in N_bits_registers - 1 downto 0 loop
                    reg(i)(j) <= '0';
                end loop;
            end loop;
        elsif rising_edge(clk) then
            --equaçao:
            -- y[0] = coef(0)*datain(0) = 0
            -- y[1] = coef(0)*datain(1) + coef(1)*datain(0) = 4*5 + 3*0 = 20
            -- y[2] = coef(0)*datain(2) + coef(1)*datain(1) + coef(0)*datain(0) = 4*-6 + 3*5 + 4*0= -9
            -- y[3] = coef(0)*datain(3) + coef(1)*datain(2) + coef(2)*datain(1) + coef(3)*datain(0) = -12
            if data_ena(0) = '1' then
                -- sum := coef(0) * signed(data_in);    -- Primeiro coeficiente -> primeiro parï¿½metro do somador.
                sum := signed(coef(0)) * signed(data_in);
                for i in 1 to N_coefficients - 1 loop
                    sign := sum(2 * N_bits_registers - 1); --Sign recebe a ultima posiï¿½ï¿½o da soma.
                    prod := signed(coef(i)) * reg(N_coefficients - 1 - i); -- coef(1) * reg(2)  // coef(2) * reg(1)  // coef(3) *
                    -- y[1] = coef(0)*datain(1) + coef(1)*datain(0)
                    sum  := sum + prod;
                    if (sign = prod(prod'left)) AND (sum(sum'left) /= sign) then
                        sum := (sum'left => sign, others => not sign);
                    end if;
                end loop;
                reg <= signed(data_in) & reg(N_coefficients - 2 downto 1);
            end if;
        end if;
        data_out_c <= sum;
    end process;

    escrita_de_barramento : process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0'); -- Zera a leitura dos dados
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then --VER
                    if daddress(15 downto 0) = MY_WORD_ADDRESS then -- core reading DIG_FILT_CTRL
                        --ddata_r <= data_ena;
                    elsif daddress(15 downto 0) = MY_WORD_ADDRESS + 4 then -- core reading DIG_FILT_IN
                        ddata_r <= std_logic_vector(data_out_c(31 downto 0));
                    elsif daddress(15 downto 0) = MY_WORD_ADDRESS + 5 then -- core reading DIG_FILT_OUT
                        ddata_r <= std_logic_vector(data_out_c(63 downto 32));  --fazer em funçao do tamanho da palavra
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture RTL;
