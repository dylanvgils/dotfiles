// Toggles the Caps Lock state through the IOHIDSystem service.
import IOKit
import IOKit.hidsystem

func fail(_ message: String, _ result: kern_return_t) -> Never {
  fputs("toggle-caps-lock: \(message) (\(result))\n", stderr)
  exit(1)
}

let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(kIOHIDSystemClass))
if service == 0 {
  fputs("toggle-caps-lock: IOHIDSystem service not found\n", stderr)
  exit(1)
}

var connect: io_connect_t = 0
let openResult = IOServiceOpen(service, mach_task_self_, UInt32(kIOHIDParamConnectType), &connect)
IOObjectRelease(service)
if openResult != KERN_SUCCESS {
  fail("cannot open IOHIDSystem", openResult)
}
defer { IOServiceClose(connect) }

var state = false
let getResult = IOHIDGetModifierLockState(connect, Int32(kIOHIDCapsLockState), &state)
if getResult != KERN_SUCCESS {
  fail("cannot read Caps Lock state", getResult)
}

let setResult = IOHIDSetModifierLockState(connect, Int32(kIOHIDCapsLockState), !state)
if setResult != KERN_SUCCESS {
  fail("cannot set Caps Lock state", setResult)
}
