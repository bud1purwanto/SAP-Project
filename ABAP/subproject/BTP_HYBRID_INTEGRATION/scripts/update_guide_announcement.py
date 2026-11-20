guide_path = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/STEP_BY_STEP_IMPLEMENTATION_GUIDE.md"
with open(guide_path, "r", encoding="utf-8") as f:
    text = f.read()

banner = """
> [!IMPORTANT]
> **DOKUMEN RESMI MICROSOFT WORD (.DOCX) TELAH TERSEDIA:**  
> Seluruh panduan implementasi teknis di bawah ini telah dikompilasi secara lengkap ke dalam dokumen Microsoft Word (.docx) siap pakai yang memuat **29 tangkapan layar (screenshot) beranotasi visual (kotak merah dan nomor penunjuk aksi)**:  
> 📄 **File Dokumen:** `outputs/DOKUMENTASI_STEP_BY_STEP_BTP_FIORI_HYBRID_INTEGRATION.docx` (serta salinan di `docs/`)  
> 🖼️ **Arsip Gambar Beranotasi:** `docs/attachments/annotated/`  
> Siap diunggah ke Google Drive dan dipresentasikan kepada manajemen maupun tim teknis.

"""

if "DOKUMEN RESMI MICROSOFT WORD (.DOCX) TELAH TERSEDIA" not in text:
    # insert after the title and metadata
    target = "**Dokumentasi Dibuat Untuk:** Baginda  \n\n---"
    replacement = "**Dokumentasi Dibuat Untuk:** Baginda  \n\n---" + banner
    text = text.replace(target, replacement)
    with open(guide_path, "w", encoding="utf-8") as f:
        f.write(text)
    print("STEP_BY_STEP guide updated with docx announcement.")
else:
    print("Already present.")
