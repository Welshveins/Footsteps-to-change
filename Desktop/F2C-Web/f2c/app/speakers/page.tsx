"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";

type Speaker = {
  id?: string;
  name?: string;
  role?: string;
  title?: string;
  organisation?: string;

  // common fields we’ve seen
  bio?: unknown;
  profile?: unknown;

  // sometimes extra fields exist
  sections?: unknown;
};

type SpeakersPayload =
  | { speakers?: Speaker[]; items?: Speaker[] }
  | Speaker[]
  | null;

const BRAND_TITLE = "Footsteps to Change 2026";

function safeString(v: unknown): string {
  return typeof v === "string" ? v : "";
}

function isStringArray(v: unknown): v is string[] {
  return Array.isArray(v) && v.every((x) => typeof x === "string");
}

function textFromUnknown(v: unknown): string {
  // Handles: string, ["para1","para2"], {a:"...", b:"..."} etc.
  if (typeof v === "string") return v;

  if (isStringArray(v)) return v.join("\n\n");

  if (v && typeof v === "object") {
    // Join any string / string[] values in a predictable order
    const entries = Object.entries(v as Record<string, unknown>);
    const parts: string[] = [];

    for (const [, val] of entries) {
      if (typeof val === "string") parts.push(val);
      else if (isStringArray(val)) parts.push(val.join("\n\n"));
    }

    return parts.filter(Boolean).join("\n\n");
  }

  return "";
}

function initialsFromName(name: string): string {
  const parts = name
    .trim()
    .split(/\s+/)
    .filter(Boolean);
  if (parts.length === 0) return "";
  if (parts.length === 1) return parts[0].slice(0, 1).toUpperCase();
  return (parts[0].slice(0, 1) + parts[parts.length - 1].slice(0, 1)).toUpperCase();
}

function normaliseNameForPhoto(name: string): string {
  // Strip common titles (Dr / Professor / Prof / OBE etc.), then build file slug
  const stripped = name
    .replace(/\b(dr|professor|prof)\b\.?/gi, "")
    .replace(/\b(obe|mbbs|md|phd|msc|bsc)\b\.?/gi, "")
    .replace(/[^\p{L}\p{N}\s-]/gu, "") // remove punctuation (unicode-safe)
    .trim();

  return stripped.toLowerCase().replace(/\s+/g, "_");
}

function photoUrlForName(name: string): string {
  // Photos are now like: laura_hissey.png
  const slug = normaliseNameForPhoto(name);
  return `/photos/${encodeURIComponent(slug)}.png`;
}

function LogoMark({ subtitle }: { subtitle: string }) {
  return (
    <div className="flex items-center gap-3">
      <img
        src="/images/F2C_Appicon.png"
        alt=""
        className="h-8 w-8 rounded-md bg-white ring-1 ring-slate-200 object-contain"
      />
      <div className="leading-tight">
        <div className="text-sm font-semibold text-slate-900">{BRAND_TITLE}</div>
        <div className="text-xs text-slate-600">{subtitle}</div>
      </div>
    </div>
  );
}

export default function SpeakersPage() {
  const [speakers, setSpeakers] = useState<Speaker[]>([]);
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [imgError, setImgError] = useState<Record<string, boolean>>({});

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setError(null);
      try {
        const res = await fetch("/data/speakers.json", { cache: "no-store" });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const json = (await res.json()) as SpeakersPayload;

        const list: Speaker[] = Array.isArray(json)
          ? json
          : Array.isArray((json as any)?.speakers)
            ? ((json as any).speakers as Speaker[])
            : Array.isArray((json as any)?.items)
              ? ((json as any).items as Speaker[])
              : [];

        if (!cancelled) setSpeakers(list);
      } catch {
        if (!cancelled) setError("Couldn’t load speakers.");
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, []);

  const sorted = useMemo(() => {
    const list = [...speakers];
    list.sort((a, b) =>
      safeString(a.name).localeCompare(safeString(b.name), "en", { sensitivity: "base" })
    );
    return list;
  }, [speakers]);

  return (
    <main className="min-h-screen bg-slate-50 px-4 py-6">
      <div className="mx-auto w-full max-w-md space-y-5">
        <div className="flex items-center justify-between">
          <LogoMark subtitle="Speakers" />
          <Link href="/" className="text-sm font-medium text-slate-600 hover:text-slate-900">
            Home
          </Link>
        </div>

        <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
          <h1 className="text-2xl font-semibold tracking-tight text-slate-900">Speakers</h1>
          <p className="mt-2 text-sm text-slate-600">Tap a speaker to open their details.</p>
          {error ? <p className="mt-3 text-sm font-medium text-red-600">{error}</p> : null}
        </div>

        <div className="space-y-3">
          {sorted.map((s, idx) => {
            const name = safeString(s.name) || `Speaker ${idx + 1}`;
            const id = safeString(s.id) || name;

            const roleLine = safeString(s.role) || safeString(s.title) || "";
            const orgLine = safeString(s.organisation) || "";

            // ✅ Build bio from multiple possible shapes, preserving paragraphs
            const bioText =
              textFromUnknown(s.bio) ||
              textFromUnknown(s.profile) ||
              textFromUnknown(s.sections) ||
              "";

            const isOpen = expandedId === id;
            const showImage = !imgError[id];

            return (
              <button
                key={id}
                type="button"
                onClick={() => setExpandedId(isOpen ? null : id)}
                className="w-full text-left rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200 active:scale-[0.995]"
              >
                <div className="flex items-start gap-4">
                  <div className="shrink-0">
                    {showImage ? (
                      <img
                        src={photoUrlForName(name)}
                        alt={name}
                        className="h-14 w-14 rounded-xl object-cover ring-1 ring-slate-200 bg-slate-100"
                        onError={() => setImgError((m) => ({ ...m, [id]: true }))}
                      />
                    ) : (
                      <div className="h-14 w-14 rounded-xl bg-sky-50 ring-1 ring-slate-200 flex items-center justify-center text-sm font-semibold text-slate-700">
                        {initialsFromName(name)}
                      </div>
                    )}
                  </div>

                  <div className="min-w-0 flex-1">
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <div className="text-base font-semibold text-slate-900 truncate">{name}</div>
                        {roleLine ? <div className="mt-0.5 text-sm text-slate-700">{roleLine}</div> : null}
                        {orgLine ? <div className="mt-0.5 text-sm text-slate-600">{orgLine}</div> : null}
                      </div>

                      <div className="shrink-0 text-sm font-semibold text-slate-600">
                        {isOpen ? "–" : "+"}
                      </div>
                    </div>

                    {isOpen ? (
                      <div className="mt-4 space-y-3 text-sm leading-relaxed text-slate-700">
                        {bioText ? (
                          <p className="whitespace-pre-wrap">{bioText}</p>
                        ) : (
                          <p className="text-slate-600">(No speaker bio provided.)</p>
                        )}
                      </div>
                    ) : null}
                  </div>
                </div>
              </button>
            );
          })}

          {!error && sorted.length === 0 ? (
            <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
              <p className="text-sm text-slate-600">(No speakers found in speakers_FINAL.json.)</p>
            </div>
          ) : null}
        </div>

        <div className="h-4" />
      </div>
    </main>
  );
}