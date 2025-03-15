vlib work 
vlog Spartan.v InstaSpartan.v spi_wrapper.v Spartan_tb.v
vsim -voptargs=+acc work.Spartan_tb.v
add wave*
run -all
quit -sim
