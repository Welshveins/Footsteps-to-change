"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

type ParkingData = {
  parking?: {
    summary?: string;
    recommended_car_parks?: string[];
    accessibility_note?: string;
    links?: { label: string; url: string }[];
  };
};

const BRAND_TITLE = "Footsteps to Change 2026";

// From organiser email (APCOA Warwick conference parking link)
const PARKING_REGISTER_URL =
  "https://citycentre.apcoa.co.uk/bookingsummary/customerdetail/3992/warwick-university-car-parks/1268/conference-parking";

function Header() {
  return (
    <div className="flex items-center justify-between">
      <div className="flex items-center gap-3">
        <img
          src="/images/F2C_Appicon.png"
          alt=""
          className="h-8 w-8 rounded-md bg-white ring-1 ring-slate-200 object-contain"
        />
        <div className="leading-tight">
          <div className="text-sm font-semibold text-slate-900">
            {BRAND_TITLE}
          </div>
          <div className="text-xs text-slate-600">Parking</div>
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

function StepRow({
  text,
  highlight,
}: {
  text: string;
  highlight?: string;
}) {
  if (!highlight) {
    return <li className="text-sm text-slate-700 leading-relaxed">{text}</li>;
  }

  const parts = text.split(highlight);

  return (
    <li className="text-sm text-slate-700 leading-relaxed">
      {parts[0]}
      <span className="mx-1 inline-flex items-center rounded-lg bg-sky-50 px-2 py-0.5 font-semibold text-slate-900 ring-1 ring-slate-200">
        {highlight}
      </span>
      {parts.slice(1).join(highlight)}
    </li>
  );
}

function FreeDelegateParkingCard() {
  return (
    <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <div className="flex items-center gap-2">
        <span
          aria-hidden
          className="text-sky-700"
          style={{ fontSize: 18, lineHeight: 1 }}
        >
          🅿️
        </span>
        <h2 className="text-lg font-semibold tracking-tight text-slate-900">
          Free Delegate Parking
        </h2>
      </div>

      <p className="mt-3 text-sm leading-relaxed text-slate-700 whitespace-pre-wrap">
        {`All conference attendees are entitled to free parking on campus.

Car parks operate using Automatic Number Plate Recognition (ANPR), so your vehicle must be registered either before arrival or on the day.`}
      </p>

      <div className="my-4 h-px w-full bg-slate-200" />

      <h3 className="text-sm font-semibold text-slate-900">How to register</h3>

      <ul className="mt-2 list-disc space-y-2 pl-5">
        <StepRow text="Fill in your personal details and confirm the booking summary." />
        <StepRow text="Select arrival and departure times — we recommend allowing extra time." />
        <StepRow text="Use promotional code WOKJL to reduce the price to £0.00." highlight="WOKJL" />
        <StepRow text="Complete your booking to secure free parking." />
      </ul>

      <p className="mt-4 text-sm text-slate-700 leading-relaxed">
        Alternatively, you can register on arrival using the QR code displayed in
        meeting spaces.
      </p>

      <a
        href={PARKING_REGISTER_URL}
        target="_blank"
        rel="noreferrer"
        className="mt-4 inline-flex w-full items-center justify-between rounded-xl bg-sky-700 px-4 py-3 text-sm font-semibold text-white hover:bg-sky-800"
      >
        <span>Register Parking</span>
        <span aria-hidden className="text-white/90">
          ↗
        </span>
      </a>
    </div>
  );
}

export default function ParkingPage() {
  const [data, setData] = useState<ParkingData | null>(null);

  useEffect(() => {
    fetch("/data/getting_there_2026.json", { cache: "no-store" })
      .then((res) => res.json())
      .then((json) => setData(json))
      .catch(() => setData(null));
  }, []);

  const parking = data?.parking;

  return (
    <main className="min-h-screen bg-slate-50 px-4 py-6">
      <div className="mx-auto w-full max-w-md space-y-5">
        <Header />

        {/* NEW: Free parking / registration card (Swift parity) */}
        <FreeDelegateParkingCard />

        {/* Existing: parking notes from JSON (keep your detail) */}
        {(parking?.summary ||
          (parking?.recommended_car_parks?.length ?? 0) > 0 ||
          parking?.accessibility_note) && (
          <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
            <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
              Parking information
            </h1>

            {parking?.summary ? (
              <p className="mt-3 text-sm leading-relaxed text-slate-700 whitespace-pre-wrap">
                {parking.summary}
              </p>
            ) : null}

            {Array.isArray(parking?.recommended_car_parks) &&
            parking.recommended_car_parks.length > 0 ? (
              <div className="mt-4">
                <h2 className="text-sm font-semibold text-slate-900">
                  Recommended car parks
                </h2>
                <ul className="mt-2 list-disc pl-5 text-sm text-slate-700 space-y-1">
                  {parking.recommended_car_parks.map((cp, i) => (
                    <li key={i}>{cp}</li>
                  ))}
                </ul>
              </div>
            ) : null}

            {parking?.accessibility_note ? (
              <div className="mt-4 text-sm text-slate-700 whitespace-pre-wrap">
                {parking.accessibility_note}
              </div>
            ) : null}
          </div>
        )}

        {/* Map (must stay) */}
        <div className="rounded-2xl bg-white p-4 shadow-sm ring-1 ring-slate-200">
          <img
            src="/images/warwick_parking_map_1200.png"
            alt="Campus parking map"
            className="w-full rounded-xl object-contain"
          />
        </div>

        {/* External links from JSON (leave as-is, even if a provider link 404s) */}
        {Array.isArray(parking?.links) && parking.links.length > 0 ? (
          <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200 space-y-3">
            {parking.links.map((link, i) => (
              <a
                key={i}
                href={link.url}
                target="_blank"
                rel="noreferrer"
                className="block rounded-xl bg-sky-50 px-4 py-3 text-sm font-semibold text-slate-900 ring-1 ring-slate-200 hover:bg-sky-100"
              >
                {link.label}
              </a>
            ))}
          </div>
        ) : null}

        <div className="h-4" />
      </div>
    </main>
  );
}