"""Self-heals ~/.drirc's FGO Arcade Mesa driconf override (see the root
README's "GPU compatibility" section) - ago.exe calls NVIDIA-only OpenGL
bindless-buffer extensions, and on a card with native GL_ARB_bindless_texture
support this needs allow_glsl_embedded_structure_declarations or ago.exe
hits a GLSL compile error Mesa rejects by default.

~/.drirc is a system-wide, per-user file that can already hold stanzas for
other games/apps entirely unrelated to this project, so this never
overwrites it wholesale: it parses the existing XML (preserving comments and
every other <device>/<application> entry untouched) and only inserts our own
stanza if an equivalent one isn't already present. A file that doesn't
exist yet is created fresh with just our stanza. A file that exists but
isn't recognizable driconf XML is left alone entirely - never guessed at.

Usage: ensure_drirc.py (no arguments; always targets ~/.drirc)
"""
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

APP_NAME = "FGO Arcade"
APP_EXECUTABLE = "ago.exe"
OPTION_NAME = "allow_glsl_embedded_structure_declarations"
OPTION_VALUE = "true"


def _has_our_stanza(root):
    for application in root.iter("application"):
        if application.get("name") == APP_NAME and application.get("executable") == APP_EXECUTABLE:
            return True
    return False


def _new_stanza():
    device = ET.Element("device")
    application = ET.SubElement(device, "application", {"name": APP_NAME, "executable": APP_EXECUTABLE})
    ET.SubElement(application, "option", {"name": OPTION_NAME, "value": OPTION_VALUE})
    return device


def main():
    path = Path.home() / ".drirc"

    if not path.is_file():
        root = ET.Element("driconf")
        root.append(_new_stanza())
        tree = ET.ElementTree(root)
        ET.indent(tree, space="    ")
        path.write_text(
            '<?xml version="1.0"?>\n' + ET.tostring(root, encoding="unicode") + "\n",
            encoding="utf-8",
        )
        print(f"Created {path} with the FGO Arcade Mesa driconf stanza.")
        return

    try:
        parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True))
        tree = ET.parse(path, parser=parser)
        root = tree.getroot()
    except ET.ParseError as exc:
        print(f"{path} is not valid XML ({exc}) - left untouched. "
              "Add the FGO Arcade stanza from the README manually.", file=sys.stderr)
        return

    if root.tag != "driconf":
        print(f"{path} doesn't look like a driconf file (root is <{root.tag}>) - left untouched.",
              file=sys.stderr)
        return

    if _has_our_stanza(root):
        return  # already present - nothing to do, silently idempotent

    root.append(_new_stanza())
    ET.indent(tree, space="    ")
    path.write_text(
        '<?xml version="1.0"?>\n' + ET.tostring(root, encoding="unicode") + "\n",
        encoding="utf-8",
    )
    print(f"Added the FGO Arcade Mesa driconf stanza to your existing {path}.")


if __name__ == "__main__":
    main()
