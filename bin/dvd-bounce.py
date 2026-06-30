#!/usr/bin/env python3
# DVD-bounce for Hyprland. Toggle: shrink+float+bounce the current workspace's
# windows (all forced opaque + shadowed = "focused"), hide the bar only while
# viewing that workspace. Toggle again to restore everything.
import json, subprocess, os, sys, signal, random, time

PIDFILE   = "/tmp/dvd-bounce.pid"
STATEFILE = "/tmp/dvd-bounce-state.json"
BARFILE   = "/tmp/dvd-bounce-bar"
WSFILE    = "/tmp/dvd-bounce-ws"
FPS, SPEED = 30, 8
ACTIVE_SHADOW = "rgba(0d0d0dee)"

def sh(a): return subprocess.run(a, capture_output=True, text=True).stdout
def hj(*c): return json.loads(sh(["hyprctl","-j",*c]) or "[]")
def hd(c):  return json.loads(sh(["hyprctl","-j",c]) or "{}")
def notify(m): subprocess.run(["notify-send","-t","1500"," DVD bounce", m])
def bar_toggle(): subprocess.run(["pkill","-USR1","-x","waybar"])

def restore():
    try: state = json.load(open(STATEFILE))
    except Exception: state = []
    cmds = []
    for w in state.get("wins", []) if isinstance(state, dict) else []:
        a = w["address"]
        cmds.append(f"dispatch setprop address:{a} forceopaque 0")
        if w["floating"]:
            cmds.append(f"dispatch resizewindowpixel exact {w['w']} {w['h']},address:{a}")
            cmds.append(f"dispatch movewindowpixel exact {w['x']} {w['y']},address:{a}")
        else:
            cmds.append(f"dispatch settiled address:{a}")
    cmds.append("keyword decoration:shadow:color_inactive rgba(00000000)")
    if cmds: sh(["hyprctl","--batch",";".join(cmds)])
    # un-hide the bar if it was hidden
    try:
        if open(BARFILE).read().strip() == "1": bar_toggle()
    except Exception: pass
    for f in (STATEFILE, BARFILE, WSFILE):
        try: os.remove(f)
        except Exception: pass

# ---- toggle OFF ----
if os.path.exists(PIDFILE):
    try: os.kill(int(open(PIDFILE).read().strip()), signal.SIGTERM)
    except Exception: pass
    try: os.remove(PIDFILE)
    except Exception: pass
    time.sleep(0.15)
    restore()
    notify("stopped — windows restored")
    sys.exit(0)

open(PIDFILE,"w").write(str(os.getpid()))
def cleanup(*_):
    try: os.remove(PIDFILE)
    except Exception: pass
    sys.exit(0)
signal.signal(signal.SIGTERM, cleanup); signal.signal(signal.SIGINT, cleanup)

mon = next((m for m in hj("monitors") if m.get("focused")), None)
if not mon: cleanup()
MW, MH = mon["width"], mon["height"]
L, T, R, B = mon["reserved"]
X0, Y0, X1, Y1 = L, T, MW-R, MH-B
WSID = mon["activeWorkspace"]["id"]
open(WSFILE,"w").write(str(WSID))
SMALL_W, SMALL_H = int(MW*0.30), int(MH*0.32)

def active():
    return [c for c in hj("clients")
            if c["workspace"]["id"]==WSID and c["mapped"] and not c["hidden"]
            and c["address"] and not c.get("fullscreen")]

ws = active()
if not ws:
    notify("no windows on this workspace"); cleanup()

json.dump({"wins":[{"address":c["address"],"floating":c["floating"],
                    "x":c["at"][0],"y":c["at"][1],"w":c["size"][0],"h":c["size"][1]} for c in ws]},
          open(STATEFILE,"w"))

# float tiled, shrink all, force opaque, give every window a shadow
for c in ws:
    if not c["floating"]:
        sh(["hyprctl","dispatch","togglefloating","address:"+c["address"]])
time.sleep(0.2)
pre = [f"dispatch resizewindowpixel exact {SMALL_W} {SMALL_H},address:{c['address']}" for c in ws]
pre += [f"dispatch setprop address:{c['address']} forceopaque 1" for c in ws]
pre.append(f"keyword decoration:shadow:color_inactive {ACTIVE_SHADOW}")
sh(["hyprctl","--batch",";".join(pre)])
time.sleep(0.15)

def load():
    o = {}
    for c in active():
        if not c["floating"]: continue
        w, h = c["size"]
        o[c["address"]] = {"x":random.uniform(X0,max(X0,X1-w)),"y":random.uniform(Y0,max(Y0,Y1-h)),
                           "w":w,"h":h,"vx":random.choice([-1,1])*SPEED,"vy":random.choice([-1,1])*SPEED}
    return o

W = load()
# bar: we're on the bouncing workspace now -> hide it
bar_hidden = False
def set_bar(hide):
    global bar_hidden
    if hide != bar_hidden:
        bar_toggle(); bar_hidden = hide
        open(BARFILE,"w").write("1" if bar_hidden else "0")
set_bar(True)

notify("started — Super+Shift+D to stop")
frame = 0
while True:
    if frame % 10 == 0:                       # ~3x/sec: bar follows the active workspace
        set_bar(hd("activeworkspace").get("id") == WSID)
    if frame and frame % (FPS*2) == 0:
        cur = load()
        for a, o in cur.items():
            if a in W: o.update(x=W[a]["x"],y=W[a]["y"],vx=W[a]["vx"],vy=W[a]["vy"])
        W = cur
        if not W: cleanup()
    frame += 1
    ad = list(W.keys())
    for a in ad:
        o = W[a]; o["x"]+=o["vx"]; o["y"]+=o["vy"]
        if o["x"]<=X0: o["x"]=X0; o["vx"]=abs(o["vx"])
        if o["x"]+o["w"]>=X1: o["x"]=X1-o["w"]; o["vx"]=-abs(o["vx"])
        if o["y"]<=Y0: o["y"]=Y0; o["vy"]=abs(o["vy"])
        if o["y"]+o["h"]>=Y1: o["y"]=Y1-o["h"]; o["vy"]=-abs(o["vy"])
    for i in range(len(ad)):
        for k in range(i+1,len(ad)):
            a,b = W[ad[i]], W[ad[k]]
            ox = min(a["x"]+a["w"],b["x"]+b["w"]) - max(a["x"],b["x"])
            oy = min(a["y"]+a["h"],b["y"]+b["h"]) - max(a["y"],b["y"])
            if ox>0 and oy>0:
                if ox<oy:
                    a["vx"],b["vx"] = -a["vx"],-b["vx"]; s=ox/2
                    if a["x"]<b["x"]: a["x"]-=s; b["x"]+=s
                    else: a["x"]+=s; b["x"]-=s
                else:
                    a["vy"],b["vy"] = -a["vy"],-b["vy"]; s=oy/2
                    if a["y"]<b["y"]: a["y"]-=s; b["y"]+=s
                    else: a["y"]+=s; b["y"]-=s
    cmds = ";".join(f"dispatch movewindowpixel exact {int(o['x'])} {int(o['y'])},address:{a}" for a,o in W.items())
    if cmds: sh(["hyprctl","--batch",cmds])
    time.sleep(1.0/FPS)
