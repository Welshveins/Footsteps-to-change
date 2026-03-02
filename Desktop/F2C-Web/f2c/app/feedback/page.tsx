"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

const BRAND_TITLE = "Footsteps to Change 2026";

const FORM_URL =
  "https://forms.office.com/Pages/ResponsePage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAANAAQ_9woZUOVlETzBQT0EwNFRHWE9HTjdOQVhOV1c1US4u";

function LogoMark() {
  return (
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
        <div className="text-xs text-slate-600">Feedback</div>
      </div>
    </div>
  );
}

export default function FeedbackPage() {
  const [confirmed, setConfirmed] = useState(false);

  useEffect(() => {
    const stored = localStorage.getItem("feedback_complete");
    if (stored === "true") setConfirmed(true);
  }, []);

  const handleToggle = () => {
    const newValue = !confirmed;
    setConfirmed(newValue);
    localStorage.setItem("feedback_complete", String(newValue));
  };

  return (
    <main className="min-h-screen bg-slate-50 px-4 py-6">
      <div className="mx-auto w-full max-w-md space-y-5">
        {/* Header */}
        <div className="flex items-center justify-between">
          <LogoMark />
          <Link
            href="/"
            className="text-sm font-medium text-slate-600 hover:text-slate-900"
          >
            Home
          </Link>
        </div>

        {/* Main Card */}
        <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200 space-y-4">
          <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
            Conference Feedback
          </h1>

          <p className="text-sm text-slate-700 leading-relaxed">
            Please complete the feedback form. Once completed, your Certificate
            will unlock.
          </p>

          <p className="text-xs text-slate-600 leading-relaxed">
            The feedback form opens securely in Microsoft Forms. Responses are
            used only for conference evaluation and service improvement.
          </p>

          <a
            href={FORM_URL}
            target="_blank"
            rel="noreferrer"
            className="block w-full text-center rounded-xl bg-sky-600 px-4 py-3 text-sm font-semibold text-white hover:bg-sky-700 transition"
          >
            Open Feedback Form
          </a>
        </div>

        {/* Confirmation Toggle */}
        <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
          <label className="flex items-center justify-between cursor-pointer">
            <span className="text-sm text-slate-900">
              I have completed the feedback form
            </span>
            <input
              type="checkbox"
              checked={confirmed}
              onChange={handleToggle}
              className="h-5 w-5 accent-sky-600"
            />
          </label>

          {confirmed && (
            <p className="mt-3 text-sm font-medium text-green-600">
              Certificate unlocked ✓
            </p>
          )}
        </div>
      </div>
    </main>
  );
}