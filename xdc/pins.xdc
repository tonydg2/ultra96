#--------------------------------------------------------------------------------------------------

# click mezz slot1
set_property PACKAGE_PIN F8 [get_ports {UART0_TX_O}];#  HD_GPIO_2 pin7
set_property PACKAGE_PIN F7 [get_ports {UART0_RX_I}];#  HD_GPIO_1 pin5

#set_property PACKAGE_PIN A7 [get_ports {RST1_O}];#  HD_GPIO_7
#set_property PACKAGE_PIN A6 [get_ports {PWM1_O}];#  HD_GPIO_6
set_property PACKAGE_PIN G6 [get_ports {INT1_I}];#  HD_GPIO_8


# click mezz slot2
set_property PACKAGE_PIN G5 [get_ports {UART1_RX_I}];#  HD_GPIO_4
set_property PACKAGE_PIN F6 [get_ports {UART1_TX_O}];#  HD_GPIO_5

#set_property PACKAGE_PIN B6 [get_ports {RST2_O}];#  HD_GPIO_14
#set_property PACKAGE_PIN C7 [get_ports {PWM2_O}];#  HD_GPIO_13
#set_property PACKAGE_PIN C5 [get_ports {INT2_O}];#  HD_GPIO_15


#--------------------------------------------------------------------------------------------------
#set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]

#--------------------------------------------------------------------------------------------------
# BANK 65
#--------------------------------------------------------------------------------------------------
#set_property PACKAGE_PIN F4 [get_ports {FAN_PWM         }];#  
##                                                          #  
#set_property PACKAGE_PIN M1 [get_ports {CSI0_D1_N       }];#  
#set_property PACKAGE_PIN M2 [get_ports {CSI0_D1_P       }];#  
#set_property PACKAGE_PIN N4 [get_ports {CSI0_D0_N       }];#  
#set_property PACKAGE_PIN N5 [get_ports {CSI0_D0_P       }];#  
#set_property PACKAGE_PIN P1 [get_ports {CSI0_C_N        }];#  
#set_property PACKAGE_PIN N2 [get_ports {CSI0_C_P        }];#  
##                                                          #  
#set_property PACKAGE_PIN U1 [get_ports {CSI1_D1_N       }];#  
#set_property PACKAGE_PIN U2 [get_ports {CSI1_D1_P       }];#  
#set_property PACKAGE_PIN R3 [get_ports {CSI1_D0_N       }];#  
#set_property PACKAGE_PIN P3 [get_ports {CSI1_D0_P       }];#  
#set_property PACKAGE_PIN C2 [get_ports {HSIC_DATA       }];#  
##                                                          #  
#set_property PACKAGE_PIN C3 [get_ports {DSI_D3_N        }];#  
#set_property PACKAGE_PIN D3 [get_ports {DSI_D3_P        }];#  
#set_property PACKAGE_PIN D1 [get_ports {DSI_D2_N        }];#  
#set_property PACKAGE_PIN E1 [get_ports {DSI_D2_P        }];#  
#set_property PACKAGE_PIN E3 [get_ports {DSI_D1_N        }];#  
#set_property PACKAGE_PIN E4 [get_ports {DSI_D1_P        }];#  
#set_property PACKAGE_PIN T2 [get_ports {CSI1_C_N        }];#  
#set_property PACKAGE_PIN T3 [get_ports {CSI1_C_P        }];#  
#set_property PACKAGE_PIN F1 [get_ports {DSI_D0_N        }];#  
#set_property PACKAGE_PIN G1 [get_ports {DSI_D0_P        }];#  
##                                                          #  
#set_property PACKAGE_PIN H5 [get_ports {DSI_CLK_N       }];#  
#set_property PACKAGE_PIN J5 [get_ports {DSI_CLK_P       }];#  
##                                                          #  
#set_property PACKAGE_PIN L1 [get_ports {CSI0_D3_N       }];#  
#set_property PACKAGE_PIN L2 [get_ports {CSI0_D3_P       }];#  
#set_property PACKAGE_PIN M4 [get_ports {CSI0_D2_N       }];#  
#set_property PACKAGE_PIN M5 [get_ports {CSI0_D2_P       }];#  
##                                                          #  
##--------------------------------------------------------------------------------------------------
## BANK 26
##--------------------------------------------------------------------------------------------------
#set_property PACKAGE_PIN A6 [get_ports {HD_GPIO_6       }];#  
#set_property PACKAGE_PIN B7 [get_ports {BT_HCI_RTS      }];#  
#set_property PACKAGE_PIN B5 [get_ports {BT_HCI_CTS      }];#  
#set_property PACKAGE_PIN B6 [get_ports {HD_GPIO_14      }];#  
#set_property PACKAGE_PIN A7 [get_ports {HD_GPIO_7       }];#  
##                                                          #  
set_property PACKAGE_PIN A9 [get_ports {RADIO_LED[0]    }];#  D9 = Orange/Yellow
set_property PACKAGE_PIN B9 [get_ports {RADIO_LED[1]    }];#  D10 = BLUE
#set_property PACKAGE_PIN C7 [get_ports {HD_GPIO_13      }];#  
##                                                          #  
#set_property PACKAGE_PIN C5 [get_ports {HD_GPIO_15      }];#  
#set_property PACKAGE_PIN D5 [get_ports {HD_GPIO_12      }];#  
#set_property PACKAGE_PIN D8 [get_ports {CSI1_MCLK       }];#  
#set_property PACKAGE_PIN E8 [get_ports {CSI0_MCLK       }];#  
#set_property PACKAGE_PIN D6 [get_ports {HD_GPIO_11      }];#  
#set_property PACKAGE_PIN D7 [get_ports {HD_GPIO_0       }];#  
#set_property PACKAGE_PIN F7 [get_ports {HD_GPIO_2       }];#  
#set_property PACKAGE_PIN F8 [get_ports {HD_GPIO_1       }];#  
#set_property PACKAGE_PIN E5 [get_ports {HD_GPIO_10      }];#  
#set_property PACKAGE_PIN E6 [get_ports {HD_GPIO_9       }];#  
#set_property PACKAGE_PIN F6 [get_ports {HD_GPIO_4       }];#  
#set_property PACKAGE_PIN G7 [get_ports {HD_GPIO_3       }];#  
#set_property PACKAGE_PIN G5 [get_ports {HD_GPIO_5       }];#  
#set_property PACKAGE_PIN G6 [get_ports {HD_GPIO_8       }];#  
#--------------------------------------------------------------------------------------------------
# BANK 66
#--------------------------------------------------------------------------------------------------
#set_property PACKAGE_PIN A2   [get_ports {HSIC_STR      }];

#--------------------------------------------------------------------------------------------------
# IOSTANDARD
#--------------------------------------------------------------------------------------------------

#bank 26  = VCCAUX      = 1.8V
#bank 65  = VCCO_HP     = 1.2V
#bank 66  = bank 65
#bank 500 = VCC_PSAUX   = 1.8V
#bank 501 = VCC_PSAUX   = 1.8V
#bank 502 = VCC_PSAUX   = 1.8V
#bank 503 = VCC_PSAUX   = 1.8V
#bank 504 = VCCO_PSDDR  = 1.1V

set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 26]];
set_property IOSTANDARD LVCMOS12 [get_ports -of_objects [get_iobanks 65]];
set_property IOSTANDARD LVCMOS12 [get_ports -of_objects [get_iobanks 66]];
