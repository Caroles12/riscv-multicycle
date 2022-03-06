#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante - Nome do arquivo p/ compilar
vcom FIR_filter.vhd testebenche.vhd

#Simula
vsim -t ns work.tb_fir

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -radix unsigned -label clk /clk 
add wave -radix unsigned -label rst /rst 
add wave -radix signed -label datain /datain
add wave -radix signed -label dataout /dataout 
add wave -label reg /dut/reg
add wave -label coef /dut/coeficientes
add wave -label produto /dut/produto
add wave -label soma /dut/soma

#Simula ate 30ns
run 100ns

wave zoomfull
write wave wave.ps