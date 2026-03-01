import Link from "next/link";
import { readFile } from "node:fs/promises";

type WelcomeJSON = {
  title?: string;
  location?: string;
  body?: string | string[];
  sign_off?: {
    names?: string[];
    role?: string;
  };
};

const BRAND_TITLE = "Footsteps to Change 2026";

function Header({ subtitle }: { subtitle: string }) {
  return (
    <div className="flex items-center justify-between">
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

      <Link
        href="/"
        className="text-sm font-medium text-slate-600 hover:text-slate-900"
      >
        Home
      </Link>
    </div>
  );
}

function asParagraphs(body: WelcomeJSON["body"]): string[] {
  if (!body) return [];
  if (Array.isArray(body)) return body.filter(Boolean);
  if (typeof body === "string") {
    return body
      .split(/\n\s*\n/g) // blank-line paragraphs
      .map((s) => s.trim())
      .filter(Boolean);
  }
  return [];
}

export default async function WelcomePage() {
  let data: WelcomeJSON | null = null;

  try {
    const raw = await readFile(process.cwd() + "/public/data/welcome_statement_2026.json", "utf8");
    data = JSON.parse(raw) as WelcomeJSON;
  } catch {
    data = null;
  }

  const title = data?.title ?? "Welcome";
  const location = data?.location ?? "";
  const paragraphs = asParagraphs(data?.body);

  const names = data?.sign_off?.names ?? ["Emma Davies", "Laura Hissey"];
  const role = data?.sign_off?.role ?? "Conference Organisers";

  return (
    <main className="min-h-screen bg-slate-50 px-4 py-6">
      <div className="mx-auto w-full max-w-md space-y-5">
        <Header subtitle="Welcome" />

        <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
          <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
            {title}
          </h1>

          {location ? (
            <p className="mt-1 text-sm text-slate-600">{location}</p>
          ) : null}

          {paragraphs.length ? (
            <div className="mt-4 space-y-4 text-base leading-relaxed text-slate-700">
              {paragraphs.map((p, i) => (
                <p key={i}>{p}</p>
              ))}
            </div>
          ) : (
            <p className="mt-4 text-sm text-slate-600">
              (No welcome text found in <code className="text-slate-800">welcome_statement_2026.json</code>.)
            </p>
          )}

          {/* Sign-off */}
          <div className="mt-6 border-t border-slate-200 pt-4">
            <div className="text-sm font-semibold text-slate-900">
              {names.join(" & ")}
            </div>
            <div className="text-sm text-slate-600">{role}</div>
          </div>

          {/* Photos (small, side-by-side, mobile-safe) */}
          <div className="mt-4 grid grid-cols-2 gap-3">
            <div className="overflow-hidden rounded-xl bg-slate-50 ring-1 ring-slate-200">
              <img
                src="/photos/emma_davies.png"
                alt="Emma Davies"
                className="h-28 w-full object-cover"
                loading="lazy"
              />
            </div>

            <div className="overflow-hidden rounded-xl bg-slate-50 ring-1 ring-slate-200">
              <img
                src="/photos/laura_hissey.png"
                alt="Laura Hissey"
                className="h-28 w-full object-cover"
                loading="lazy"
              />
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
