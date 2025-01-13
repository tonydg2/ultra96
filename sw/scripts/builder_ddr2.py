# 2024-09-01T15:10:21.955192
import vitis

client = vitis.create_client()
client.set_workspace(path="/mnt/TDG_512/projects/1_u96_custom/sw/workspace1")

platform = client.create_platform_component(name = "u96_platform",hw = "/mnt/TDG_512/projects/1_u96_custom/output_products/top_io.xsa",os = "standalone",cpu = "psu_cortexa53_0")

platform = client.get_platform_component(name="u96_platform")
status = platform.build()

comp = client.create_app_component(name="zynqmp_dram_test",platform = "/mnt/TDG_512/projects/1_u96_custom/sw/workspace1/u96_platform/export/u96_platform/u96_platform.xpfm",domain = "standalone_psu_cortexa53_0",template = "zynqmp_dram_test")

comp = client.get_component(name="zynqmp_dram_test")
comp.build()

domain = platform.get_domain(name="zynqmp_fsbl")

status = domain.set_config(option = "os", param = "standalone_stdin", value = "psu_uart_1")

status = domain.set_config(option = "os", param = "standalone_stdout", value = "psu_uart_1")

domain = platform.get_domain(name="standalone_psu_cortexa53_0")

status = domain.set_config(option = "os", param = "standalone_stdin", value = "psu_uart_1")

status = domain.set_config(option = "os", param = "standalone_stdout", value = "psu_uart_1")

status = platform.build()

comp.build()

client.delete_component(name="zynqmp_dram_test")

client.delete_platform_component(name="u96_platform")

platform = client.create_platform_component(name = "platform_1600",hw = "/mnt/TDG_512/projects/1_u96_custom/output_products_1600/top_io.xsa",os = "standalone",cpu = "psu_cortexa53_0")

platform = client.get_platform_component(name="platform_1600")
domain = platform.get_domain(name="zynqmp_fsbl")

status = domain.set_config(option = "os", param = "standalone_stdin", value = "psu_uart_1")

status = domain.set_config(option = "os", param = "standalone_stdout", value = "psu_uart_1")

domain = platform.get_domain(name="standalone_psu_cortexa53_0")

status = domain.set_config(option = "os", param = "standalone_stdin", value = "psu_uart_1")

status = domain.set_config(option = "os", param = "standalone_stdout", value = "psu_uart_1")

platform = client.create_platform_component(name = "platform_1066",hw = "/mnt/TDG_512/projects/1_u96_custom/output_products_ORIGINAL_1066/top_io.xsa",os = "standalone",cpu = "psu_cortexa53_0")

platform = client.get_platform_component(name="platform_1066")
domain = platform.get_domain(name="zynqmp_fsbl")

status = domain.set_config(option = "os", param = "standalone_stdin", value = "psu_uart_1")

status = domain.set_config(option = "os", param = "standalone_stdout", value = "psu_uart_1")

domain = platform.get_domain(name="standalone_psu_cortexa53_0")

status = domain.set_config(option = "os", param = "standalone_stdin", value = "psu_uart_1")

status = domain.set_config(option = "os", param = "standalone_stdout", value = "psu_uart_1")

status = platform.build()

platform = client.get_platform_component(name="platform_1600")
status = platform.build()

comp = client.create_app_component(name="zynqmp_dram_test_1600",platform = "/mnt/TDG_512/projects/1_u96_custom/sw/workspace1/platform_1600/export/platform_1600/platform_1600.xpfm",domain = "standalone_psu_cortexa53_0",template = "zynqmp_dram_test")

comp = client.get_component(name="zynqmp_dram_test_1600")
comp.build()

comp = client.create_app_component(name="zynqmp_dram_test_1066",platform = "/mnt/TDG_512/projects/1_u96_custom/sw/workspace1/platform_1066/export/platform_1066/platform_1066.xpfm",domain = "standalone_psu_cortexa53_0",template = "zynqmp_dram_test")

comp = client.get_component(name="zynqmp_dram_test_1066")
comp.build()

comp = client.create_app_component(name="memory_tests_1600",platform = "/mnt/TDG_512/projects/1_u96_custom/sw/workspace1/platform_1600/export/platform_1600/platform_1600.xpfm",domain = "standalone_psu_cortexa53_0",template = "memory_tests")

comp = client.get_component(name="memory_tests_1600")
comp.build()

platform = client.create_platform_component(name = "platform_1866",hw = "/mnt/TDG_512/projects/1_u96_custom/output_products_1866/top_io.xsa",os = "standalone",cpu = "psu_cortexa53_0")

platform = client.get_platform_component(name="platform_1866")
domain = platform.get_domain(name="zynqmp_fsbl")

status = domain.set_config(option = "os", param = "standalone_stdin", value = "psu_uart_1")

status = domain.set_config(option = "os", param = "standalone_stdout", value = "psu_uart_1")

domain = platform.get_domain(name="standalone_psu_cortexa53_0")

status = domain.set_config(option = "os", param = "standalone_stdin", value = "psu_uart_1")

status = domain.set_config(option = "os", param = "standalone_stdout", value = "psu_uart_1")

comp = client.create_app_component(name="zynqmp_dram_test_1866",platform = "/mnt/TDG_512/projects/1_u96_custom/sw/workspace1/platform_1866/export/platform_1866/platform_1866.xpfm",domain = "standalone_psu_cortexa53_0",template = "zynqmp_dram_test")

status = platform.build()

comp = client.get_component(name="zynqmp_dram_test_1866")
comp.build()

comp = client.create_app_component(name="ddr_bw_1866",platform = "/mnt/TDG_512/projects/1_u96_custom/sw/workspace1/platform_1866/export/platform_1866/platform_1866.xpfm",domain = "standalone_psu_cortexa53_0",template = "hello_world")

comp = client.get_component(name="ddr_bw_1866")
status = comp.import_files(from_loc="/mnt/TDG_512/projects/1_u96_custom/sw/src", files=["helloworld.c", "helpFunctions.c", "helpFunctions.h"], dest_dir_in_cmp = "src")

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

vitis.dispose()

