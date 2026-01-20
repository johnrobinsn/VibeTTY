# ConnectBot URLs to Replace

## Summary

| URL | Purpose | Files Affected |
|-----|---------|----------------|
| `https://connectbot.org/bug` | Bug reporting link in logs viewer | 12 string resource files + 40+ locale .po files |
| `no-reply+translations@connectbot.org` | Git author email for translations bot | 1 GitHub workflow file |

---

## Details

### 1. Bug Reporting URL

**Current:** `https://connectbot.org/bug`

**Used in:** `logs_bug_report_info` string - shown in the log viewer to direct users where to report bugs.

**Files to update:**

String resources (values/strings.xml):
- `app/src/main/res/values/strings.xml:1199`
- `app/src/main/res/values-cs/strings.xml:450`
- `app/src/main/res/values-de/strings.xml:450`
- `app/src/main/res/values-es/strings.xml:450`
- `app/src/main/res/values-fr/strings.xml:450`
- `app/src/main/res/values-it/strings.xml:450`
- `app/src/main/res/values-ja/strings.xml:450`
- `app/src/main/res/values-ko/strings.xml:450`
- `app/src/main/res/values-pl/strings.xml:450`
- `app/src/main/res/values-pt-rBR/strings.xml:450`
- `app/src/main/res/values-ru/strings.xml:450`

Locale .po files (in `app/locale/fortune/`):
- af.po, ar.po, be.po, bg.po, ca.po, cs.po, da.po, de.po, el.po, en_CA.po, en_GB.po
- es.po, eu.po, fa.po, fi.po, fortune.pot, fr.po, gl.po, he.po, hr.po, hu.po, id.po
- is.po, it.po, ja.po, ka.po, ko.po, lo.po, lt.po, lv.po, mk.po, nb.po, ne.po, nl.po
- pl.po, pt.po, pt_BR.po, ro.po, ru.po, sk.po, sl.po, sr.po, sv.po, ta.po, th.po
- tk.po, tr.po, uk.po, vi.po, zh_CN.po, zh_HK.po, zh_TW.po

---

### 2. Translations Bot Email

**Current:** `no-reply+translations@connectbot.org`

**Used in:** Git commit author for automated translation imports

**File to update:**
- `.github/workflows/translations-import.yml:65`

---

## Suggested Replacements

| Current | Suggested Replacement |
|---------|----------------------|
| `https://connectbot.org/bug` | `https://github.com/johnrobinsn/VibeTTY/issues` |
| `no-reply+translations@connectbot.org` | `no-reply+translations@<your-domain>` or a noreply GitHub email |
