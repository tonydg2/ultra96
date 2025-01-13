#!/usr/bin/env python3
import vitis

client = vitis.create_client()

workspacePath = "../workspace0"
sourceDir = "../src"
client.set_workspace(path=workspacePath)

platform = client.create_platform_component(name = "u96_platform",hw = "../../output_products/top_io.xsa",os = "standalone",cpu = "psu_cortexa53_0")
platform = client.get_platform_component(name="u96_platform")
domain = platform.get_domain(name="zynqmp_fsbl")
status = domain.set_config(option = "os", param = "standalone_stdin", value = "psu_uart_1")
status = domain.set_config(option = "os", param = "standalone_stdout", value = "psu_uart_1")
domain = platform.get_domain(name="standalone_psu_cortexa53_0")
status = domain.set_config(option = "os", param = "standalone_stdin", value = "psu_uart_1")
status = domain.set_config(option = "os", param = "standalone_stdout", value = "psu_uart_1")
status = platform.build()

platform_xpmf = client.get_platform("u96_platform")
comp = client.create_app_component(name="hello_world",platform = platform_xpmf,domain = "standalone_psu_cortexa53_0")
comp = client.get_component(name="hello_world")
status = comp.import_files(from_loc=sourceDir, files=["helloworld.c", "helpFunctions.c", "helpFunctions.h", "platform.c", "platform.h"], dest_dir_in_cmp = "src")
comp.build()

#comp = client.create_app_component(name="mcdma_ex",platform = platform_xpmf,domain = "standalone_psu_cortexa53_0")
#comp = client.get_component(name="mcdma_ex")
#status = comp.import_files(from_loc=sourceDir, files=["helpFunctions.c", "helpFunctions.h", "mcdma_polled_adg.c"], dest_dir_in_cmp = "src")
#comp.build()
#
#comp = client.create_app_component(name="mcdma_custm",platform = platform_xpmf,domain = "standalone_psu_cortexa53_0")
#comp = client.get_component(name="mcdma_custm")
#status = comp.import_files(from_loc=sourceDir, files=["helpFunctions.c", "helpFunctions.h", "mcdma_custom.c"], dest_dir_in_cmp = "src")
#comp.build()


vitis.dispose()

