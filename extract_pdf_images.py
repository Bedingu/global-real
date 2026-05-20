import fitz  # PyMuPDF
import os

pdf_folder = "Empreendimentos"
output_base = "Empreendimentos/images"

os.makedirs(output_base, exist_ok=True)

for pdf_file in os.listdir(pdf_folder):
    if not pdf_file.endswith(".pdf"):
        continue

    pdf_name = pdf_file.replace(".pdf", "").lower().replace(" ", "_")
    output_dir = os.path.join(output_base, pdf_name)
    os.makedirs(output_dir, exist_ok=True)

    pdf_path = os.path.join(pdf_folder, pdf_file)
    doc = fitz.open(pdf_path)

    img_count = 0
    for page_num in range(len(doc)):
        page = doc[page_num]
        images = page.get_images(full=True)

        for img_idx, img in enumerate(images):
            xref = img[0]
            base_image = doc.extract_image(xref)
            image_bytes = base_image["image"]
            image_ext = base_image["ext"]
            width = base_image["width"]
            height = base_image["height"]

            # Skip tiny images (logos, icons)
            if width < 200 or height < 200:
                continue

            img_count += 1
            filename = f"page{page_num+1:02d}_img{img_idx+1:02d}_{width}x{height}.{image_ext}"
            filepath = os.path.join(output_dir, filename)

            with open(filepath, "wb") as f:
                f.write(image_bytes)

    doc.close()
    print(f"✅ {pdf_file}: {img_count} imagens extraídas -> {output_dir}")

print("\n🎉 Extração concluída!")
