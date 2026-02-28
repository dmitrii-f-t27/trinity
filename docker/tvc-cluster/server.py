#!/usr/bin/env python3
import os
import json
from http.server import HTTPServer, BaseHTTPRequestHandler

class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            node_id = os.environ.get("TRINITY_NODE_ID", "unknown")
            role = os.environ.get("TRINITY_NODE_ROLE", "unknown")
            response = {
                "status": "healthy",
                "node": node_id,
                "role": role,
                "shards": int(os.environ.get("TRINITY_SHARDS", "27")),
                "vectors": 0
            }
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        print(f"[{self.log_date_time_string()}] {format % args}")

if __name__ == "__main__":
    port = 8080
    server = HTTPServer(("0.0.0.0", port), HealthHandler)
    print(f"TVC Node listening on port {port}")
    server.serve_forever()
