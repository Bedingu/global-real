import fitz
import os

folder = "Investimentos"
for f in os.listdir(folder):
    if "Ramalho" in f and f.endswith(".pdf"):
        path = os.path.join(folder, f)
        doc = fitz.open(path)
        for i in range(len(doc)):
            text = doc[i].get_text()
            if text.strip():
                print(f"\n--- Page {i+1} ---")
                print(text[:2000])
        doc.close()
        break
