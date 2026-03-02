"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";

type AbstractItem = {
  id?: string;
  title?: string;
  authors?: string[];
  affiliations?: string[];
  topic?: string | null;

  // two common ways the text appears
  abstractText?: string;
  rawText?: string;

  // structured sections
  sections?: Record<string, string>;

  keywords?: string[];
  references?: string[];
};

type AbstractsPayload =
  | { abstracts?: AbstractItem[]; items?: AbstractItem[]; sessions?: AbstractItem[]; data?: AbstractItem[] }
  | AbstractItem[]
  | null;

const BRAND_TITLE = "Footsteps to Change 2026";

function safeString(v: unknown): string {
  return typeof v === "string" ? v : "";
}

function safeArray(v: unknown): string[] {
  return Array.isArray(v) ? v.filter((x) => typeof x === "string") : [];
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

function normalizeAbstracts(json: AbstractsPayload): AbstractItem[] {
  if (!json) return [];
  if (Array.isArray(json)) return json as AbstractItem[];

  const asObj = json as any;
  const arr =
    (Array.isArray(asObj.abstracts) && asObj.abstracts) ||
    (Array.isArray(asObj.items) && asObj.items) ||
    (Array.isArray(asObj.sessions) && asObj.sessions) ||
    (Array.isArray(asObj.data) && asObj.data) ||
    [];

  return arr as AbstractItem[];
}

function formatSectionTitle(key: string) {
  const k = key.trim();
  if (!k) return "";
  return k.charAt(0).toUpperCase() + k.slice(1);
}

export default function AbstractsPage() {
  const [items, setItems] = useState<AbstractItem[]>([]);
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setError(null);
      try {
        const res = await fetch("/data/abstracts.json", { cache: "no-store" });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const json = (await res.json()) as AbstractsPayload;
        const list = normalizeAbstracts(json);
        if (!cancelled) setItems(list);
      } catch {
        if (!cancelled) setError("Couldn’t load abstracts.json from /public/data.");
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, []);

  const sorted = useMemo(() => {
    const list = [...items];
    list.sort((a, b) => safeString(a.title).localeCompare(safeString(b.title), "en", { sensitivity: "base" }));
    return list;
  }, [items]);

  return (
    <main className="min-h-screen bg-slate-50 px-4 py-6">
      <div className="mx-auto w-full max-w-md space-y-5">
        <div className="flex items-center justify-between">
          <LogoMark subtitle="Abstracts" />
          <Link href="/" className="text-sm font-medium text-slate-600 hover:text-slate-900">
            Home
          </Link>
        </div>

        <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
          <h1 className="text-2xl font-semibold tracking-tight text-slate-900">Abstracts</h1>
          <p className="mt-2 text-sm text-slate-600">Tap an abstract to expand.</p>
          {error ? <p className="mt-3 text-sm font-medium text-red-600">{error}</p> : null}
        </div>

        <div className="space-y-3">
          {sorted.map((a, idx) => {
            const title = safeString(a.title) || `Abstract ${idx + 1}`;
            const id = safeString(a.id) || title;

            const authors = safeArray(a.authors);
            const affiliations = safeArray(a.affiliations);
            const topic = safeString(a.topic);

            const isOpen = expandedId === id;

            const sections = a.sections && typeof a.sections === "object" ? a.sections : null;
            const sectionKeys = sections ? Object.keys(sections).filter((k) => safeString((sections as any)[k]).trim()) : [];

            const abstractText = safeString(a.abstractText) || safeString(a.rawText);

            const keywords = safeArray(a.keywords);
            const references = safeArray(a.references);

            return (
              <button
                key={id}
                type="button"
                onClick={() => setExpandedId(isOpen ? null : id)}
                className="w-full text-left rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200 active:scale-[0.995]"
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <div className="text-base font-semibold text-slate-900">{title}</div>

                    {authors.length ? (
                      <div className="mt-1 text-sm text-slate-700">{authors.join(", ")}</div>
                    ) : null}

                    {topic ? <div className="mt-1 text-sm text-slate-600">{topic}</div> : null}
                  </div>

                  <div className="shrink-0 text-sm font-semibold text-slate-600">{isOpen ? "–" : "+"}</div>
                </div>

                {isOpen ? (
                  <div className="mt-4 space-y-4 text-sm leading-relaxed text-slate-700">
                    {affiliations.length ? (
                      <div>
                        <div className="font-semibold text-slate-900">Affiliations</div>
                        <div className="mt-1">{affiliations.join(" • ")}</div>
                      </div>
                    ) : null}

                    {sectionKeys.length ? (
                      <div className="space-y-4">
                        {sectionKeys.map((k) => (
                          <div key={k}>
                            <div className="font-semibold text-slate-900">{formatSectionTitle(k)}</div>
                            <p className="mt-1 whitespace-pre-wrap">{safeString((sections as any)[k])}</p>
                          </div>
                        ))}
                      </div>
                    ) : abstractText ? (
                      <div>
                        <div className="font-semibold text-slate-900">Abstract</div>
                        <p className="mt-1 whitespace-pre-wrap">{abstractText}</p>
                      </div>
                    ) : (
                      <p className="text-slate-600">(No abstract text found.)</p>
                    )}

                    {keywords.length ? (
                      <div>
                        <div className="font-semibold text-slate-900">Keywords</div>
                        <div className="mt-1">{keywords.join(", ")}</div>
                      </div>
                    ) : null}

                    {references.length ? (
                      <div>
                        <div className="font-semibold text-slate-900">References</div>
                        <ul className="mt-2 list-disc space-y-1 pl-5">
                          {references.map((r, i) => (
                            <li key={i} className="whitespace-pre-wrap">
                              {r}
                            </li>
                          ))}
                        </ul>
                      </div>
                    ) : null}
                  </div>
                ) : null}
              </button>
            );
          })}

          {!error && sorted.length === 0 ? (
            <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
              <p className="text-sm text-slate-600">(No abstracts found in abstracts.json.)</p>
            </div>
          ) : null}
        </div>

        <div className="h-4" />
      </div>
    </main>
  );
}