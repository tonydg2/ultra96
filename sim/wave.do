onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /spi_tb/spi2/csn_i
add wave -noupdate /spi_tb/spi/sclk_i
add wave -noupdate /spi_tb/spi/mosi_i
add wave -noupdate /spi_tb/spi/miso_o
add wave -noupdate -label miso_o2 /spi_tb/spi2/miso_o
add wave -noupdate -label miso_o3 /spi_tb/spi3/miso_o
add wave -noupdate -label miso_o4 /spi_tb/spi4/miso_o
add wave -noupdate -divider spi
add wave -noupdate -expand -group spi /spi_tb/spi/SPI_SM
add wave -noupdate -expand -group spi -radix unsigned -childformat {{{/spi_tb/spi/bit_idx[2]} -radix unsigned} {{/spi_tb/spi/bit_idx[1]} -radix unsigned} {{/spi_tb/spi/bit_idx[0]} -radix unsigned}} -subitemconfig {{/spi_tb/spi/bit_idx[2]} {-radix unsigned} {/spi_tb/spi/bit_idx[1]} {-radix unsigned} {/spi_tb/spi/bit_idx[0]} {-radix unsigned}} /spi_tb/spi/bit_idx
add wave -noupdate -expand -group spi /spi_tb/spi/opcode
add wave -noupdate -expand -group spi /spi_tb/spi/opcode_done
add wave -noupdate -expand -group spi /spi_tb/spi/addr
add wave -noupdate -expand -group spi /spi_tb/spi/addr_done
add wave -noupdate -expand -group spi /spi_tb/spi/data_rcv
add wave -noupdate -expand -group spi /spi_tb/spi/data_rcv_done
add wave -noupdate -expand -group spi2 /spi_tb/spi2/SPI_STATE
add wave -noupdate -expand -group spi2 -radix unsigned /spi_tb/spi2/bit_idx
add wave -noupdate -expand -group spi2 /spi_tb/spi2/opcode
add wave -noupdate -expand -group spi2 /spi_tb/spi2/opcode_done
add wave -noupdate -expand -group spi2 /spi_tb/spi2/addr
add wave -noupdate -expand -group spi2 /spi_tb/spi2/addr_done
add wave -noupdate -expand -group spi2 /spi_tb/spi2/data_rcv
add wave -noupdate -expand -group spi2 /spi_tb/spi2/data_rcv_done
add wave -noupdate -group spi3 /spi_tb/spi3/spi_sm
add wave -noupdate -group spi3 /spi_tb/spi3/bit_idx
add wave -noupdate -group spi3 /spi_tb/spi3/opcode
add wave -noupdate -group spi3 /spi_tb/spi3/opcode_done
add wave -noupdate -group spi3 /spi_tb/spi3/addr
add wave -noupdate -group spi3 /spi_tb/spi3/addr_done
add wave -noupdate -group spi3 /spi_tb/spi3/data_rcv
add wave -noupdate -group spi3 /spi_tb/spi3/data_rcv_done
add wave -noupdate -group spi4 /spi_tb/spi4/spi_state
add wave -noupdate -group spi4 /spi_tb/spi4/bit_idx
add wave -noupdate -group spi4 /spi_tb/spi4/opcode
add wave -noupdate -group spi4 /spi_tb/spi4/opcode_done
add wave -noupdate -group spi4 /spi_tb/spi4/addr
add wave -noupdate -group spi4 /spi_tb/spi4/addr_done
add wave -noupdate -group spi4 /spi_tb/spi4/data_rcv
add wave -noupdate -group spi4 /spi_tb/spi4/data_rcv_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {976791 ps} 0}
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
WaveRestoreZoom {0 ps} {5775 ns}
