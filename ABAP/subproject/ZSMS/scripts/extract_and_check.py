import pyrfc
import json

def get_conns():
    conn_dev = pyrfc.Connection(ashost="192.168.2.8", sysnr="00", client="130", user="TRSTDEV", passwd="ronin03")
    conn_s4 = pyrfc.Connection(ashost="192.168.1.199", sysnr="01", client="130", user="TRSTABAP", passwd="supporter")
    return conn_dev, conn_s4

def main():
    conn_dev, conn_s4 = get_conns()
    
    # 1. System info
    info_dev = conn_dev.call("RFC_SYSTEM_INFO")["RFCSI_EXPORT"]
    info_s4 = conn_s4.call("RFC_SYSTEM_INFO")["RFCSI_EXPORT"]
    print(f"DEV System: SID={info_dev.get('RFCSYSID')}, Release={info_dev.get('RFCSAPRL')}, DB={info_dev.get('RFCDBSYS')}, Host={info_dev.get('RFCHOST')}")
    print(f"S4  System: SID={info_s4.get('RFCSYSID')}, Release={info_s4.get('RFCSAPRL')}, DB={info_s4.get('RFCDBSYS')}, Host={info_s4.get('RFCHOST')}")

    # 2. Read TSTC & TSTCT for ZSMS in DEV
    tcode_data = conn_dev.call("RFC_READ_TABLE", QUERY_TABLE="TSTC", OPTIONS=[{"TEXT": "TCODE = 'ZSMS'"}])
    print("TSTC Dev:", tcode_data.get("DATA"))
    
    ttext_data = conn_dev.call("RFC_READ_TABLE", QUERY_TABLE="TSTCT", OPTIONS=[{"TEXT": "TCODE = 'ZSMS'"}])
    print("TSTCT Dev:", ttext_data.get("DATA"))

    # 3. Read Program ZSMS source from DEV
    prog_data = conn_dev.call("RPY_PROGRAM_READ", PROGRAM_NAME="ZSMS")
    source_lines = [line["LINE"] for line in prog_data.get("SOURCE_EXTENDED", [])]
    if not source_lines:
        source_lines = [line["LINE"] for line in prog_data.get("SOURCE", [])]
    print(f"Program ZSMS lines in DEV: {len(source_lines)}")

    with open("/data/Projects/SAP/ABAP/subproject/ZSMS/src/ZSMS.abap", "w") as f:
        f.write("\n".join(source_lines))
    print("Saved source to subproject/ZSMS/src/ZSMS.abap")

    # 4. Read text pool
    try:
        tpool = conn_dev.call("RS_TEXTPOOL_READ", OBJECT_NAME="ZSMS", ACTION="P")
        print("Textpool entries:", len(tpool.get("TEXTPOOL", [])))
        for t in tpool.get("TEXTPOOL", []):
            print("  ", t)
    except Exception as e:
        print("RS_TEXTPOOL_READ error:", e)

    # 5. Check if ZSMS exists in S4
    tcode_s4 = conn_s4.call("RFC_READ_TABLE", QUERY_TABLE="TSTC", OPTIONS=[{"TEXT": "TCODE = 'ZSMS'"}])
    prog_s4 = conn_s4.call("RFC_READ_TABLE", QUERY_TABLE="TRDIR", OPTIONS=[{"TEXT": "NAME = 'ZSMS'"}])
    print("S4 TSTC ZSMS:", tcode_s4.get("DATA"))
    print("S4 TRDIR ZSMS:", prog_s4.get("DATA"))

if __name__ == "__main__":
    main()