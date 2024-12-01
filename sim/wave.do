onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /spi_tb/spi2/csn_i
add wave -noupdate /spi_tb/spi/sclk_i
add wave -noupdate /spi_tb/spi/mosi_i
add wave -noupdate /spi_tb/spi/miso_o
add wave -noupdate -label miso_o2 /spi_tb/spi2/miso_o
add wave -noupdate -divider spi
add wave -noupdate /spi_tb/spi/SPI_SM
add wave -noupdate -radix unsigned /spi_tb/spi/bit_idx
add wave -noupdate /spi_tb/spi/opcode
add wave -noupdate /spi_tb/spi/opcode_done
add wave -noupdate /spi_tb/spi/addr
add wave -noupdate /spi_tb/spi/addr_done
add wave -noupdate /spi_tb/spi/data_rcv
add wave -noupdate /spi_tb/spi/data_rcv_done
add wave -noupdate -divider spi2
add wave -noupdate /spi_tb/spi2/SPI_STATE
add wave -noupdate -radix unsigned /spi_tb/spi2/bit_idx
add wave -noupdate /spi_tb/spi2/opcode
add wave -noupdate /spi_tb/spi2/opcode_done
add wave -noupdate /spi_tb/spi2/addr
add wave -noupdate /spi_tb/spi2/addr_done
add wave -noupdate /spi_tb/spi2/data_rcv
add wave -noupdate /spi_tb/spi2/data_rcv_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {686127 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {4410 ns}
