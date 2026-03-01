"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

type Session = {
  id: string;
  start: string;
  end: string;
  type: string;
  title: string;
  speakers: string[];
  organisation?: string;
  chair?: string;
  track?: string;
  notes?: string;
};

type ProgrammeData = {
  sessions: Session[];
};

export default function ProgrammePage() {
  const [sessions, setSessions] = useState<Session[]>([]);
  const [expandedId, setExpandedId] = useState<string | null>(null);

  useEffect(() => {
    fetch("/data/programme.json")
      .then((res) => res.json())
      .then((data: ProgrammeData) => {
        setSessions(data.sessions || []);
      })
      .catch(() => {
        setSessions([]);
      });
  }, []);

  return (
    <main className="min-h-screen bg-slate-50 px-4 py-6">
      <div className="mx-auto w-full max-w-md space-y-5">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <img
              src="/images/F2C_Appicon.png"
              alt=""
              className="h-8 w-8 rounded-md bg-white ring-1 ring-slate-200 object-contain"
            />
            <div className="leading-tight">
              <div className="text-sm font-semibold text-slate-900">
                Footsteps to Change 2026
              </div>
              <div className="text-xs text-slate-600">Programme</div>
            </div>
          </div>

          <Link
            href="/"
            className="text-sm font-medium text-slate-600 hover:text-slate-900"
          >
            Home
          </Link>
        </div>

        {/* Page title */}
        <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
          <h1 className="text-2xl font-semibold text-slate-900">
            Conference Programme
          </h1>
          <p className="mt-2 text-sm text-slate-600">
            Tap a session to view full details.
          </p>
        </div>

        {/* Sessions */}
        {sessions.map((session) => {
          const isOpen = expandedId === session.id;

          return (
            <div
              key={session.id}
              className="rounded-2xl bg-white shadow-sm ring-1 ring-slate-200"
            >
              <button
                onClick={() =>
                  setExpandedId(isOpen ? null : session.id)
                }
                className="w-full p-4 text-left"
              >
                <div className="flex justify-between items-start gap-3">
                  <div>
                    <div className="text-sm font-semibold text-slate-900">
                      {session.start} – {session.end}
                    </div>
                    <div className="mt-1 text-base font-medium text-slate-800">
                      {session.title}
                    </div>
                  </div>

                  <div className="text-slate-500 text-sm">
                    {isOpen ? "−" : "+"}
                  </div>
                </div>

                {/* Only show when collapsed */}
                {!isOpen && (
                  <div className="mt-2 text-xs text-slate-500">
                    Tap to expand
                  </div>
                )}
              </button>

              {/* Expanded content */}
              {isOpen && (
                <div className="px-4 pb-4 pt-0 space-y-3 text-sm text-slate-700 border-t border-slate-200">
                  {session.type && (
                    <div>
                      <span className="font-semibold">Type: </span>
                      {session.type}
                    </div>
                  )}

                  {session.speakers && session.speakers.length > 0 && (
                    <div>
                      <span className="font-semibold">Speakers: </span>
                      {session.speakers.join(", ")}
                    </div>
                  )}

                  {session.organisation && (
                    <div>
                      <span className="font-semibold">Organisation: </span>
                      {session.organisation}
                    </div>
                  )}

                  {session.chair && (
                    <div>
                      <span className="font-semibold">Chair: </span>
                      {session.chair}
                    </div>
                  )}

                  {session.track && (
                    <div>
                      <span className="font-semibold">Track: </span>
                      {session.track}
                    </div>
                  )}

                  {session.notes && (
                    <div>
                      <span className="font-semibold">Notes: </span>
                      {session.notes}
                    </div>
                  )}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </main>
  );
}