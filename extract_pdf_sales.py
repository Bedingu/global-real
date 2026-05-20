import fitz
import os
import re

pdf_folder = "Empreendimentos"

for pdf_file in sorted(os.listdir(pdf_folder)):
    if not pdf_file.endswith(".pdf"):
        continue

    pdf_path = os.path.join(pdf_folder, pdf_file)
    doc = fitz.open(pdf_path)

    print(f"\n{'='*60}")
    print(f"📄 {pdf_file} ({len(doc)} páginas)")
    print(f"{'='*60}")

    # Search all pages for key sales data
    keywords = ['m²', 'R$', 'a partir', 'studio', 'dormitório', 'quarto',
                'entrega', 'previsão', 'metragem', 'área', 'unidade',
                'torre', 'andar', 'vaga', 'lazer', 'rentabilidade', '%']

    for page_num in range(len(doc)):
        page = doc[page_num]
        text = page.get_text()
        if not text.strip():
            continue

        # Check if page has sales-relevant info
        lower_text = text.lower()
        has_keywords = any(k in lower_text for k in keywords)
        has_numbers = bool(re.search(r'\d{2,3}\s*m²|\d{3}\.\d{3}|R\$|a partir', text))

        if has_keywords and has_numbers:
            print(f"\n--- Página {page_num + 1} ---")
            # Print only relevant lines
            for line in text.split('\n'):
                line = line.strip()
                if line and any(k in line.lower() for k in keywords):
                    print(f"  {line}")

    doc.close()
