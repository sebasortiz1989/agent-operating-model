# DesignDocs — the design of record

**Owner: `designer`.** The manager reads freely and lands the result — the State paste,
the session record, the queue row — but does not edit what is here.

## Nothing here is the product

Everything in this folder is a *reference the product is built against*. A canvas is not
the UI, a spec is not the UI, and a generated preview page is not the UI.

## Layout

```
DesignDocs/
  <date>_brief_<topic>.md          the brief sent to a design session
  <date>_review_<topic>.md         the review — AT THIS LEVEL, never inside a session folder
  <date>_<topic>/                  one session's delivery — THE SOURCE, if a canvas is used
  Preview/                         GENERATED, never hand-edited — or hand-authored, never
                                   generated over. This README says which. Delete the
                                   other sentence.
```

**Reviews sit at the root.** A later delivery replaces a session folder wholesale, and a
review filed inside it dies with it.

## The one thing this file must say

**Which is the source of truth for a screen — the canvas, or the per-screen file?**
State it here, in one line, before the first preview exists:

> Source: _(the canvas at `<path>` / the files in `Preview/`)_. The other is output.

A fix that lands in the file that gets regenerated tonight is the failure this line
prevents.
