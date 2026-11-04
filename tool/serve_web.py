"""Local static SPA server for checking Flutter path URLs; not a production backend."""
import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


class SpaHandler(SimpleHTTPRequestHandler):
    def translate_path(self, path):
        resolved = Path(super().translate_path(path))
        if not resolved.exists() and not resolved.suffix:
            return str(Path(self.directory) / "index.html")
        return str(resolved)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=8158)
    parser.add_argument("--directory", default="build/web")
    args = parser.parse_args()
    directory = str(Path(args.directory).resolve())
    if not (Path(directory) / "index.html").exists():
        parser.error("Build the web app first: fvm flutter build web")
    server = ThreadingHTTPServer(("127.0.0.1", args.port), partial(SpaHandler, directory=directory))
    print(f"Serving {directory} at http://127.0.0.1:{args.port}", flush=True)
    server.serve_forever()
