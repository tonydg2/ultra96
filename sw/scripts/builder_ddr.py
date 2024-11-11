# 2024-09-02T14:34:13.074535
import vitis

client = vitis.create_client()
client.set_workspace(path="/mnt/TDG_512/projects/1_u96_custom/sw/workspace1")

comp = client.get_component(name="ddr_bw_1866")
comp.build()

comp.build()

comp.build()

comp.build()

status = comp.clean()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp = client.create_app_component(name="ddr_bw_1066",platform = "/mnt/TDG_512/projects/1_u96_custom/sw/workspace1/platform_1066/export/platform_1066/platform_1066.xpfm",domain = "standalone_psu_cortexa53_0",template = "hello_world")

comp = client.get_component(name="ddr_bw_1066")
status = comp.import_files(from_loc="/mnt/TDG_512/projects/1_u96_custom/sw/src", files=["helpFunctions.c", "helpFunctions.h"], dest_dir_in_cmp = "src")

comp.build()

