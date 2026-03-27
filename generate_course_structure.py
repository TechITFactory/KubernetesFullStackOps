import re
import zlib
from dataclasses import dataclass, field
from pathlib import Path


ROOT = Path(r"c:\Users\USER\Desktop\Kubernetes Full Stack Ops")
PDF_PATH = Path(r"c:\Users\USER\Downloads\k8s-toc.pdf")


@dataclass
class Node:
    number: str
    title: str
    level: int
    children: list["Node"] = field(default_factory=list)


PART_NAME_MAP = {
    "1": "GETTING STARTED",
    "2": "CONCEPTS",
    "3": "TASKS",
    "4": "TUTORIALS",
    "5": "REFERENCE",
    "6": "CONTRIBUTE TO KUBERNETES",
}


def decode_text_from_pdf(pdf_path: Path) -> list[str]:
    pdf = pdf_path.read_bytes()
    cmap_match = re.search(rb"beginbfchar\s*(.*?)\s*endbfchar", pdf, re.S)
    if not cmap_match:
        raise RuntimeError("Unable to locate PDF character map.")

    cmap_pairs = re.findall(rb"<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>", cmap_match.group(1))
    cmap = {int(src, 16): chr(int(dst, 16)) for src, dst in cmap_pairs}

    def decode_hex(hex_text: str) -> str:
        chars = []
        for i in range(0, len(hex_text), 4):
            chunk = hex_text[i : i + 4]
            if len(chunk) == 4:
                chars.append(cmap.get(int(chunk, 16), "?"))
        return "".join(chars)

    texts: list[str] = []
    for stream_match in re.finditer(rb"stream\r?\n", pdf):
        start = stream_match.end()
        end = pdf.find(b"endstream", start)
        if end == -1:
            continue

        data = pdf[start:end]
        if data.endswith(b"\r\n"):
            data = data[:-2]
        elif data.endswith(b"\n"):
            data = data[:-1]

        try:
            decoded = zlib.decompress(data)
        except Exception:
            continue

        if b"BT" not in decoded:
            continue

        pattern = rb"(-?\d+(?:\.\d+)?)\s+(-?\d+(?:\.\d+)?)\s+Tm\s*(.*?)(?=(?:-?\d+(?:\.\d+)?\s+-?\d+(?:\.\d+)?\s+Tm)|ET)"
        for text_match in re.finditer(pattern, decoded, re.S):
            segment = text_match.group(3)
            line = "".join(decode_hex(item.decode()) for item in re.findall(rb"<([0-9A-Fa-f]+)>", segment))
            cleaned = re.sub(r"\s+", " ", line).strip()
            if cleaned:
                texts.append(cleaned)
    return texts


def normalize_outline_lines(lines: list[str]) -> list[str]:
    filtered: list[str] = []
    for line in lines:
        line = re.sub(r"\.{2,}\s*\d+$", "", line).strip()
        if not line:
            continue
        if line.startswith("kubernetes.io/docsPage"):
            continue
        if line.startswith("Kubernetes Complete Course"):
            continue
        if line.startswith("Based on Official Kubernetes Documentation"):
            continue
        if line.startswith("Last Updated:"):
            continue
        if line == "Table of Contents":
            continue
        filtered.append(line)

    merged: list[str] = []
    for line in filtered:
        is_heading = bool(re.match(r"^(Part \d+\s+.+|\d+(?:\.\d+)+\s+.+)$", line))
        if is_heading:
            merged.append(line)
            continue

        # Wrapped title continuation from the PDF text layer.
        if merged and re.match(r"^(Part \d+\s+.+|\d+(?:\.\d+)+\s+.+)$", merged[-1]):
            merged[-1] = f"{merged[-1]} {line}".strip()

    unique: list[str] = []
    seen: set[str] = set()
    for line in merged:
        if line in seen:
            continue
        seen.add(line)
        unique.append(line)
    return unique


def build_outline(lines: list[str]) -> tuple[list[str], dict[str, list[Node]]]:
    part_order: list[str] = []
    parts: dict[str, list[Node]] = {}
    stack: list[Node] = []
    current_part: str | None = None

    for line in lines:
        part_match = re.match(r"^Part (\d+)\s+(.+)$", line)
        if part_match:
            part_number = part_match.group(1)
            current_part = part_number
            if part_number not in parts:
                parts[part_number] = []
                part_order.append(part_number)
            stack = []
            continue

        match = re.match(r"^(\d+(?:\.\d+)+)\s+(.+)$", line)
        if not match:
            continue

        number, title = match.groups()
        level = number.count(".")
        node = Node(number=number, title=title.strip(), level=level)

        if current_part is None:
            current_part = number.split(".")[0]
            if current_part not in parts:
                parts[current_part] = []
                part_order.append(current_part)

        while stack and stack[-1].level >= level:
            stack.pop()

        if stack:
            stack[-1].children.append(node)
        else:
            parts[current_part].append(node)

        stack.append(node)

    return part_order, parts


def slugify(name: str) -> str:
    value = name.lower()
    value = value.replace("&", "and")
    value = re.sub(r"[^a-z0-9]+", "-", value)
    value = re.sub(r"-{2,}", "-", value).strip("-")
    return value or "item"


def safe_name(number: str, title: str) -> str:
    return f"{number}-{slugify(title)}"


def write_text(path: Path, content: str) -> None:
    path.write_text(content, encoding="utf-8")


def render_root_readme(part_order: list[str], parts: dict[str, list[Node]]) -> str:
    lines = [
        "# Kubernetes Complete Course",
        "",
        "Course structure generated from the table of contents in `k8s-toc.pdf`.",
        "",
        "## Layout",
        "",
        "- Each `part-*` folder maps to a top-level part from the PDF.",
        "- Each module is a folder with its own `README.md`.",
        "- Sections and deeper subsections are created as nested folders to preserve the source hierarchy.",
        "",
        "## Parts",
        "",
    ]
    for part_number in part_order:
        part_title = PART_NAME_MAP.get(part_number, f"Part {part_number}")
        lines.append(f"- Part {part_number}: {part_title}")
    lines.append("")
    return "\n".join(lines)


def render_part_readme(part_number: str, nodes: list[Node]) -> str:
    part_title = PART_NAME_MAP.get(part_number, f"Part {part_number}")
    lines = [
        f"# Part {part_number}: {part_title}",
        "",
        "## Modules",
        "",
    ]
    for node in nodes:
        lines.append(f"- {node.number} {node.title}")
    lines.append("")
    return "\n".join(lines)


def render_node_readme(node: Node) -> str:
    lines = [
        f"# {node.number} {node.title}",
        "",
        "- Objective: [Add objective]",
        "- Outcomes: [Add outcomes]",
        "- Notes: [Add notes]",
        "",
    ]
    if node.children:
        lines.append("## Children")
        lines.append("")
        for child in node.children:
            lines.append(f"- {child.number} {child.title}")
        lines.append("")
    return "\n".join(lines)


def render_leaf_file(node: Node) -> str:
    return "\n".join(
        [
            f"# {node.number} {node.title}",
            "",
            "- Summary: [Add section summary]",
            "- Content: [Add lesson content]",
            "- Lab: [Add practice or demo]",
            "",
        ]
    )


def create_section_folder(base_dir: Path, node: Node) -> None:
    section_dir = base_dir / safe_name(node.number, node.title)
    section_dir.mkdir(parents=True, exist_ok=True)
    (section_dir / "scripts").mkdir(exist_ok=True)
    (section_dir / "yamls").mkdir(exist_ok=True)
    write_text(section_dir / "README.md", render_leaf_file(node))
    write_text(section_dir / "scripts" / ".gitkeep", "")
    write_text(section_dir / "yamls" / ".gitkeep", "")


def materialize_children(base_dir: Path, nodes: list[Node]) -> None:
    for node in nodes:
        folder_name = safe_name(node.number, node.title)
        if node.level == 1 or node.children:
            node_dir = base_dir / folder_name
            node_dir.mkdir(parents=True, exist_ok=True)
            write_text(node_dir / "README.md", render_node_readme(node))
            if node.children:
                materialize_children(node_dir, node.children)
        else:
            create_section_folder(base_dir, node)


def build_filesystem(part_order: list[str], parts: dict[str, list[Node]]) -> None:
    ROOT.mkdir(parents=True, exist_ok=True)

    write_text(ROOT / "README.md", render_root_readme(part_order, parts))

    for part_number in part_order:
        part_title = PART_NAME_MAP.get(part_number, f"Part {part_number}")
        part_dir = ROOT / f"part-{part_number}-{slugify(part_title)}"
        part_dir.mkdir(parents=True, exist_ok=True)
        write_text(part_dir / "README.md", render_part_readme(part_number, parts[part_number]))
        materialize_children(part_dir, parts[part_number])


def main() -> None:
    raw_lines = decode_text_from_pdf(PDF_PATH)
    outline_lines = normalize_outline_lines(raw_lines)
    part_order, parts = build_outline(outline_lines)
    build_filesystem(part_order, parts)
    print(f"Generated {len(part_order)} parts in {ROOT}")


if __name__ == "__main__":
    main()
