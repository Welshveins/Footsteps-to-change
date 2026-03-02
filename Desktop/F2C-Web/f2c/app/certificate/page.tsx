"use client";

import Link from "next/link";
import { useState } from "react";

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

export default function CertificatePage() {
  const [unlocked, setUnlocked] = useState(false);
  const [name, setName] = useState("");
  const [organisation, setOrganisation] = useState("");

  return (
    <main className="min-h-screen bg-slate-50 px-4 py-6">
      <div className="mx-auto w-full max-w-md space-y-5">
        <div className="flex items-center justify-between">
          <LogoMark subtitle="Certificate of Attendance" />
          <Link href="/" className="text-sm text-slate-600 hover:text-slate-900">
            Home
          </Link>
        </div>

        {!unlocked ? (
          <div className="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200 space-y-4">
            <h1 className="text-xl font-semibold">Certificate Locked</h1>

            <p className="text-sm text-slate-600">
              Please complete the feedback form. Once completed, your Certificate will unlock.
            </p>

            <label className="flex items-center gap-3 text-sm">
              <input
                type="checkbox"
                checked={unlocked}
                onChange={(e) => setUnlocked(e.target.checked)}
                className="h-4 w-4"
              />
              I confirm I have completed the feedback form
            </label>
          </div>
        ) : (
          <>
            {/* Form */}
            <div className="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200 space-y-4">
              <h1 className="text-xl font-semibold">Build your Certificate</h1>

              <div className="space-y-3">
                <div>
                  <label className="block text-sm font-medium text-slate-700">
                    Your name
                  </label>
                  <input
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="mt-1 w-full rounded-xl border border-slate-300 px-3 py-2 text-sm"
                    placeholder="Full name"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700">
                    Organisation / Location
                  </label>
                  <input
                    value={organisation}
                    onChange={(e) => setOrganisation(e.target.value)}
                    className="mt-1 w-full rounded-xl border border-slate-300 px-3 py-2 text-sm"
                    placeholder="Organisation"
                  />
                </div>
              </div>
            </div>

            {/* Certificate Preview */}
            <div className="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200 text-center space-y-4">
<div className="flex justify-center">
  <img
    src="/images/F2C_Appicon.png"
    alt="Footsteps to Change logo"
    className="h-10 w-10 object-contain"
  />
</div>

<div className="text-xs tracking-widest text-slate-500 uppercase">
                Certificate of Attendance
              </div>

              <div className="text-2xl font-semibold text-slate-900">
                {name || "Your Name"}
              </div>

              <div className="text-sm text-slate-600">
                has attended
              </div>

              <div className="text-lg font-semibold text-sky-600">
  Footsteps to Change Conference 2026
</div>

              <div className="text-sm text-slate-600">
                University of Warwick
              </div>

              {organisation && (
                <div className="text-sm text-slate-700 pt-2">
                  {organisation}
                </div>
              )}

              <div className="pt-6 grid grid-cols-2 gap-6 items-end">
                <div className="text-center">
                  <img
                    src="/images/emma_signature.png"
                    alt="Emma Davies signature"
                    className="mx-auto h-12 object-contain"
                  />
                  <div className="mt-2 text-sm font-medium">
                    Emma Davies
                  </div>
                  <div className="text-xs text-slate-600">
                    Conference Organiser
                  </div>
                </div>

                <div className="text-center">
                  <img
                    src="/images/laura_signature.png"
                    alt="Laura Hissey signature"
                    className="mx-auto h-12 object-contain"
                  />
                  <div className="mt-2 text-sm font-medium">
                    Laura Hissey
                  </div>
                  <div className="text-xs text-slate-600">
                    Conference Organiser
                  </div>
                </div>
              </div>
            </div>
          </>
        )}
      </div>
    </main>
  );
}