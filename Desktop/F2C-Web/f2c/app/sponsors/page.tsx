"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";

type SponsorItem = {
  name?: string;
  logo?: string;         // e.g. "/images/BPS_1024.png" or "BPS_1024.png"
  description?: string;  // long text with \n\n paragraphs
};

type SponsorsPayload =
  | { title?: string; updated_for?: string; sponsors?: SponsorItem[] }
  | { sponsors?: SponsorItem[] }
  | SponsorItem[]
  | null;

const BRAND_TITLE = "Footsteps to Change 2026";

function safeString(v: unknown): string {
  return typeof v === "string" ? v : "";
}

function safeArray<T>(v: unknown): T[] {
  return Array.isArray(v) ? (v as T[]) : [];
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

function paragraphize(text: string): string[] {
  // Split on blank lines; keep single line breaks inside paragraphs
  return text
    .split(/\n\s*\n/g)
    .map((p) => p.trim())
    .filter(Boolean);
}

function resolveLogoSrc(logo?: string) {
  const l = safeString(logo);
  if (!l) return "";
  if (l.startsWith("/")) return l; // e.g. "/images/BPS_1024.png"
  return `/images/${l}`;           // e.g. "BPS_1024.png"
}

function SponsorCard({ sponsor }: { sponsor: SponsorItem }) {
  const name = safeString(sponsor.name) || "Sponsor";
  const logoSrc = resolveLogoSrc(sponsor.logo);
  const desc = safeString(sponsor.description);
  const paras = desc ? paragraphize(desc) : [];

  return (
    <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <div className="flex items-start gap-4">
        <div className="h-[86px] w-[86px] shrink-0 rounded-2xl bg-white ring-1 ring-slate-200 flex items-center justify-center overflow-hidden">
          {logoSrc ? (
            <img
              src={logoSrc}
              alt={`${name} logo`}
              className="h-full w-full object-contain p-3"
            />
          ) : (
            <div className="text-xs font-semibold text-slate-600">Sponsor</div>
          )}
        </div>

        <div className="min-w-0 flex-1">
          <div className="text-base font-semibold text-slate-900">{name}</div>
        </div>
      </div>

      <div className="mt-4 space-y-3 text-sm leading-relaxed text-slate-700">
        {paras.length ? (
          paras.map((p, i) => (
            <p key={i} className="whitespace-pre-wrap">
              {p}
            </p>
          ))
        ) : (
          <p className="text-slate-600">(No sponsor description found.)</p>
        )}
      </div>
    </div>
  );
}

export default function SponsorsPage() {
  const [title, setTitle] = useState("Sponsors");
  const [sponsors, setSponsors] = useState<SponsorItem[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setError(null);
      try {
        const res = await fetch("/data/sponsors.json", { cache: "no-store" });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const json = (await res.json()) as SponsorsPayload;

        let list: SponsorItem[] = [];
        let t = "Sponsors";

        if (Array.isArray(json)) {
          list = json;
        } else if (json && typeof json === "object") {
          const obj = json as any;
          t = safeString(obj.title) || t;
          list = safeArray<SponsorItem>(obj.sponsors);
        }

        if (!cancelled) {
          setTitle(t);
          setSponsors(list);
          if (!list.length) setError("No sponsors found in sponsors.json.");
        }
      } catch {
        if (!cancelled) setError("Couldn’t load sponsors.json from /public/data.");
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, []);

  const sorted = useMemo(() => {
    const list = [...sponsors];
    list.sort((a, b) =>
      safeString(a.name).localeCompare(safeString(b.name), "en", { sensitivity: "base" })
    );
    return list;
  }, [sponsors]);

  return (
    <main className="min-h-screen bg-slate-50 px-4 py-6">
      <div className="mx-auto w-full max-w-md space-y-5">
        <div className="flex items-center justify-between">
          <LogoMark subtitle="Sponsors" />
          <Link href="/" className="text-sm font-medium text-slate-600 hover:text-slate-900">
            Home
          </Link>
        </div>

        <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
          <h1 className="text-2xl font-semibold tracking-tight text-slate-900">{title}</h1>
          <p className="mt-2 text-sm text-slate-600">
            Thank you to our sponsors for supporting Footsteps to Change Conference 2026.
          </p>
          {error ? <p className="mt-3 text-sm font-medium text-red-600">{error}</p> : null}
        </div>

        <div className="space-y-3">
          {sorted.map((s, i) => (
            <SponsorCard key={(safeString(s.name) || "sponsor") + i} sponsor={s} />
          ))}
        </div>
      </div>
    </main>
  );
}