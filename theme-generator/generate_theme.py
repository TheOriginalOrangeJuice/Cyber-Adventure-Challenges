#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import zipfile
from dataclasses import dataclass, fields
from pathlib import Path
from typing import Iterable


SKIP_DIR_NAMES = {".git", ".generated", "__pycache__"}
SKIP_REWRITE_DIR_NAMES: set[str] = set()
BINARY_EXTENSIONS = {
    ".7z",
    ".a",
    ".bin",
    ".class",
    ".dll",
    ".eot",
    ".exe",
    ".gif",
    ".gz",
    ".ico",
    ".jar",
    ".jpeg",
    ".jpg",
    ".o",
    ".otf",
    ".pdf",
    ".png",
    ".pyc",
    ".so",
    ".tar",
    ".ttf",
    ".woff",
    ".woff2",
    ".zip",
}


@dataclass(frozen=True)
class BaseThemePreset:
    name: str
    slug: str
    short_display_name: str
    code: str
    flag_prefix: str
    event_name: str
    website_dir_name: str
    website_domain: str
    website_public_url: str
    website_service_name: str
    support_project: str
    hack_box1_network: str
    hack_box3_network: str
    evidence_dir_name: str
    evidence_mount_path: str
    crypto_user_prefix: str
    linux_user_prefix: str
    windows_user_prefix: str
    windows_underscored_prefix: str
    hack_user_prefix: str
    hack_underscored_prefix: str
    profile_dir: str
    hack_service_name: str
    notes_dir_name: str
    linux_users_filename: str
    systemd_service_name: str
    hash_users: list[str]
    pipeline_owner: str
    windows_protocol_user: str
    extra_replacements: list[tuple[str, str]]
    audit_markers: list[str]


@dataclass(frozen=True)
class ThemePlan:
    base_theme_dir: Path
    output_dir: Path
    display_name: str
    short_display_name: str
    slug: str
    code: str
    flag_prefix: str
    event_name: str
    website_domain: str
    website_public_url: str
    website_clone_url: str | None
    website_dir_name: str
    website_service_name: str
    support_project: str
    hack_box1_network: str
    hack_box3_network: str
    evidence_dir_name: str
    evidence_mount_path: str
    crypto_user_prefix: str
    linux_user_prefix: str
    windows_user_prefix: str
    windows_underscored_prefix: str
    hack_user_prefix: str
    hack_underscored_prefix: str
    profile_dir: str
    hack_service_name: str
    notes_dir_name: str
    linux_users_filename: str
    systemd_service_name: str
    hash_users: list[str]
    pipeline_owner: str
    windows_protocol_user: str
    extra_replacements: list[tuple[str, str]]


BASE_THEME_PRESETS = {
    "ipn": BaseThemePreset(
        name="IPN Theme",
        slug="ipn",
        short_display_name="IPN",
        code="IPN",
        flag_prefix="IPN",
        event_name="IPN Summit",
        website_dir_name="ipn_website",
        website_domain="ipnsummit.com",
        website_public_url="https://ipnsummit.com/",
        website_service_name="ipnsummit-web",
        support_project="cyber-adventure-ipn-support",
        hack_box1_network="hack_ipn1_net",
        hack_box3_network="hack_ipn3_net",
        evidence_dir_name="IPN_Summit_Data",
        evidence_mount_path="/mnt/ipn_summit_data",
        crypto_user_prefix="cryptIPN",
        linux_user_prefix="linuxIPN",
        windows_user_prefix="windowsIPN",
        windows_underscored_prefix="windows_IPN",
        hack_user_prefix="hackIPN",
        hack_underscored_prefix="hack_IPN",
        profile_dir=".ipn_profile",
        hack_service_name="ipn-backdoor",
        notes_dir_name="ipn_breach_note s",
        linux_users_filename="ipn_users.txt",
        systemd_service_name="cyber-adventure-ipn.service",
        hash_users=[
            "salim_gheewalla",
            "aziz_kapadia",
            "arshad_somani",
            "marriam_shah",
            "hadi_ibrahimi",
            "zain_mitha",
            "serena_tejani",
            "armaan_chakkiwala",
            "shahzeb_jiwani",
            "murad_kajani",
        ],
        pipeline_owner="salim_ghee",
        windows_protocol_user="manisha_hirani",
        extra_replacements=[
            ("ipn", "{code_lower}"),
            ("ipnsummit", "{website_domain_label}"),
            ("IPNSummit", "{website_domain_pascal}"),
            ("https://www.ipnsummit.com/", "{website_public_url}"),
            ("https://ipnsummit.com/", "{website_public_url}"),
            ("ipnonline.net", "{website_domain}"),
            ("IPNOnline", "{short_display_name}"),
        ],
        audit_markers=[
            "IPN Theme",
            "IPN Summit",
            "IPN",
            "ipn",
            "ipnsummit",
            "ipnsummit.com",
            "ipnonline.net",
            "IPNOnline",
            "hack_ipn1_net",
            "hack_ipn3_net",
            "ipn-backdoor",
            "IPN_Summit_Data",
        ],
    ),
    "rowdycon": BaseThemePreset(
        name="RowdyCon Theme",
        slug="rowdycon",
        short_display_name="RowdyCon",
        code="RCC",
        flag_prefix="RCC",
        event_name="RCC Summit",
        website_dir_name="rcc_website",
        website_domain="rowdycybercon.org",
        website_public_url="https://rowdycybercon.org/",
        website_service_name="rcc-web",
        support_project="cyber-adventure-rowdycon-support",
        hack_box1_network="hack_rcc1_net",
        hack_box3_network="hack_rcc3_net",
        evidence_dir_name="RCC_Con_Data",
        evidence_mount_path="/mnt/rcc_con_data",
        crypto_user_prefix="cryptRCC",
        linux_user_prefix="linuxRCC",
        windows_user_prefix="windowsRCC",
        windows_underscored_prefix="windows_RCC",
        hack_user_prefix="hackRCC",
        hack_underscored_prefix="hack_RCC",
        profile_dir=".rcc_profile",
        hack_service_name="rcc-backdoor",
        notes_dir_name="rcc_breach_note s",
        linux_users_filename="rcc_users.txt",
        systemd_service_name="cyber-adventure-rowdycon.service",
        hash_users=[
            "maanasa_baskar",
            "elisha_szeto",
            "joaquin",
            "joshua_silva",
            "vian_chen",
            "curran_hill",
            "blessy",
            "daniel_ruiz",
            "josie_sauceda",
            "judith_infante",
        ],
        pipeline_owner="joshua_silva",
        windows_protocol_user="ke_yang",
        extra_replacements=[
            ("rcc", "{code_lower}"),
            ("rowdycon", "{website_domain_label}"),
            ("RowdyCon", "{short_display_name}"),
            ("rowdycybercon", "{website_domain_label}"),
            ("RowdyCyberCon", "{website_domain_pascal}"),
            ("https://www.rowdycon.org/", "{website_public_url}"),
            ("https://rowdycybercon.org/", "{website_public_url}"),
        ],
        audit_markers=[
            "RowdyCon Theme",
            "RowdyCon",
            "RCC Summit",
            "RCC",
            "rcc",
            "rowdycon",
            "rowdycybercon",
            "rowdycybercon.org",
            "https://www.rowdycon.org/",
            "hack_rcc1_net",
            "hack_rcc3_net",
            "rcc-backdoor",
            "RCC_Con_Data",
        ],
    ),
}


def sanitize_name_for_dir(value: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9]+", "_", value).strip("_")
    return cleaned or "Theme_Data"


def domain_label(domain: str) -> str:
    return domain.split(".", 1)[0]


def pascal_case(value: str) -> str:
    parts = re.split(r"[^A-Za-z0-9]+", value)
    return "".join(part[:1].upper() + part[1:] for part in parts if part)


def load_config(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise SystemExit(f"Config file not found: {path}") from exc
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Config file is not valid JSON: {exc}") from exc


def detect_base_theme(base_theme_dir: Path) -> BaseThemePreset:
    if (base_theme_dir / "Windows" / "box3_persistence" / "IPN_Summit_Data").exists():
        return BASE_THEME_PRESETS["ipn"]
    if (base_theme_dir / "Windows" / "box3_persistence" / "RCC_Con_Data").exists():
        return BASE_THEME_PRESETS["rowdycon"]
    raise SystemExit(f"Could not identify base theme from {base_theme_dir}")


def build_plan(config_path: Path, raw: dict) -> tuple[BaseThemePreset, ThemePlan]:
    theme = raw.get("theme", {})
    people = raw.get("people", {})

    required = [
        ("base_theme_dir", raw.get("base_theme_dir")),
        ("output_dir", raw.get("output_dir")),
        ("theme.display_name", theme.get("display_name")),
        ("theme.slug", theme.get("slug")),
        ("theme.code", theme.get("code")),
        ("theme.flag_prefix", theme.get("flag_prefix")),
        ("theme.event_name", theme.get("event_name")),
        ("theme.website_domain", theme.get("website_domain")),
    ]
    missing = [key for key, value in required if not value]
    if missing:
        raise SystemExit(f"Missing required config values: {', '.join(missing)}")

    base_theme_dir = (config_path.parent / raw["base_theme_dir"]).resolve()
    output_dir = (config_path.parent / raw["output_dir"]).resolve()
    base = detect_base_theme(base_theme_dir)

    hash_users = people.get("hash_users", [])
    if len(hash_users) < len(base.hash_users):
        raise SystemExit(
            f"Config needs at least {len(base.hash_users)} people.hash_users values; got {len(hash_users)}."
        )

    slug = theme["slug"].lower()
    code = theme["code"].upper()
    event_name = theme["event_name"]
    evidence_dir_name = theme.get("evidence_dir_name", f"{sanitize_name_for_dir(event_name)}_Data")
    website_dir_name = theme.get("website_dir_name", f"{slug}_website")
    website_domain = theme["website_domain"]
    website_public_url = theme.get("website_public_url", f"https://{website_domain}/")
    short_display_name = theme.get("short_display_name", event_name)

    template_values = {
        "code_lower": code.lower(),
        "short_display_name": short_display_name,
        "slug": slug,
        "website_domain": website_domain,
        "website_public_url": website_public_url,
        "website_domain_label": domain_label(website_domain),
        "website_domain_pascal": pascal_case(domain_label(website_domain)),
    }

    extra_replacements: list[tuple[str, str]] = []
    for old, template in base.extra_replacements:
        extra_replacements.append((old, template.format(**template_values)))

    for old, new in theme.get("extra_replacements", {}).items():
        extra_replacements.append((old, new))

    plan = ThemePlan(
        base_theme_dir=base_theme_dir,
        output_dir=output_dir,
        display_name=theme["display_name"],
        short_display_name=short_display_name,
        slug=slug,
        code=code,
        flag_prefix=theme["flag_prefix"].upper(),
        event_name=event_name,
        website_domain=website_domain,
        website_public_url=website_public_url,
        website_clone_url=theme.get("website_clone_url"),
        website_dir_name=website_dir_name,
        website_service_name=theme.get("website_service_name", f"{slug}-web"),
        support_project=theme.get("support_project", f"cyber-adventure-{slug}-support"),
        hack_box1_network=theme.get("hack_box1_network", f"hack_{slug}1_net"),
        hack_box3_network=theme.get("hack_box3_network", f"hack_{slug}3_net"),
        evidence_dir_name=evidence_dir_name,
        evidence_mount_path=theme.get("evidence_mount_path", f"/mnt/{slug}_summit_data"),
        crypto_user_prefix=theme.get("crypto_user_prefix", f"crypt{code}"),
        linux_user_prefix=theme.get("linux_user_prefix", f"linux{code}"),
        windows_user_prefix=theme.get("windows_user_prefix", f"windows{code}"),
        windows_underscored_prefix=theme.get("windows_underscored_prefix", f"windows_{code}"),
        hack_user_prefix=theme.get("hack_user_prefix", f"hack{code}"),
        hack_underscored_prefix=theme.get("hack_underscored_prefix", f"hack_{code}"),
        profile_dir=theme.get("profile_dir", f".{slug}_profile"),
        hack_service_name=theme.get("hack_service_name", f"{slug}-backdoor"),
        notes_dir_name=theme.get("notes_dir_name", f"{slug}_breach_note s"),
        linux_users_filename=theme.get("linux_users_filename", f"{slug}_users.txt"),
        systemd_service_name=f"cyber-adventure-{slug}.service",
        hash_users=hash_users[: len(base.hash_users)],
        pipeline_owner=people.get("pipeline_owner", hash_users[0]),
        windows_protocol_user=people.get("windows_protocol_user", hash_users[0]),
        extra_replacements=extra_replacements,
    )

    return base, plan


def ignore_copy(_src: str, names: list[str]) -> set[str]:
    ignored = {name for name in names if name in SKIP_DIR_NAMES}
    return ignored


def copy_theme(plan: ThemePlan, force: bool) -> None:
    if plan.output_dir.exists():
        if not force:
            raise SystemExit(f"Output directory already exists: {plan.output_dir}. Use --force to overwrite it.")
        shutil.rmtree(plan.output_dir, ignore_errors=True)

    shutil.copytree(plan.base_theme_dir, plan.output_dir, ignore=ignore_copy)


def build_replacements(base: BaseThemePreset, plan: ThemePlan) -> list[tuple[str, str]]:
    replacements: dict[str, str] = {}

    def add(old: str, new: str) -> None:
        if old and old != new:
            replacements[old] = new

    def add_common_case_variants(old: str, new: str) -> None:
        variants = [
            (old, new),
            (old.lower(), new.lower()),
            (old.upper(), new.upper()),
            (old.capitalize(), new.capitalize()),
            (old.title(), new.title()),
        ]
        for old_variant, new_variant in variants:
            add(old_variant, new_variant)

    add_common_case_variants(base.name, plan.display_name)
    add_common_case_variants(base.slug, plan.slug)
    add_common_case_variants(base.short_display_name, plan.short_display_name)
    add_common_case_variants(base.event_name, plan.event_name)
    add_common_case_variants(base.flag_prefix, plan.flag_prefix)
    add_common_case_variants(base.code, plan.code)
    add_common_case_variants(base.website_dir_name, plan.website_dir_name)
    add_common_case_variants(base.website_domain, plan.website_domain)
    add_common_case_variants(base.website_public_url, plan.website_public_url)
    add_common_case_variants(base.website_service_name, plan.website_service_name)
    add_common_case_variants(base.support_project, plan.support_project)
    add_common_case_variants(base.hack_box1_network, plan.hack_box1_network)
    add_common_case_variants(base.hack_box3_network, plan.hack_box3_network)
    add_common_case_variants(base.evidence_dir_name, plan.evidence_dir_name)
    add_common_case_variants(base.evidence_mount_path, plan.evidence_mount_path)
    add_common_case_variants(base.crypto_user_prefix, plan.crypto_user_prefix)
    add_common_case_variants(base.linux_user_prefix, plan.linux_user_prefix)
    add_common_case_variants(base.windows_user_prefix, plan.windows_user_prefix)
    add_common_case_variants(base.windows_underscored_prefix, plan.windows_underscored_prefix)
    add_common_case_variants(base.hack_user_prefix, plan.hack_user_prefix)
    add_common_case_variants(base.hack_underscored_prefix, plan.hack_underscored_prefix)
    add_common_case_variants(base.profile_dir, plan.profile_dir)
    add_common_case_variants(base.hack_service_name, plan.hack_service_name)
    add_common_case_variants(base.notes_dir_name, plan.notes_dir_name)
    add_common_case_variants(base.linux_users_filename, plan.linux_users_filename)
    add_common_case_variants(base.systemd_service_name, plan.systemd_service_name)
    add_common_case_variants(base.pipeline_owner, plan.pipeline_owner)
    add_common_case_variants(base.windows_protocol_user, plan.windows_protocol_user)

    for old_name, new_name in zip(base.hash_users, plan.hash_users):
        add_common_case_variants(old_name, new_name)

    for old, new in plan.extra_replacements:
        add_common_case_variants(old, new)

    ordered = sorted(replacements.items(), key=lambda item: len(item[0]), reverse=True)
    return ordered


def collect_audit_markers(base: BaseThemePreset) -> list[str]:
    markers: list[str] = []
    for field in fields(base):
        value = getattr(base, field.name)
        if isinstance(value, str):
            markers.append(value)
            continue
        if isinstance(value, list):
            for item in value:
                if isinstance(item, str):
                    markers.append(item)
                elif isinstance(item, tuple):
                    old_value = item[0]
                    if isinstance(old_value, str):
                        markers.append(old_value)

    deduped = []
    for marker in markers:
        if marker and marker not in deduped:
            deduped.append(marker)
    return deduped


def compile_audit_pattern(marker: str) -> re.Pattern[str]:
    flags = re.IGNORECASE if any(char.isalpha() for char in marker) else 0
    if marker.isalnum() and len(marker) <= 4:
        return re.compile(rf"(?<![A-Za-z0-9]){re.escape(marker)}(?![A-Za-z0-9])", flags)
    return re.compile(re.escape(marker), flags)


def rename_paths(root: Path, replacements: list[tuple[str, str]]) -> None:
    all_paths = sorted(root.rglob("*"), key=lambda path: len(path.parts), reverse=True)
    for path in all_paths:
        if any(part in SKIP_REWRITE_DIR_NAMES for part in path.parts):
            continue
        new_name = path.name
        for old, new in replacements:
            if old in new_name:
                new_name = new_name.replace(old, new)
        if new_name != path.name:
            path.rename(path.with_name(new_name))


def is_probably_binary(path: Path, raw: bytes | None = None) -> bool:
    if path.suffix.lower() in BINARY_EXTENSIONS:
        return True
    if raw is None:
        try:
            raw = path.read_bytes()
        except OSError:
            return True
    sample = raw[:4096]
    return b"\x00" in sample


def to_binary_pairs(replacements: list[tuple[str, str]]) -> list[tuple[str, bytes, bytes]]:
    pairs: list[tuple[str, bytes, bytes]] = []
    for old, new in replacements:
        try:
            old_bytes = old.encode("utf-8")
            if len(old_bytes) < 5:
                continue
            pairs.append((old, old_bytes, new.encode("utf-8")))
        except UnicodeEncodeError:
            continue
    return pairs


def decode_text(raw: bytes) -> tuple[str, str] | None:
    try:
        return raw.decode("utf-8"), "utf-8"
    except UnicodeDecodeError:
        try:
            return raw.decode("latin-1"), "latin-1"
        except UnicodeDecodeError:
            return None


def apply_text_replacements(text: str, replacements: list[tuple[str, str]]) -> str:
    updated = text
    for old, new in replacements:
        updated = updated.replace(old, new)
    for old, new in replacements:
        if old.isalnum() and len(old) <= 4:
            updated = re.sub(rf"(?<![A-Za-z0-9]){re.escape(old)}(?![A-Za-z0-9])", new, updated, flags=re.IGNORECASE)
    return updated


def replace_binary_content(raw: bytes, binary_pairs: list[tuple[str, bytes, bytes]]) -> bytes:
    updated = raw
    for _old, old_bytes, new_bytes in binary_pairs:
        if old_bytes not in updated:
            continue
        if len(new_bytes) > len(old_bytes):
            continue
        replacement = new_bytes.ljust(len(old_bytes), b"\x00")
        updated = updated.replace(old_bytes, replacement)
    return updated


def rewrite_zip_archive(path: Path, replacements: list[tuple[str, str]], binary_pairs: list[tuple[str, bytes, bytes]]) -> None:
    temp_path = path.with_suffix(path.suffix + ".tmp")
    changed = False
    with zipfile.ZipFile(path, "r") as source:
        archive_comment = source.comment
        decoded_comment = decode_text(archive_comment)
        if decoded_comment is not None:
            comment_text, comment_encoding = decoded_comment
            updated_comment_text = apply_text_replacements(comment_text, replacements)
            updated_comment = updated_comment_text.encode(comment_encoding)
            changed = changed or updated_comment != archive_comment
        else:
            updated_comment = replace_binary_content(archive_comment, binary_pairs)
            changed = changed or updated_comment != archive_comment

        with zipfile.ZipFile(temp_path, "w") as dest:
            for info in source.infolist():
                raw = source.read(info.filename)
                new_name = apply_text_replacements(info.filename, replacements)
                changed = changed or new_name != info.filename

                entry_path = Path(info.filename)
                if is_probably_binary(entry_path, raw):
                    new_raw = replace_binary_content(raw, binary_pairs)
                else:
                    decoded = decode_text(raw)
                    if decoded is None:
                        new_raw = raw
                    else:
                        text, encoding = decoded
                        updated_text = apply_text_replacements(text, replacements)
                        new_raw = updated_text.encode(encoding)
                changed = changed or new_raw != raw

                new_info = zipfile.ZipInfo(new_name, date_time=info.date_time)
                new_info.compress_type = info.compress_type
                new_info.comment = info.comment
                new_info.extra = info.extra
                new_info.create_system = info.create_system
                new_info.create_version = info.create_version
                new_info.extract_version = info.extract_version
                new_info.flag_bits = info.flag_bits
                new_info.volume = info.volume
                new_info.internal_attr = info.internal_attr
                new_info.external_attr = info.external_attr
                dest.writestr(new_info, new_raw)

            dest.comment = updated_comment

    if changed:
        os.replace(temp_path, path)
        return

    temp_path.unlink(missing_ok=True)


def replace_file_content(root: Path, replacements: list[tuple[str, str]]) -> None:
    binary_pairs = to_binary_pairs(replacements)
    for path in root.rglob("*"):
        if any(part in SKIP_REWRITE_DIR_NAMES for part in path.parts):
            continue
        if not path.is_file():
            continue

        if path.suffix.lower() == ".zip":
            rewrite_zip_archive(path, replacements, binary_pairs)
            continue

        raw = path.read_bytes()
        if is_probably_binary(path, raw):
            updated = replace_binary_content(raw, binary_pairs)
            if updated != raw:
                path.write_bytes(updated)
            continue

        decoded = decode_text(raw)
        if decoded is None:
            continue
        text, encoding = decoded
        updated = apply_text_replacements(text, replacements)

        if updated != text:
            path.write_text(updated, encoding=encoding)


def find_marker_in_binary(raw: bytes, markers: list[str]) -> str | None:
    for marker in markers:
        try:
            marker_bytes = marker.encode("utf-8")
        except UnicodeEncodeError:
            continue
        if len(marker_bytes) < 5:
            continue
        if marker_bytes and marker_bytes in raw:
            return marker
    return None


def find_marker_in_zip(path: Path, markers: list[str], patterns: list[re.Pattern[str]]) -> tuple[int, str] | None:
    try:
        with zipfile.ZipFile(path, "r") as archive:
            for info in archive.infolist():
                for marker, pattern in zip(markers, patterns):
                    if pattern.search(info.filename):
                        return 0, marker

                raw = archive.read(info.filename)
                entry_path = Path(info.filename)
                if is_probably_binary(entry_path, raw):
                    marker = find_marker_in_binary(raw, markers)
                    if marker is not None:
                        return 0, marker
                    continue

                decoded = decode_text(raw)
                if decoded is not None:
                    text, encoding = decoded
                    for lineno, line in enumerate(text.splitlines(), start=1):
                        for marker, pattern in zip(markers, patterns):
                            if pattern.search(line):
                                return lineno, marker
    except zipfile.BadZipFile:
        return None

    return None


def should_skip_audit_path(path: Path, output_root: Path, skip_website_clone: bool, website_dir_name: str) -> bool:
    if path.name == "theme-generator.json":
        return True
    if any(part in SKIP_REWRITE_DIR_NAMES for part in path.parts):
        return True
    if skip_website_clone:
        website_root = output_root / "Hack" / "Box3" / website_dir_name
        try:
            path.relative_to(website_root)
            return True
        except ValueError:
            pass
    return False


def audit_generated_theme(
    output_root: Path,
    base: BaseThemePreset,
    skip_website_clone: bool,
    website_dir_name: str,
) -> list[tuple[Path, int, str]]:
    findings: list[tuple[Path, int, str]] = []
    markers = collect_audit_markers(base)
    patterns = [compile_audit_pattern(marker) for marker in markers]

    for path in output_root.rglob("*"):
        if should_skip_audit_path(path, output_root, skip_website_clone, website_dir_name):
            continue
        relative_path = path.relative_to(output_root).as_posix()
        for marker, pattern in zip(markers, patterns):
            if pattern.search(relative_path):
                findings.append((path, 0, marker))
                break
        if not path.is_file():
            continue

        raw = path.read_bytes()
        if path.suffix.lower() == ".zip":
            match = find_marker_in_zip(path, markers, patterns)
            if match is not None:
                lineno, marker = match
                findings.append((path, lineno, marker))
            continue

        if is_probably_binary(path, raw):
            marker = find_marker_in_binary(raw, markers)
            if marker is not None:
                findings.append((path, 0, marker))
            continue

        try:
            text = raw.decode("utf-8")
        except UnicodeDecodeError:
            try:
                text = raw.decode("latin-1")
            except UnicodeDecodeError:
                continue

        for lineno, line in enumerate(text.splitlines(), start=1):
            for marker, pattern in zip(markers, patterns):
                if pattern.search(line):
                    findings.append((path, lineno, marker))
                    break

    return findings


def discover_switchboard_dir(config_path: Path, plan: ThemePlan) -> Path | None:
    env_dir = os.environ.get("SWITCHBOARD_DIR")
    candidates = []
    if env_dir:
        candidates.append(Path(env_dir))

    candidates.extend(
        [
            config_path.parent / "Docker-TCP-Switchboard",
            plan.base_theme_dir.parent / "Docker-TCP-Switchboard",
            plan.output_dir.parent / "Docker-TCP-Switchboard",
            plan.output_dir / "Docker-TCP-Switchboard",
        ]
    )

    for candidate in candidates:
        if candidate.is_dir():
            return candidate.resolve()
    return None


def validate_generated_theme(config_path: Path, plan: ThemePlan) -> None:
    print("[theme-generator] Validating generated theme")
    subprocess.run(["bash", "-n", str(plan.output_dir / "labctl.sh")], check=True)

    docker = shutil.which("docker")
    if docker is None:
        print("[theme-generator] Skipping Docker-backed validation because 'docker' is not installed")
        return

    switchboard_dir = discover_switchboard_dir(config_path, plan)
    if switchboard_dir is None:
        print(
            "[theme-generator] Skipping labctl validation because Docker-TCP-Switchboard "
            "was not found next to the config, base theme, or output directory"
        )
        return

    env = os.environ.copy()
    env["SWITCHBOARD_DIR"] = str(switchboard_dir)

    subprocess.run(
        ["./labctl.sh", "generate-config"],
        cwd=plan.output_dir,
        env=env,
        stdout=subprocess.DEVNULL,
        check=True,
    )
    subprocess.run(
        ["./labctl.sh", "generate-service"],
        cwd=plan.output_dir,
        env=env,
        stdout=subprocess.DEVNULL,
        check=True,
    )
    subprocess.run(
        [
            docker,
            "compose",
            "-f",
            str(plan.output_dir / "Hack" / "Box 1" / "docker-compose.yml"),
            "config",
        ],
        cwd=plan.output_dir,
        stdout=subprocess.DEVNULL,
        check=True,
    )


def rewrite_labctl(path: Path, plan: ThemePlan) -> None:
    text = path.read_text(encoding="utf-8")
    detect_body = f"""detect_theme() {{
  THEME_SLUG="{plan.slug}"
  SUPPORT_PROJECT="{plan.support_project}"
  HACK_BOX1_NETWORK="{plan.hack_box1_network}"
  HACK_BOX3_NETWORK="{plan.hack_box3_network}"
  WINDOWS_EVIDENCE_HOST_DIR="${{THEME_DIR}}/Windows/box3_persistence/{plan.evidence_dir_name}"
  WINDOWS_EVIDENCE_CONTAINER_DIR="{plan.evidence_mount_path}"
}}"""
    text, count = re.subn(r"detect_theme\(\) \{\n.*?\n\}", detect_body, text, flags=re.S)
    if count != 1:
        raise SystemExit(f"Could not rewrite detect_theme() in {path}")

    status_line = (
        "  docker ps --format 'table {{.Names}}\\t{{.Image}}\\t{{.Status}}' "
        f"| awk 'NR == 1 || $1 ~ /cyber-adventure/ || $1 ~ /{re.escape(plan.website_service_name)}/ || $1 ~ /scout-/'"
    )
    text = re.sub(
        r"  docker ps --format 'table \{\{\.Names\}\}\\t\{\{\.Image\}\}\\t\{\{\.Status\}\}' \| awk 'NR == 1 \|\| \$1 ~ /cyber-adventure/ \|\| \$1 ~ /.*?\/ \|\| \$1 ~ /scout-/'",
        status_line,
        text,
    )

    path.write_text(text, encoding="utf-8")
    os.chmod(path, 0o755)


def clone_website(plan: ThemePlan, skip_website_clone: bool) -> None:
    if skip_website_clone or not plan.website_clone_url:
        return

    wget = shutil.which("wget")
    if wget is None:
        raise SystemExit("Website cloning requested, but 'wget' is not installed.")

    website_parent = plan.output_dir / "Hack" / "Box3" / plan.website_dir_name
    shutil.rmtree(website_parent, ignore_errors=True)
    website_parent.mkdir(parents=True, exist_ok=True)

    command = [
        wget,
        "--mirror",
        "--convert-links",
        "--adjust-extension",
        "--page-requisites",
        "--no-parent",
        "--directory-prefix",
        str(website_parent),
        plan.website_clone_url,
    ]
    subprocess.run(command, check=True)

    desired_root = website_parent / plan.website_domain
    if desired_root.exists():
        return

    top_level_dirs = [child for child in website_parent.iterdir() if child.is_dir()]
    if len(top_level_dirs) == 1:
        top_level_dirs[0].rename(desired_root)
        return

    loose_files = [child for child in website_parent.iterdir() if child.is_file()]
    if loose_files:
        desired_root.mkdir(parents=True, exist_ok=True)
        for child in list(website_parent.iterdir()):
            if child != desired_root:
                shutil.move(str(child), desired_root / child.name)


def write_generator_metadata(plan: ThemePlan, config_path: Path) -> None:
    metadata = {
        "generated_from": str(config_path),
        "slug": plan.slug,
        "display_name": plan.display_name,
        "event_name": plan.event_name,
        "website_domain": plan.website_domain,
    }
    output = plan.output_dir / "theme-generator.json"
    output.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")


def generate_theme(
    config_path: Path,
    force: bool,
    skip_website_clone: bool,
    skip_audit: bool,
    skip_validation: bool,
) -> None:
    raw = load_config(config_path)
    base, plan = build_plan(config_path, raw)
    replacements = build_replacements(base, plan)

    print(f"[theme-generator] Copying base theme from {plan.base_theme_dir} to {plan.output_dir}")
    copy_theme(plan, force=force)
    print("[theme-generator] Renaming theme-specific paths")
    rename_paths(plan.output_dir, replacements)
    print("[theme-generator] Rewriting file content")
    replace_file_content(plan.output_dir, replacements)

    print("[theme-generator] Rewriting generated labctl.sh")
    rewrite_labctl(plan.output_dir / "labctl.sh", plan)
    print("[theme-generator] Handling website assets")
    clone_website(plan, skip_website_clone=skip_website_clone)
    write_generator_metadata(plan, config_path)

    if not skip_audit:
        print("[theme-generator] Auditing generated content for leftover baseline markers")
        findings = audit_generated_theme(
            output_root=plan.output_dir,
            base=base,
            skip_website_clone=skip_website_clone,
            website_dir_name=plan.website_dir_name,
        )
        if findings:
            preview = "\n".join(
                f"  - {path}:{lineno} still contains legacy marker {marker!r}"
                for path, lineno, marker in findings[:20]
            )
            raise SystemExit(
                "Generated theme still contains baseline-specific content.\n"
                f"{preview}\n"
                f"Total findings: {len(findings)}"
            )

    if not skip_validation:
        validate_generated_theme(config_path, plan)

    print(f"Generated theme at: {plan.output_dir}")
    if plan.website_clone_url and not skip_website_clone:
        print(f"Cloned website into: {plan.output_dir / 'Hack' / 'Box3' / plan.website_dir_name / plan.website_domain}")


def parse_args(argv: Iterable[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a new Cyber Adventure theme from a small config file.")
    parser.add_argument("--config", required=True, help="Path to the JSON config file.")
    parser.add_argument("--force", action="store_true", help="Overwrite the output directory if it already exists.")
    parser.add_argument(
        "--skip-website-clone",
        action="store_true",
        help="Do not mirror the configured website into Hack/Box3 during this run.",
    )
    parser.add_argument(
        "--skip-audit",
        action="store_true",
        help="Skip the leftover-content audit after generation.",
    )
    parser.add_argument(
        "--skip-validation",
        action="store_true",
        help="Skip syntax and compose validation for the generated theme.",
    )
    return parser.parse_args(list(argv))


def main(argv: Iterable[str]) -> int:
    args = parse_args(argv)
    config_path = Path(args.config).resolve()
    generate_theme(
        config_path,
        force=args.force,
        skip_website_clone=args.skip_website_clone,
        skip_audit=args.skip_audit,
        skip_validation=args.skip_validation,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
