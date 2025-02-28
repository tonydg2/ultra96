onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /msk_tb/msk_demodulator_inst/clk
add wave -noupdate /msk_tb/msk_demodulator_inst/data_out
add wave -noupdate -expand -group mod /msk_tb/msk_modulator_inst/data_in
add wave -noupdate -expand -group mod /msk_tb/msk_modulator_inst/dbg_phase_step
add wave -noupdate -expand -group mod -format Analog-Step -height 84 -max 32767.0 -min -32767.0 -radix decimal /msk_tb/msk_modulator_inst/i_o
add wave -noupdate -expand -group mod -format Analog-Step -height 84 -max 32767.0 -min -32767.0 -radix decimal /msk_tb/msk_modulator_inst/q_o
add wave -noupdate -expand -group mod -radix unsigned /msk_tb/msk_modulator_inst/phase_step_low
add wave -noupdate -expand -group mod -radix unsigned /msk_tb/msk_modulator_inst/phase_step_high
add wave -noupdate -expand -group mod -radix unsigned -childformat {{{/msk_tb/msk_modulator_inst/phase_acc[31]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[30]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[29]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[28]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[27]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[26]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[25]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[24]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[23]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[22]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[21]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[20]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[19]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[18]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[17]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[16]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[15]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[14]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[13]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[12]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[11]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[10]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[9]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[8]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[7]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[6]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[5]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[4]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[3]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[2]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[1]} -radix unsigned} {{/msk_tb/msk_modulator_inst/phase_acc[0]} -radix unsigned}} -subitemconfig {{/msk_tb/msk_modulator_inst/phase_acc[31]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[30]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[29]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[28]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[27]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[26]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[25]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[24]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[23]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[22]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[21]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[20]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[19]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[18]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[17]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[16]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[15]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[14]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[13]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[12]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[11]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[10]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[9]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[8]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[7]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[6]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[5]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[4]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[3]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[2]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[1]} {-radix unsigned} {/msk_tb/msk_modulator_inst/phase_acc[0]} {-radix unsigned}} /msk_tb/msk_modulator_inst/phase_acc
add wave -noupdate /msk_tb/msk_modulator_inst/FREQ_DEV_REAL
add wave -noupdate -group iq2REAL -format Analog-Step -height 84 -max 32766.0 -min -32767.0 -radix decimal /msk_tb/iq_to_real_inst/real_o
add wave -noupdate -group real2IQ -format Analog-Step -height 84 -max 13125.0 -min -13126.0 -radix decimal /msk_tb/real_to_iq_inst/i_out
add wave -noupdate -group real2IQ -format Analog-Step -height 84 -max 13116.999999999998 -min -16384.0 -radix decimal /msk_tb/real_to_iq_inst/q_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1539375 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 274
configure wave -valuecolwidth 190
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
WaveRestoreZoom {0 ps} {5250 ns}
