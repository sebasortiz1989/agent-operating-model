# Designer reference — THE PREVIEW

Read when building or changing the preview, and **before writing any generator**.

**Why it exists.** In a generative design tool, changing one thing re-renders the whole
canvas — slow, and expensive in tokens. **Per-screen HTML files let one page be fixed
without touching the other forty.** That is an authoring economy, not a presentation
nicety. It is also how the design gets *read*: opening one screen beside the code it
specifies, instead of scrolling a canvas past thirteen others.

## The two invariants — everything else is a choice

1. **One screen, one file** — openable, readable and fixable on its own.
2. **An index that links them**, opening from the filesystem. No dev server, no build
   step, no network.

A generator, a canvas, per-section indexes, embedded fonts — all useful, all optional.
A project with six screens, no canvas and a hand-written index is running this
correctly. **Adopt the generator the day a global change first costs N edits**, not
before.

```
DesignDocs/<date>_<topic>/<canvas>.html      the SOURCE, if the project has a canvas
scripts/build-previews.py                    optional: canvas → Preview/
DesignDocs/Preview/index.html                every screen
DesignDocs/Preview/01-<screen>.html          one screen, opens on a double click
```

## One source, and it is named

**If previews are generated, nothing in `Preview/` is ever hand-edited** — change the
source, rerun. A file patched by hand is reverted by the next build, and in the
meantime the canvas — which every later session reads as truth — is quietly wrong.
Anything a preview needs that the canvas cannot express goes **in the script**, where
it applies to every view and survives. If previews are hand-authored, the per-screen
files *are* the source and no script may write over them. **Pick one and say so** in
`DesignDocs/README.md`.

## What a generator needs from a canvas — only two things

1. **A stable per-screen anchor** a regex can find — an `id`, a data attribute, or a
   comment. It must survive editing, because it is what keeps filenames stable.
2. **One balanced fixed-width root element per screen**, so the extractor can walk
   depth and cut exactly that screen out. Anchor on the width, not the surrounding
   style.

**Three things that break a naive extractor, all found by measuring real canvases:**

- **Some "screens" are fragments** — a dialog, a popover, a comparison strip of several
  fixed-width children side by side. "First fixed-width div after the anchor" cuts one
  column out of a comparison and loses the rest.
- **Numbering is not always contiguous.** Keep the slug map explicit; a derived
  filename invents a gap.
- **A canvas may be a running program, not a drawing.** Some design-tool exports build
  their content at load time — template loops, `{{ }}` bindings, one shared data block
  placed *after* every screen, resolved by a runtime script. **Cut a screen out and you
  get a skeleton of loops that never run.** Before writing the extractor, count the
  bindings; if there are hundreds, every generated page must carry the data block and
  the runtime beside it, and the "one self-contained file" property is gone. **Say so
  in the README rather than discovering it in the room.**

## What the generator does to each screen

| Step | Why |
|---|---|
| Turn the fixed width into a floor (`min-width`) | so the page fills a window instead of sitting in a column |
| Unpin an `absolute` header to `sticky` | a canvas draws it absolute so the whole board reads in one scroll |
| Inline assets as `data:` URIs, MIME read from the extension | one file opens anywhere; a hardcoded MIME survives a browser and fails a print pipeline |
| Give images dimensions from their own header | no reflow as they load |
| Embed the fonts the canvas actually uses | a preview that needs the network breaks in the room |
| Open phone-frame scrollers | `overflow:hidden` rectangles hide real content below the fold |
| Add what a page has and a canvas never does | `<title>`, `lang`, viewport, `color-scheme`, focus rings |

**Every generated file carries a one-line banner: generated, never hand-edited, not
the product.** So does the script's docstring.

## Before you say it is done

Rebuild, then check — measured, not eyeballed: every file opened and rendered; every
index link resolves; contrast computed on the pairs the spec defines; file sizes
reported — a 10 MB page that has to open on a projector is a finding.
