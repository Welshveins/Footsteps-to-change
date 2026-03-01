import Link from "next/link";

const tiles = [
  { href: "/welcome", title: "Welcome", subtitle: "Intro", icon: "👋" },
  { href: "/programme", title: "Programme", subtitle: "Schedule", icon: "🗓️" },
  { href: "/speakers", title: "Speakers", subtitle: "Who's speaking", icon: "👥" },
  { href: "/venue", title: "Venue", subtitle: "Directions", icon: "📍" },
  { href: "/parking", title: "Parking", subtitle: "Free parking", icon: "🚗" },
  { href: "/floorplan", title: "Floor Plan", subtitle: "Rooms", icon: "🧭" },
  { href: "/feedback", title: "Feedback", subtitle: "Form", icon: "✅" },
  { href: "/certificate", title: "Certificate", subtitle: "Preview + share", icon: "📄" },
  { href: "/abstracts", title: "Abstracts", subtitle: "Browse", icon: "🔎" },
  { href: "/sponsors", title: "Sponsors", subtitle: "Thanks", icon: "🤝" },
];

function Header() {
  return (
    <div className="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <div className="flex items-center gap-3">
        <img
          src="/images/F2C_Appicon.png"
          alt="Footsteps to Change"
          className="h-9 w-9 rounded-lg bg-white ring-1 ring-slate-200 object-contain"
        />
        <div className="leading-tight">
          <div className="text-sm font-semibold text-slate-900">
            Footsteps to Change
          </div>
          <div className="text-xs text-slate-600">Conference 2026</div>
        </div>
      </div>
    </div>
  );
}

export default function Home() {
  return (
    <main className="min-h-screen bg-slate-100 px-4 py-6">
      <div className="mx-auto w-full max-w-md space-y-4">
        <Header />

        <div className="grid grid-cols-2 gap-3">
          {tiles.map((t) => (
            <Link
              key={t.href}
              href={t.href}
              className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200 active:scale-[0.99]"
            >
              <div className="flex items-start justify-between gap-2">
                <div>
                  <div className="text-base font-semibold text-slate-900">
                    {t.title}
                  </div>
                  <div className="mt-1 text-sm text-slate-600">
                    {t.subtitle}
                  </div>
                </div>
                <div className="text-lg" aria-hidden>
                  {t.icon}
                </div>
              </div>
            </Link>
          ))}
        </div>

        <div className="rounded-2xl bg-white p-4 text-xs text-slate-500 shadow-sm ring-1 ring-slate-200">
          Tip: add this web app to your Home Screen for all-day access.
        </div>
      </div>
    </main>
  );
}