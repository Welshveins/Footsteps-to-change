import Link from "next/link";
import { promises as fs } from "fs";
import path from "path";

type LinkItem = { label: string; url: string };

type GettingThere = {
  id?: string;
  title?: string;
  subtitle?: string;
  updated_for?: string;

  venue?: {
    name?: string;
    postcode?: string;
    notes?: string[];
    links?: LinkItem[];
  };

  travel?: Array<{
    mode?: string; // Train / Bus / Taxi / Car
    summary?: string;
    details?: string[];
    links?: LinkItem[];
  }>;

  parking?: {
    summary?: string;
    recommended_car_parks?: string[];
    accessibility_note?: string;
    links?: LinkItem[]; // keep even if 404
  };
};

const BRAND_TITLE = "Footsteps to Change 2026";

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

function Card({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <h2 className="text-base font-semibold text-slate-900">{title}</h2>
      <div className="mt-3 space-y-3 text-sm leading-relaxed text-slate-700">
        {children}
      </div>
    </section>
  );
}

function BulletList({ items }: { items?: string[] }) {
  const list = (items ?? []).filter((x) => typeof x === "string" && x.trim().length);
  if (!list.length) return null;

  return (
    <ul className="list-disc space-y-1 pl-5">
      {list.map((t, i) => (
        <li key={i}>{t}</li>
      ))}
    </ul>
  );
}

function LinkButtons({ links }: { links?: LinkItem[] }) {
  const list = Array.isArray(links)
    ? links.filter((l) => l && typeof l.label === "string" && typeof l.url === "string")
    : [];

  if (!list.length) return null;

  return (
    <div className="space-y-2 pt-1">
      {list.map((l, i) => (
        <a
          key={`${l.url}-${i}`}
          href={l.url}
          target="_blank"
          rel="noreferrer"
          className="inline-flex w-full items-center justify-between rounded-xl bg-sky-50 px-4 py-3 text-sm font-semibold text-slate-900 ring-1 ring-slate-200 hover:bg-sky-100"
        >
          <span>{l.label}</span>
          <span aria-hidden className="text-slate-600">
            ↗
          </span>
        </a>
      ))}
    </div>
  );
}

function modeKey(mode?: string) {
  return (mode ?? "").trim().toLowerCase();
}

export default async function VenuePage() {
  let data: GettingThere | null = null;

  try {
    const filePath = path.join(
      process.cwd(),
      "public",
      "data",
      "getting_there_2026.json"
    );
    const raw = await fs.readFile(filePath, "utf8");
    data = JSON.parse(raw) as GettingThere;
  } catch {
    data = null;
  }

  if (!data) {
    return (
      <main className="min-h-screen bg-slate-50 px-4 py-6">
        <div className="mx-auto w-full max-w-md space-y-5">
          <div className="flex items-center justify-between">
            <LogoMark subtitle="Venue" />
            <Link
              href="/"
              className="text-sm font-medium text-slate-600 hover:text-slate-900"
            >
              Home
            </Link>
          </div>

          <Card title="Couldn’t load venue details">
            <p className="text-slate-600">
              I couldn’t read{" "}
              <code className="text-slate-800">public/data/getting_there_2026.json</code>.
            </p>
          </Card>
        </div>
      </main>
    );
  }

  const venue = data.venue ?? {};
  const parking = data.parking ?? {};
  const travel = Array.isArray(data.travel) ? data.travel : [];

  const byMode = new Map<string, (typeof travel)[number]>();
  for (const t of travel) {
    const k = modeKey(t?.mode);
    if (k) byMode.set(k, t);
  }

  const train = byMode.get("train");
  const bus = byMode.get("bus");
  const taxi = byMode.get("taxi");
  const car = byMode.get("car");

  return (
    <main className="min-h-screen bg-slate-50 px-4 py-6">
      <div className="mx-auto w-full max-w-md space-y-5">
        {/* Header bar */}
        <div className="flex items-center justify-between">
          <LogoMark subtitle="Venue" />
          <Link
            href="/"
            className="text-sm font-medium text-slate-600 hover:text-slate-900"
          >
            Home
          </Link>
        </div>

        {/* Title */}
        <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
          <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
            {data.title ?? "Getting there"}
          </h1>
          {data.subtitle ? (
            <p className="mt-2 text-sm text-slate-600">{data.subtitle}</p>
          ) : null}
          {data.updated_for ? (
            <p className="mt-1 text-xs text-slate-500">{data.updated_for}</p>
          ) : null}
        </div>

        {/* ORDER: The Oculus */}
        <Card title={venue.name ?? "The Oculus, University of Warwick"}>
          {venue.postcode ? (
            <p>
              <span className="font-semibold text-slate-900">Postcode:</span>{" "}
              {venue.postcode}
            </p>
          ) : null}
          <BulletList items={venue.notes} />
          <LinkButtons links={venue.links} />
        </Card>

        {/* ORDER: University of Warwick */}
        <Card title="University of Warwick">
          <p className="text-slate-700">
            Central Campus venues (including The Oculus) are signposted off Gibbet
            Hill Road.
          </p>
        </Card>

        {/* ORDER: Parking */}
        <Card title="Parking">
          {parking.summary ? (
            <p className="whitespace-pre-wrap">{parking.summary}</p>
          ) : null}

          {Array.isArray(parking.recommended_car_parks) &&
          parking.recommended_car_parks.length ? (
            <>
              <p className="font-semibold text-slate-900">Recommended car parks</p>
              <BulletList items={parking.recommended_car_parks} />
            </>
          ) : null}

          {parking.accessibility_note ? (
            <p className="whitespace-pre-wrap">{parking.accessibility_note}</p>
          ) : null}

          {/* keep link even if it 404s (as discussed) */}
          <LinkButtons links={parking.links} />

          <div className="pt-2">
            <Link
              href="/parking"
              className="inline-flex w-full items-center justify-between rounded-xl bg-sky-50 px-4 py-3 text-sm font-semibold text-slate-900 ring-1 ring-slate-200 hover:bg-sky-100"
            >
              <span>Open Parking Map</span>
              <span aria-hidden className="text-slate-600">
                →
              </span>
            </Link>
          </div>
        </Card>

        {/* ORDER: Train */}
        <Card title="Train">
          {train?.summary ? (
            <p className="whitespace-pre-wrap">{train.summary}</p>
          ) : null}
          <BulletList items={train?.details} />
          <LinkButtons links={train?.links} />
        </Card>

        {/* ORDER: Bus */}
        <Card title="Bus">
          {bus?.summary ? <p className="whitespace-pre-wrap">{bus.summary}</p> : null}
          <BulletList items={bus?.details} />
          <LinkButtons links={bus?.links} />
        </Card>

        {/* ORDER: Taxi */}
        <Card title="Taxi">
          {taxi?.summary ? (
            <p className="whitespace-pre-wrap">{taxi.summary}</p>
          ) : null}
          <BulletList items={taxi?.details} />
          <LinkButtons links={taxi?.links} />
        </Card>

        {/* ORDER: Car */}
        <Card title="Car">
          {car?.summary ? <p className="whitespace-pre-wrap">{car.summary}</p> : null}
          <BulletList items={car?.details} />
          <LinkButtons links={car?.links} />
        </Card>

        <div className="h-4" />
      </div>
    </main>
  );
}