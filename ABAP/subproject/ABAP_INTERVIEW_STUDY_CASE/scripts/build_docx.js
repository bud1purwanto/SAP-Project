// Gabung docs/00..08 (Markdown) menjadi satu dokumen Word.
// Usage: NODE_PATH=<folder node_modules docx+marked> node build_docx.js <docs_dir> <out.docx>
const fs = require('fs');
const path = require('path');
const { marked } = require('marked');
const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, Table, TableRow, TableCell,
  WidthType, ShadingType, BorderStyle, AlignmentType, LevelFormat, PageBreak,
  Footer, Header, PageNumber, TabStopType,
} = require('docx');

const [docsDir, outFile] = process.argv.slice(2);
const FILES = ['00_INDEX.md', '01_ALV.md', '02_BAPI_vs_BDC.md', '03_BADI.md', '04_USER_EXIT.md',
  '05_SMARTFORMS.md', '06_HASIL_UJI.md', '07_IDOC.md', '08_ODATA.md'];

const FONT = 'Arial';
const MONO = 'Courier New';
const PAGE_W = 11906, MARGIN = 1134;           // A4, margin 0.79 in
const CONTENT_W = PAGE_W - 2 * MARGIN;
const ACCENT = '1F4E79';

const ent = s => String(s || '')
  .replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>')
  .replace(/&quot;/g, '"').replace(/&#39;/g, "'");

// ---------- inline ----------
function inline(tokens, base = {}) {
  const out = [];
  for (const t of tokens || []) {
    switch (t.type) {
      case 'strong': out.push(...inline(t.tokens, { ...base, bold: true })); break;
      case 'em': out.push(...inline(t.tokens, { ...base, italics: true })); break;
      case 'del': out.push(...inline(t.tokens, { ...base, strike: true })); break;
      case 'codespan':
        out.push(new TextRun({ ...base, text: ent(t.text), font: MONO, size: base.size ? base.size - 2 : 19, color: '8B1A1A' }));
        break;
      case 'link': out.push(...inline(t.tokens, { ...base, color: ACCENT })); break;
      case 'br': out.push(new TextRun({ break: 1 })); break;
      case 'text':
        if (t.tokens && t.tokens.length) out.push(...inline(t.tokens, base));
        else out.push(new TextRun({ ...base, text: ent(t.text) }));
        break;
      case 'escape': out.push(new TextRun({ ...base, text: ent(t.text) })); break;
      case 'html': out.push(new TextRun({ ...base, text: ent(t.text) })); break;
      default: out.push(new TextRun({ ...base, text: ent(t.raw || t.text || '') }));
    }
  }
  return out;
}

// ---------- blocks ----------
let listInstance = 0;
const HEAD = { 1: HeadingLevel.HEADING_1, 2: HeadingLevel.HEADING_2, 3: HeadingLevel.HEADING_3, 4: HeadingLevel.HEADING_4 };

function codeBlock(text) {
  const lines = ent(text).split('\n');
  return lines.map((ln, i) => new Paragraph({
    spacing: { before: i === 0 ? 80 : 0, after: i === lines.length - 1 ? 120 : 0, line: 240 },
    shading: { type: ShadingType.CLEAR, color: 'auto', fill: 'F3F3F3' },
    border: {
      left: { style: BorderStyle.SINGLE, size: 12, color: 'A6A6A6', space: 6 },
    },
    indent: { left: 120 },
    children: [new TextRun({ text: ln.length ? ln : ' ', font: MONO, size: 15 })],
  }));
}

function table(t) {
  const ncol = t.header.length;
  const weight = Array(ncol).fill(0).map((_, c) => {
    const lens = [t.header[c].text, ...t.rows.map(r => (r[c] ? r[c].text : ''))].map(s => ent(s).length);
    return Math.min(Math.max(Math.max(...lens), 9), 55);
  });
  const sum = weight.reduce((a, b) => a + b, 0);
  const widths = weight.map(w => Math.floor(CONTENT_W * w / sum));
  widths[ncol - 1] += CONTENT_W - widths.reduce((a, b) => a + b, 0);
  const border = { style: BorderStyle.SINGLE, size: 4, color: 'BFBFBF' };
  const borders = { top: border, bottom: border, left: border, right: border };
  const cell = (c, i, hdr) => new TableCell({
    width: { size: widths[i], type: WidthType.DXA },
    borders,
    margins: { top: 50, bottom: 50, left: 80, right: 80 },
    shading: hdr ? { type: ShadingType.CLEAR, color: 'auto', fill: 'DCE6F1' } : undefined,
    children: [new Paragraph({
      spacing: { before: 0, after: 0 },
      children: inline(c ? c.tokens : [], { size: 17, bold: hdr || undefined }),
    })],
  });
  return new Table({
    width: { size: CONTENT_W, type: WidthType.DXA },
    columnWidths: widths,
    rows: [
      new TableRow({ tableHeader: true, children: t.header.map((c, i) => cell(c, i, true)) }),
      ...t.rows.map(r => new TableRow({ children: Array(ncol).fill(0).map((_, i) => cell(r[i], i, false)) })),
    ],
  });
}

function list(l, level, out) {
  const inst = ++listInstance;
  for (const item of l.items) {
    let first = true;
    for (const b of item.tokens) {
      if (b.type === 'list') { list(b, level + 1, out); continue; }
      if (b.type === 'code') { out.push(...codeBlock(b.text)); continue; }
      if (b.type === 'table') { out.push(table(b)); continue; }
      const toks = b.tokens || [{ type: 'text', text: b.text || '' }];
      const kids = [];
      if (first && item.task) kids.push(new TextRun({ text: item.checked ? '☑ ' : '☐ ' }));
      kids.push(...inline(toks));
      out.push(new Paragraph({
        numbering: first
          ? { reference: l.ordered ? 'num' : 'bullet', level: Math.min(level, 2), instance: inst }
          : undefined,
        indent: first ? undefined : { left: 720 * (level + 1) },
        spacing: { before: 0, after: 60 },
        children: kids,
      }));
      first = false;
    }
  }
}

function blocks(tokens, out, ctx = {}) {
  for (const t of tokens) {
    switch (t.type) {
      case 'heading': {
        const depth = Math.min(t.depth, 4);
        out.push(new Paragraph({ heading: HEAD[depth], children: inline(t.tokens), pageBreakBefore: depth === 1 && ctx.notFirst }));
        if (depth === 1) ctx.notFirst = true;
        break;
      }
      case 'paragraph':
        out.push(new Paragraph({ spacing: { after: 120 }, children: inline(t.tokens) }));
        break;
      case 'blockquote': quote(t.tokens, out); break;
      case 'list': list(t, 0, out); break;
      case 'code': out.push(...codeBlock(t.text)); break;
      case 'table': out.push(table(t)); out.push(new Paragraph({ spacing: { after: 80 }, children: [] })); break;
      case 'hr':
        out.push(new Paragraph({ border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: 'BFBFBF', space: 1 } }, children: [] }));
        break;
      case 'space': break;
      default:
        if (t.text) out.push(new Paragraph({ children: [new TextRun(ent(t.text))] }));
    }
  }
}

function quotePara(children) {
  return new Paragraph({
    shading: { type: ShadingType.CLEAR, color: 'auto', fill: 'EEF3F8' },
    border: { left: { style: BorderStyle.SINGLE, size: 18, color: '5B9BD5', space: 8 } },
    indent: { left: 200 }, spacing: { after: 40 }, children,
  });
}
function quote(tokens, out) {
  for (const t of tokens) {
    if (t.type === 'paragraph') out.push(quotePara(inline(t.tokens, { size: 19 })));
    else if (t.type === 'list') {
      t.items.forEach((it, i) => {
        const txt = it.tokens.filter(x => x.type !== 'list');
        const toks = txt.flatMap(x => x.tokens || [{ type: 'text', text: x.text || '' }]);
        out.push(quotePara([new TextRun({ text: (t.ordered ? (i + 1) + '. ' : '• '), size: 19 }), ...inline(toks, { size: 19 })]));
        const sub = it.tokens.filter(x => x.type === 'list');
        if (sub.length) quote(sub, out);
      });
    } else if (t.type === 'table') { out.push(table(t)); }
    else if (t.type === 'code') out.push(...codeBlock(t.text));
    else if (t.type === 'blockquote') quote(t.tokens, out);
    else if (t.type !== 'space') out.push(quotePara(inline([{ type: 'text', text: t.text || t.raw || '' }], { size: 19 })));
  }
}

// ---------- dokumen ----------
const body = [];
// Halaman judul
body.push(new Paragraph({ spacing: { before: 2400, after: 240 }, alignment: AlignmentType.CENTER,
  children: [new TextRun({ text: 'Study Case Teknik ABAP ECC 6', font: FONT, size: 52, bold: true, color: ACCENT })] }));
body.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 480 },
  children: [new TextRun({ text: 'Persiapan Interview — Hands-on berbasis program nyata', font: FONT, size: 28, color: '404040' })] }));
const modules = [
  ['00', 'Index & aturan latihan'], ['01', 'ALV'], ['02', 'BAPI vs BDC'], ['03', 'BAdI'],
  ['04', 'User Exit'], ['05', 'SmartForms'], ['06', 'Hasil uji sandbox-new & S/4HANA'], ['07', 'IDoc'], ['08', 'OData'],
];
for (const [n, t] of modules) {
  body.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 60 },
    children: [new TextRun({ text: `${n}   ${t}`, font: FONT, size: 24 })] }));
}
body.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 720 },
  children: [new TextRun({ text: 'SAP ECC 6.0 EHP6 · ABAP 7.31 · S/4HANA 1909 (OData)', font: FONT, size: 20, color: '595959' })] }));
body.push(new Paragraph({ alignment: AlignmentType.CENTER,
  children: [new TextRun({ text: 'Versi 26 November 2026', font: FONT, size: 20, color: '595959' })] }));

const ctx = { notFirst: true };
for (const f of FILES) {
  const md = fs.readFileSync(path.join(docsDir, f), 'utf8');
  const toks = marked.lexer(md, { gfm: true });
  const out = [];
  blocks(toks, out, ctx);
  body.push(...out);
}

const doc = new Document({
  creator: 'Study case ABAP',
  title: 'Study Case Teknik ABAP ECC 6',
  styles: {
    default: { document: { run: { font: FONT, size: 21 } } },
    paragraphStyles: [
      { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: FONT, size: 34, bold: true, color: ACCENT },
        paragraph: { spacing: { before: 0, after: 200 }, keepNext: true, outlineLevel: 0,
          border: { bottom: { style: BorderStyle.SINGLE, size: 8, color: ACCENT, space: 4 } } } },
      { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: FONT, size: 27, bold: true, color: ACCENT },
        paragraph: { spacing: { before: 300, after: 120 }, keepNext: true, outlineLevel: 1 } },
      { id: 'Heading3', name: 'Heading 3', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: FONT, size: 23, bold: true, color: '2E2E2E' },
        paragraph: { spacing: { before: 220, after: 100 }, keepNext: true, outlineLevel: 2 } },
      { id: 'Heading4', name: 'Heading 4', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: FONT, size: 21, bold: true, italics: true, color: '2E2E2E' },
        paragraph: { spacing: { before: 180, after: 80 }, keepNext: true, outlineLevel: 3 } },
    ],
  },
  numbering: {
    config: [
      { reference: 'bullet', levels: [0, 1, 2].map(l => ({ level: l, format: LevelFormat.BULLET,
        text: ['●', '○', '■'][l], alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 720 * (l + 1), hanging: 360 } } } })) },
      { reference: 'num', levels: [0, 1, 2].map(l => ({ level: l, format: [LevelFormat.DECIMAL, LevelFormat.LOWER_LETTER, LevelFormat.LOWER_ROMAN][l],
        text: `%${l + 1}.`, alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 720 * (l + 1), hanging: 360 } } } })) },
    ],
  },
  sections: [{
    properties: { page: { size: { width: PAGE_W, height: 16838 }, margin: { top: 1134, bottom: 1134, left: MARGIN, right: MARGIN } } },
    headers: { default: new Header({ children: [new Paragraph({ alignment: AlignmentType.RIGHT,
      children: [new TextRun({ text: 'Study Case Teknik ABAP ECC 6', size: 16, color: '808080' })] })] }) },
    footers: { default: new Footer({ children: [new Paragraph({ alignment: AlignmentType.CENTER,
      children: [new TextRun({ children: ['Halaman ', PageNumber.CURRENT, ' dari ', PageNumber.TOTAL_PAGES], size: 16, color: '808080' })] })] }) },
    children: body,
  }],
});

Packer.toBuffer(doc).then(buf => { fs.writeFileSync(outFile, buf); console.log('OK', outFile, buf.length, 'bytes'); });
