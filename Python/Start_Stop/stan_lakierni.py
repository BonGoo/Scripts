import EasyMCP2221

# Inicjalizacja MCP2221
mcp = EasyMCP2221.Device()
mcp.set_pin_function(gp1="GPIO_IN")

def odczytaj_stan():
    inputs = mcp.GPIO_read()  # Odczyt stanu wszystkich pinów GPIO
    gp_state = inputs[1]
    return gp_state
