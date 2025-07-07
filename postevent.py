import fdb

connect = fdb.connect(
    dsn="192.168.0.252:/home/dados/newcotex/sprcom.fb",
    user="SYSDBA",
    password="masterkey"
)

event_nomes = ["cp_pedido", "tnfitnfsa", "tnfcanfsa"]

try:
    while True:
        eventos = connect.event_conduit(event_nomes)
        eventos.begin()
        result = eventos.wait()
        eventos.close()

        for nome, event in result.items():
            if event > 0:
                print(f"realtime/firebird/{nome} firebird/{nome}", flush=True)

except KeyboardInterrupt:
    if 'eventos' in locals():
        eventos.close()

finally:
    connect.close()
    print("connect.close\n", flush=True)
