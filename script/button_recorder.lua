
function gpioOpen(port)
  gpioExport = io.open('/sys/class/gpio/export', 'w')
  gpioExport:write(port)
  gpioExport:close()
end

gpioOpen(146)
gpioOpen(147)
gpioOpen(175)
gpioOpen(114)



while true do
  gpio147 = io.open('/sys/class/gpio/gpio147/value', 'r')
  b1 = gpio147:read('*number')
  gpio147:close()

  gpio146 = io.open('/sys/class/gpio/gpio146/value', 'r')
  b2 = gpio146:read('*number')
  gpio146:close()

  gpio175 = io.open('/sys/class/gpio/gpio175/value', 'r+')
  b3 = gpio175:read('*number')
  gpio175:close()

  gpio114 = io.open('/sys/class/gpio/gpio114/value', 'r+')
  b4 = gpio114:read('*number')
  gpio114:close()

  butstr = b1..b2..b3..b4
  if butstr ~= '0000' then
    print(butstr)
  end
end

