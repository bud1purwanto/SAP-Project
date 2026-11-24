export function draftAlur(sources) {
  const rows = [];
  const calledForms = new Set();
  const calls = [];
  for (const [program, source] of sources) {
    const blocks = [];
    let scope = '';
    for (const [index, raw] of source.entries()) {
      if (raw.trimStart().startsWith('*')) continue;
      const line = raw.match(/^(?:'[^']*'|[^'"])*/)?.[0].trim() ?? '';
      const form = line.match(/^FORM\s+(\w+)/i);
      const event = line.match(/^(INITIALIZATION|START-OF-SELECTION|END-OF-SELECTION|AT SELECTION-SCREEN)\b/i);
      if (form || event || /^ENDFORM\b/i.test(line)) {
        scope = form ? 'FORM ' + form[1].toUpperCase() : event?.[1].toUpperCase() ?? '';
        blocks.length = 0;
      }
      const branch = line.match(/^(ELSEIF|ELSE|WHEN)\b/i);
      if (branch) {
        if (blocks.length) blocks[blocks.length - 1] = line;
      } else if (/^(IF|CASE)\s/i.test(line)) {
        blocks.push(line);
      } else if (/^END(IF|CASE)\b/i.test(line)) {
        blocks.pop();
      }
      const perform = line.match(/^PERFORM\s+(\w+)/i);
      if (perform) calledForms.add(perform[1].toUpperCase());
      if (perform || /^(SUBMIT|CALL TRANSACTION|MESSAGE)\s/i.test(line)) {
        calls.push({program, index, scope, context: blocks.filter(entry => !/^CASE\b/i.test(entry)), line});
      }
    }
  }
  for (const {program, index, scope, context, line} of calls) {
    const status = scope.startsWith('FORM ') && !calledForms.has(scope.slice(5))
      ? 'Pemanggil PERFORM langsung belum ditemukan. Periksa callback atau panggilan dinamis.'
      : 'Tinjau kondisi dan hasil di ECC.';
    rows.push(`  ${program}:${index + 1} | ${[scope, ...context].filter(Boolean).join(' > ') || 'Konteks perlu ditinjau'} | ${line} | ${status}`);
  }
  return ['ALUR YANG PERLU DIUJI', 'Draft statis dari pola ABAP. Kondisi dan aksi di bawah masih perlu direview.', ...rows,
    'Input contoh dan hasil ECC yang diharapkan: diisi bersama functional.', ''].join('\n');
}
