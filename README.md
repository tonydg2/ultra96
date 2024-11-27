# ultra96

#### ClickMezz - LCD mini Click on Slot1 
HW / connection modification necessary. Digi-pot controlled by CS2 on LCD mini click board
"AN" pin on mikrobus. The AN pin is not connected/accessable on u96. Connected with external wire
pin26 of 40pinHDR on ClickMezz(SPI0_CS1), this is CS for slot2 on ClickMezz, connected to AN pin of slot1.

(u96 SPI0 CS1) MIO40_PS_GPIO1_3 --> 40pinHDR pin26 --> AN pin MIKROBUS1 --> CS2 digi-pot LCD mini click