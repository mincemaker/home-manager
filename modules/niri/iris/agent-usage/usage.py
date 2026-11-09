#!/usr/bin/env python3
import json, subprocess, sys, threading, urllib.request
from datetime import datetime
from pathlib import Path


def claude():
  token = json.loads((Path.home() / ".claude/.credentials.json").read_text())["claudeAiOauth"]["accessToken"]
  req = urllib.request.Request("https://api.anthropic.com/api/oauth/usage", headers={
    "Authorization": "Bearer " + token,
    "anthropic-beta": "oauth-2025-04-20",
  })
  data = json.load(urllib.request.urlopen(req, timeout=10))
  def win(key):
    b = data.get(key) or {}
    if b.get("utilization") is None:
      return None
    reset = b.get("resets_at")
    return {"percent": float(b["utilization"]),
            "resetsAt": int(datetime.fromisoformat(reset).timestamp()) if reset else None}
  return {"session": win("five_hour"), "week": win("seven_day")}


def codex():
  proc = subprocess.Popen(["codex", "app-server"], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                          stderr=subprocess.DEVNULL, text=True)
  watchdog = threading.Timer(15, proc.kill)
  watchdog.daemon = True
  watchdog.start()
  try:
    def send(msg):
      proc.stdin.write(json.dumps(msg) + "\n")
      proc.stdin.flush()
    def wait(id_):
      for line in proc.stdout:
        msg = json.loads(line)
        if msg.get("id") == id_:
          if "error" in msg:
            raise RuntimeError(msg["error"].get("message", "rpc error"))
          return msg["result"]
      raise RuntimeError("codex app-server exited")
    send({"id": 1, "method": "initialize", "params": {"clientInfo": {"name": "inir-agent-usage", "version": "1"}}})
    wait(1)
    send({"method": "initialized", "params": {}})
    send({"id": 2, "method": "account/rateLimits/read", "params": {}})
    limits = wait(2)["rateLimits"]
  finally:
    proc.kill()
  def win(w):
    return {"percent": float(w["usedPercent"]), "resetsAt": w.get("resetsAt")} if w else None
  return {"session": win(limits.get("primary")), "week": win(limits.get("secondary"))}


out = {}
for name, fn in (("claude", claude), ("codex", codex)):
  try:
    out[name] = fn()
  except Exception as e:
    out[name] = {"error": f"{type(e).__name__}: {e}"}
json.dump(out, sys.stdout)
