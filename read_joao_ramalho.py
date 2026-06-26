import fitz
import os

# Find the file
folder = "Investimentos"
for f in os.listdir(folder):
    if "Ramalho" in f and f.endswith(".pdf"):
        path = os.path.join(folder, f)
        print(f"Found: {path}")
        doc = fitz.open(path)
        print(f"Pages: {len(doc)}")
        for i in range(min(5, len(doc))):
            text = doc[i].get_text()
            if text.strip():
                print(f"\n--- Page {i+1} ---")
                print(text[:2000])
        doc.close()
        break
