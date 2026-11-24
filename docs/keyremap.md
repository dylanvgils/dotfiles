# Debugging keyremap
This page lists commands to debug the macOS key remapping, see the [README](../README.md#6-macos-key-remapping).

```sh
# Connected keyboards with their VendorID and ProductID
hidutil list

# Stored mappings per keyboard (also shown when Input Monitoring is missing)
hidutil property --match '{"Built-In":true}' --get UserKeyMapping | head -20
hidutil property --match '{"VendorID":0x46d}' --get UserKeyMapping

# LaunchAgent state and errors
launchctl print gui/$(id -u)/local.keyremap.builtin
launchctl print gui/$(id -u)/local.keyremap.logitech
cat /tmp/local.keyremap.*.err
```

## Input Monitoring
The built-in keyboard mapping only works when `/usr/bin/hidutil` has Input Monitoring. Without it, `hidutil` exits 0 and stores the mapping, but the keys don't change. The Logitech mapping works without it.