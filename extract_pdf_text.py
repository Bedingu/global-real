import fitz  # PyMuPDF
import os

pdf_folder = "Empreendimentos"

for pdf_file in sorted(os.listdir(pdf_folder)):
    if not pdf_file.endswith(".pdf"):
        continue

    pdf_path = os.path.join(pdf_folder, pdf_file)
    doc = fitz.open(pdf_path)

    print(f"\n{'='*60}")
    print(f"📄 {pdf_file}")
    print(f"{'='*60}")

    # Extract text from first 5 pages (usually has key info)
    for page_num in range(min(5, len(doc))):
        page = doc[page_num]
        text = page.get_text()
        if text.strip():
            print(f"\n--- Página {page_num + 1} ---")
            print(text[:2000])

    doc.close()
