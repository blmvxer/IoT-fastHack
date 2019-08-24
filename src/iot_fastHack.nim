import terminal, net, random, strutils, os, streams

var
  serVer: string
  sock = newSocket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
  attempts = 0
  found = 0
  port = ""
  output = ""

proc genAddr(): string =
  randomize()
  var
    ip0 = rand(1..255)
    ip1 = rand(255)
    ip2 = rand(255)
    ip3 = rand(255)
  attempts = attempts + 1
  return (join([$ip0, $ip1, $ip2, $ip3], "."))

proc sockSSH(host: string): string =
  try:
    var
      stream = newFileStream(output, fmWrite)
      ipServ = join([host, ":", port, "  - ", serVer])
    sock.connect(host, Port(parseInt(port)), 250)
    serVer = recvLine(sock, 250)
    found = found + 1
    stream.write(ipServ & "\n")
    stream.close()
    sock.close()
    return serVer
  except:
    sock.close()
    discard

try:
  if paramCount() > 0:
    case paramStr(1):
      of "-p":
        port = paramStr(2)
      else:
        echo "missing -p"
    case paramStr(3):
      of "-o":
        output = paramStr(4)
      else:
        quit(1)
except:
  quit(1)

while true:
  var host = genAddr()
  discard sockSSH(host)
  echo """
  # IoT fastHack v0.1
  # IP: $#                Service Version: $#
  # Attempts Completed: $#        Found: $#
""" % [join([host, ":", port]), serVer, $attempts, $found]
  eraseScreen()
  setCursorPos(0, 0)