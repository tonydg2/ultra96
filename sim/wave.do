onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /led_cnt_tb/led_cnt/clk100
add wave -noupdate /led_cnt_tb/led_cnt/CNT_1S
add wave -noupdate /led_cnt_tb/led_cnt/div_i
add wave -noupdate /led_cnt_tb/led_cnt/led_o
add wave -noupdate /led_cnt_tb/led_cnt/led_int_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1999207 ps} 0}
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
WaveRestoreZoom {1999050 ps} {2000050 ps}
